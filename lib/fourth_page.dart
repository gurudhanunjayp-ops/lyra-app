
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
  final TextEditingController userIdController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

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

    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;

      if (_isPasswordVisible) {
        setState(() {
          _isPasswordVisible = false;
        });
      }
    });
  }

  Future<void> _login() async {
    final userId = userIdController.text.trim();
    final password = passwordController.text;

    if (userId.isEmpty || password.isEmpty) {
      _showError(
        'Enter both your user ID and password.',
      );
      return;
    }

    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final uri = Uri.parse(patientlogin);

      final response = await http
          .post(
            uri,
            headers: const {
              'Content-Type':
                  'application/x-www-form-urlencoded',
              'Accept': 'application/json',
            },
            body: {
              'Userid': userId,
              'password': password,
            },
          )
          .timeout(const Duration(seconds: 20));

      if (!mounted) return;

      debugPrint(
        'Patient login HTTP status: ${response.statusCode}',
      );

      if (response.statusCode != 200) {
        _showError(
          'The server returned HTTP '
          '${response.statusCode}. Please try again later.',
          title: 'Login Error',
        );
        return;
      }

      final responseBody = response.body.trim();

      // Handle a JSON response, including a possible PHP
      // warning or notice before the JSON object.
      final jsonStart = responseBody.indexOf('{');
      final jsonEnd = responseBody.lastIndexOf('}');

      if (jsonStart < 0 || jsonEnd < jsonStart) {
        debugPrint(
          'Invalid patient login response: $responseBody',
        );

        _showError(
          'The server returned an invalid response. '
          'Please check the patient login API.',
          title: 'Server Response Error',
        );
        return;
      }

      final decoded = jsonDecode(
        responseBody.substring(
          jsonStart,
          jsonEnd + 1,
        ),
      );

      if (decoded is! Map<String, dynamic>) {
        _showError(
          'Unexpected response from the login server.',
        );
        return;
      }

      final data = decoded;

      // Accept the response formats supported by this client.
      final status =
          data['status']?.toString().toLowerCase();

      final success =
          data['success'] == true ||
          status == 'success';

      if (!success) {
        final message = data['message']?.toString();

        _showError(
          message != null && message.trim().isNotEmpty
              ? message
              : 'Invalid user ID or password.',
          title: 'Patient Login Failed',
        );
        return;
      }

      // Read the patient ID and name if the API returns them.
      // Otherwise, retain the entered ID for compatibility
      // with the existing backend response.
      final rawPatientId =
          data['Userid'] ??
          data['userId'] ??
          data['user_id'] ??
          data['patientId'] ??
          data['patient_id'];

      final returnedPatientId =
          rawPatientId?.toString().trim();

      final patientId =
          returnedPatientId != null &&
                  returnedPatientId.isNotEmpty
              ? returnedPatientId
              : userId;

      final rawName =
          data['name'] ??
          data['patientName'] ??
          data['patient_name'];

      final patientName =
          rawName?.toString().trim() ?? '';

      if (patientId.isEmpty) {
        _showError(
          'The server did not provide a valid patient ID.',
          title: 'Login Error',
        );
        return;
      }

      final prefs =
          await SharedPreferences.getInstance();

      await prefs.setString('userId', patientId);

      if (!mounted) return;

      // Open the patient dashboard only after login succeeds.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PLoginPage(
            userId: patientId,
            name: patientName,
          ),
        ),
      );

      // Notifications must not block navigation.
      unawaited(
        HealthNotificationService
            .configureForPatientLogin(),
      );
    } on TimeoutException {
      if (mounted) {
        _showError(
          'The login request timed out. '
          'Check your internet connection and try again.',
          title: 'Connection Timeout',
        );
      }
    } on FormatException catch (e) {
      debugPrint('Patient login JSON error: $e');

      if (mounted) {
        _showError(
          'The server response could not be processed. '
          'Please check the login API response.',
          title: 'Response Error',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Patient login error: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (mounted) {
        _showError(
          'Unable to reach the server. Check the API URL, '
          'internet connection, and backend service.',
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
          MaterialPageRoute(
builder: (_) => SecondPage(),          ),
          (route) => false,
        );
      },
      child: Scaffold(
        body: AppBackground(
          decor: BgDecor.waves,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 28,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
builder: (_) => SecondPage(),                          ),
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

                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(
                        alpha: 0.85,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(
                            alpha: 0.12,
                          ),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        AppTextField(
                          label: 'User ID',
                          hint: 'Enter your user id',
                          icon: Icons.person_outline_rounded,
                          controller: userIdController,
                        ),

                        const SizedBox(height: 18),

                        AppTextField(
                          label: 'Password',
                          hint: 'Enter your password',
                          icon: Icons.lock_outline_rounded,
                          controller: passwordController,
                          obscureText: !_isPasswordVisible,
                          suffixIcon: IconButton(
                            tooltip: _isPasswordVisible
                                ? 'Hide password'
                                : 'Show password',
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed:
                                _togglePasswordVisibility,
                          ),
                        ),

                        const SizedBox(height: 26),

                        if (_isLoading)
                          const CircularProgressIndicator(
                            color: AppColors.primary,
                          )
                        else
                          PrimaryButton(
                            label: 'Login',
                            icon: Icons.login_rounded,
                            onPressed: _login,
                          ),

                        const SizedBox(height: 8),

                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ForgotPasswordPage(),
                                    ),
                                  );
                                },
                          child: const Text(
                            'Create / Forgot Password?',
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  const Text(
                    'Hope blooms here.\n'
                    'Welcome back to your journey',
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
