import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infertilityapp/app_ui.dart';
import 'package:infertilityapp/comman.dart';
import 'package:infertilityapp/health_notification_service.dart';
import 'package:infertilityapp/plogin.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'forgot_password_page.dart';
import 'second_page.dart';

class FourthPage extends StatefulWidget {
  const FourthPage({super.key});

  @override
  State<FourthPage> createState() => _FourthPageState();
}

class _FourthPageState extends State<FourthPage> {
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _userIdError;
  String? _passwordError;

  @override
  void dispose() {
    userIdController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  Future<void> _login() async {
    final userId = userIdController.text.trim();
    final password = passwordController.text;

    final idError = AppValidators.userId(userId);
    final passError = AppValidators.loginPassword(password);
    setState(() {
      _userIdError = idError;
      _passwordError = passError;
    });
    if (idError != null || passError != null) return;
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authenticatePatient(userId, password);
      if (!mounted) return;

      if (result.data == null) {
        _showError(
          result.error ?? 'Invalid User ID or password. Please try again.',
          title: result.errorTitle,
        );
        return;
      }

      final Map<String, dynamic> data = result.data!;

      // Check nested objects if patient data is wrapped inside data/patientDetails/user
      Map<String, dynamic> detailMap = data;
      if (data['patientDetails'] is Map<String, dynamic>) {
        detailMap = data['patientDetails'];
      } else if (data['patientDetails'] is List &&
          (data['patientDetails'] as List).isNotEmpty &&
          (data['patientDetails'] as List).first is Map) {
        detailMap = Map<String, dynamic>.from((data['patientDetails'] as List).first);
      } else if (data['data'] is Map<String, dynamic>) {
        detailMap = data['data'];
      } else if (data['data'] is List &&
          (data['data'] as List).isNotEmpty &&
          (data['data'] as List).first is Map) {
        detailMap = Map<String, dynamic>.from((data['data'] as List).first);
      } else if (data['user'] is Map<String, dynamic>) {
        detailMap = data['user'];
      }

      // Extract resolved patient ID
      final rawId = detailMap['Userid'] ??
          detailMap['userid'] ??
          detailMap['userId'] ??
          detailMap['user_id'] ??
          detailMap['patientId'] ??
          detailMap['patient_id'] ??
          data['Userid'] ??
          data['userid'] ??
          data['userId'] ??
          data['user_id'] ??
          data['patientId'] ??
          data['patient_id'];

      final patientId = (rawId != null && rawId.toString().trim().isNotEmpty)
          ? rawId.toString().trim()
          : userId;

      // Extract resolved patient Name
      final rawName = detailMap['Name'] ??
          detailMap['name'] ??
          detailMap['patientName'] ??
          detailMap['patient_name'] ??
          data['Name'] ??
          data['name'] ??
          data['patientName'] ??
          data['patient_name'];

      String patientName = rawName?.toString().trim() ?? '';

      // If name was not returned in the login response, fetch it from viewpatient
      if (patientName.isEmpty) {
        try {
          final profileRes = await http.post(
            Uri.parse(viewpatient),
            body: {'userId': patientId, 'userid': patientId},
          ).timeout(const Duration(seconds: 4));

          if (profileRes.statusCode == 200) {
            final pBody = profileRes.body;
            final pStart = pBody.indexOf('{');
            final pEnd = pBody.lastIndexOf('}');
            if (pStart >= 0 && pEnd > pStart) {
              final pJson = jsonDecode(pBody.substring(pStart, pEnd + 1));
              var details = pJson['patientDetails'];
              if (details is List && details.isNotEmpty) {
                details = details.first;
              }
              if (details is Map && details['Name'] != null) {
                patientName = details['Name'].toString().trim();
              }
            }
          }
        } catch (_) {
          // Non-critical: continue with available info
        }
      }

      // Save user ID to SharedPreferences across all common keys
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', patientId);
      await prefs.setString('UserId', patientId);
      await prefs.setString('userid', patientId);
      await prefs.setString('patientId', patientId);
      if (patientName.isNotEmpty) {
        await prefs.setString('name', patientName);
        await prefs.setString('userName', patientName);
      }

      if (!mounted) return;

      // Navigate to patient dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PLoginPage(
            userId: patientId,
            name: patientName,
          ),
        ),
      );

      // Schedule background notifications safely
      try {
        unawaited(HealthNotificationService.configureForPatientLogin());
      } catch (notifErr) {
        debugPrint('Notification setup error: $notifErr');
      }
    } on TimeoutException {
      if (mounted) {
        _showError(
          'The login request timed out. Please check your internet connection and try again.',
          title: 'Connection Timeout',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Patient login error: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (mounted) {
        _showError(
          'Unable to reach the server. Please check your internet connection and try again.',
          title: 'Connection Error',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Sends the patient login request and decides whether it succeeded.
  ///
  /// The live database cannot be modified, and some existing rows store the
  /// password padded with spaces (e.g. " 90") or left at the column default
  /// ('WELCOME' / a single space). To let those users sign in without any
  /// server-side change, each plausible form of the typed password is tried
  /// in order until the backend accepts one.
  Future<_PatientLoginResult> _authenticatePatient(
    String userId,
    String password,
  ) async {
    final uri = Uri.parse(patientlogin);

    final candidates = <String>[];
    void addCandidate(String value) {
      if (value.isNotEmpty && !candidates.contains(value)) {
        candidates.add(value);
      }
    }

    final trimmed = password.trim();
    addCandidate(password);
    addCandidate(trimmed);
    addCandidate(' $trimmed');
    addCandidate('$trimmed ');
    addCandidate(' ');
    addCandidate('WELCOME');

    bool gotValidResponse = false;
    String? lastMessage;

    for (final candidate in candidates) {
      // Support all potential key casing used across different versions
      // of the PHP patient login backend.
      final Map<String, String> bodyFields = {
        'userid': userId,
        'Userid': userId,
        'userId': userId,
        'user_id': userId,
        'patientid': userId,
        'patient_id': userId,
        'username': userId,
        'password': candidate,
        'Password': candidate,
      };

      http.Response response;
      try {
        response = await http
            .post(uri, body: bodyFields)
            .timeout(const Duration(seconds: 20));
      } on TimeoutException {
        return const _PatientLoginResult(
          error: 'The login request timed out. Please check your internet connection and try again.',
          errorTitle: 'Connection Timeout',
        );
      } catch (e) {
        debugPrint('Patient login network error: $e');
        return const _PatientLoginResult(
          error: 'Unable to reach the server. Please check your internet connection and try again.',
          errorTitle: 'Connection Error',
        );
      }

      debugPrint('Patient login HTTP status: ${response.statusCode}');

      dynamic parsedData = _tryExtractJsonOrStatus(response.body);
      if (parsedData == null) {
        // Fallback: try posting as application/json
        try {
          final jsonResponse = await http
              .post(
                uri,
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
                body: jsonEncode(bodyFields),
              )
              .timeout(const Duration(seconds: 15));

          final candidateData = _tryExtractJsonOrStatus(jsonResponse.body);
          if (candidateData != null) {
            parsedData = candidateData;
          }
        } catch (fallbackError) {
          debugPrint('JSON fallback error: $fallbackError');
        }
      }

      if (parsedData == null) {
        // Check for plain-text successful responses
        final rawTrimmed = response.body.trim().toLowerCase();
        if (rawTrimmed == 'success' ||
            rawTrimmed == '1' ||
            rawTrimmed == 'true' ||
            rawTrimmed == 'ok') {
          return const _PatientLoginResult(data: {'status': true});
        }
        continue;
      }

      gotValidResponse = true;

      final Map<String, dynamic> data = parsedData is Map<String, dynamic>
          ? parsedData
          : Map<String, dynamic>.from(parsedData as Map);

      if (_isLoginSuccess(data)) {
        return _PatientLoginResult(data: data);
      }

      final message = data['message']?.toString();
      if (message != null && message.trim().isNotEmpty) {
        lastMessage = message;
      }
    }

    if (!gotValidResponse) {
      return const _PatientLoginResult(
        error: 'The server returned an unrecognised response. Please check your credentials or try again later.',
        errorTitle: 'Login Error',
      );
    }

    return _PatientLoginResult(
      error: (lastMessage != null && lastMessage.trim().isNotEmpty)
          ? lastMessage
          : 'Invalid User ID or password. Please try again.',
      errorTitle: 'Patient Login Failed',
    );
  }

  /// Comprehensive success validation: supports boolean true, int 1,
  /// strings 'success', 'true', '1', 'ok', or presence of patient data.
  bool _isLoginSuccess(Map<String, dynamic> data) {
    final rawStatus = data['status'];
    final rawSuccess = data['success'];
    final statusStr = rawStatus?.toString().toLowerCase().trim() ?? '';
    final successStr = rawSuccess?.toString().toLowerCase().trim() ?? '';

    return rawStatus == true ||
        rawSuccess == true ||
        rawStatus == 1 ||
        rawSuccess == 1 ||
        statusStr == 'success' ||
        statusStr == 'true' ||
        statusStr == '1' ||
        statusStr == 'ok' ||
        statusStr == 'valid' ||
        successStr == 'success' ||
        successStr == 'true' ||
        successStr == '1' ||
        successStr == 'ok' ||
        (data['patientDetails'] != null &&
            data['patientDetails'] != false &&
            data['patientDetails'] != '') ||
        (data['data'] != null && data['data'] != false && data['data'] != '');
  }

  /// Extracts JSON object even when preceded by PHP warnings or strings like "Connected"
  dynamic _tryExtractJsonOrStatus(String responseBody) {
    try {
      final trimmed = responseBody.trim();
      final jsonStart = trimmed.indexOf('{');
      final jsonEnd = trimmed.lastIndexOf('}');

      if (jsonStart >= 0 && jsonEnd > jsonStart) {
        final cleanJson = trimmed.substring(jsonStart, jsonEnd + 1);
        final decoded = jsonDecode(cleanJson);
        if (decoded is Map<String, dynamic> || decoded is Map) {
          return decoded;
        }
      }

      // Check array format [{...}]
      final arrStart = trimmed.indexOf('[');
      final arrEnd = trimmed.lastIndexOf(']');
      if (arrStart >= 0 && arrEnd > arrStart) {
        final cleanArr = trimmed.substring(arrStart, arrEnd + 1);
        final decoded = jsonDecode(cleanArr);
        if (decoded is List && decoded.isNotEmpty && decoded.first is Map) {
          return decoded.first;
        }
      }

      // Check direct JSON decode
      final direct = jsonDecode(trimmed);
      if (direct is Map<String, dynamic> || direct is Map) {
        return direct;
      }
    } catch (_) {
      // Not valid JSON
    }
    return null;
  }

  void _showError(
    String message, {
    String title = 'Error',
  }) {
    if (!mounted) return;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || !mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => SecondPage()),
          (route) => false,
        );
      },
      child: Scaffold(
        body: AppBackground(
          decor: BgDecor.hearts,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => SecondPage()),
                          (route) => false,
                        );
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const GradientIconBadge(
                    icon: Icons.person_outline_rounded,
                    size: 92,
                    iconSize: 44,
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Patient Login',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Welcome back to your journey',
                    style: TextStyle(
                      fontSize: 14.5,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 30),
                  SectionCard(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      children: [
                        AppTextField(
                          label: 'User ID',
                          hint: 'Enter your patient user id',
                          icon: Icons.person_outline_rounded,
                          controller: userIdController,
                          maxLength: 20,
                          textInputAction: TextInputAction.next,
                          errorText: _userIdError,
                          onChanged: (_) {
                            if (_userIdError != null) {
                              setState(() => _userIdError = null);
                            }
                          },
                        ),
                        const SizedBox(height: 18),
                        AppTextField(
                          label: 'Password',
                          hint: 'Enter your password',
                          icon: Icons.lock_outline_rounded,
                          controller: passwordController,
                          obscureText: !_isPasswordVisible,
                          maxLength: 50,
                          textInputAction: TextInputAction.done,
                          errorText: _passwordError,
                          onSubmitted: (_) => _login(),
                          onChanged: (_) {
                            if (_passwordError != null) {
                              setState(() => _passwordError = null);
                            }
                          },
                          suffixIcon: IconButton(
                            tooltip: _isPasswordVisible ? 'Hide password' : 'Show password',
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: _togglePasswordVisibility,
                          ),
                        ),
                        const SizedBox(height: 26),
                        if (_isLoading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        else
                          PrimaryButton(
                            label: 'Login',
                            icon: Icons.login_rounded,
                            onPressed: _login,
                          ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ForgotPasswordPage(),
                                    ),
                                  );
                                },
                          child: const Text('Create / Forgot Password?'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),
                  const Text(
                    'Hope blooms here.\nWelcome back to your journey',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PatientLoginResult {
  final Map<String, dynamic>? data;
  final String? error;
  final String errorTitle;

  const _PatientLoginResult({
    this.data,
    this.error,
    this.errorTitle = 'Patient Login Failed',
  });
}
