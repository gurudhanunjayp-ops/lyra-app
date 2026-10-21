import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infertilityapp/app_ui.dart';
import 'package:infertilityapp/second_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:infertilityapp/comman.dart';
import 'package:infertilityapp/fifth_page.dart';
import 'package:infertilityapp/doctor_forgot_pass.dart';
import 'dart:convert';

class ThirdPage extends StatefulWidget {
  @override
  _ThirdPageState createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage> {
  TextEditingController userIdController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
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

    setState(() => _isLoading = true);
    try {
      // API endpoint URL
      var url = Uri.parse(doctorlogin);

      // Data to send via form data (not JSON)
      var data = {
        'dr_userid': userId,
        'password': password,
      };

      // Send POST request to the server
      var response = await http.post(
        url,
        body: data, // Sending as form data
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) throw Exception('Login unavailable');

      // Clean up response body to remove extra text like "Connected"
      String responseBody = response.body;
      if (responseBody.contains("{")) {
        responseBody = responseBody.substring(responseBody.indexOf("{"));
      }

      try {
        // Parse the cleaned JSON response
        var responseData = jsonDecode(responseBody);

        // Check login status
        if (responseData['status'] == 'success') {
          // Save the User ID using shared preferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('UserId', userId);
          if (!mounted) return;

          // Navigate to the FifthPage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => FifthPage(
                userId: userId,
                // Doctor IDs may contain letters; successful login must not crash.
                dayDifference: int.tryParse(userId) ?? 0,
              ),
            ),
          );
        } else {
          // Login failed
          _showLoginFailedDialog();
        }
      } catch (e) {
        // Handle the parsing error
        print('Error parsing JSON: $e');
        _showLoginFailedDialog();
      }
    } catch (e) {
      _showLoginFailedDialog(e is TimeoutException
          ? 'The request timed out. Check your connection and try again.'
          : 'We could not sign you in. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showLoginFailedDialog([String message = 'Invalid user ID or password.']) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Login Failed'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SecondPage()),
        );
      },
      child: Scaffold(
        body: AppBackground(
          decor: BgDecor.waves,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => SecondPage()),
                      ),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppColors.ink),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const GradientIconBadge(
                    icon: Icons.medical_services_outlined,
                    size: 92,
                    iconSize: 44,
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Doctor Login',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Welcome back, Doctor!',
                    style: TextStyle(fontSize: 14.5, color: AppColors.muted),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.12),
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
                            tooltip: _isPasswordVisible
                                ? 'Hide password'
                                : 'Show password',
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: _togglePasswordVisibility,
                          ),
                        ),
                        const SizedBox(height: 26),
                        _isLoading
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: CircularProgressIndicator(
                                      color: AppColors.primary),
                                ),
                              )
                            : PrimaryButton(
                                label: 'Login',
                                icon: Icons.login_rounded,
                                onPressed: _login,
                              ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      DoctorForgotPasswordPage()),
                            );
                          },
                          child: const Text('Create / Forgot Password?'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),
                  const Text(
                    'Empowering Lives, Fertility Strides.',
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
