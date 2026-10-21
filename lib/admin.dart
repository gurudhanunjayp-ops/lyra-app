import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infertilityapp/alogin.dart';
import 'package:infertilityapp/app_ui.dart';
import 'second_page.dart';
import 'comman.dart';
import 'dart:async';

class Admin extends StatefulWidget {
  @override
  _AdminState createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  final TextEditingController passwordController = TextEditingController();
  final String adminId = '1920';
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _passwordError;

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  Future<void> loginAdmin() async {
    final password = passwordController.text;
    final passError = AppValidators.loginPassword(password);
    setState(() => _passwordError = passError);
    if (passError != null) return;
    if (_isLoading) return;

    setState(() => _isLoading = true);
    try {
      final response = await http
          .post(
            Uri.parse(doctorlogin),
            body: {
              'dr_userid': adminId,
              'password': passwordController.text,
            },
          )
          .timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) throw Exception('Login unavailable');

      var responseBody = response.body;
      final jsonStart = responseBody.indexOf('{');
      if (jsonStart >= 0) responseBody = responseBody.substring(jsonStart);
      final responseData = jsonDecode(responseBody);
      if (responseData['status'] == 'success') {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ALogin()),
        );
      } else {
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

  void _showLoginFailedDialog([String message = 'Invalid admin password.']) {
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
        // Navigate to AdminPage when back button is pressed
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SecondPage()),
        );
      },
      child: Scaffold(
        body: AppBackground(
          decor: BgDecor.crosses,
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
                  const SizedBox(height: 24),
                  const GradientIconBadge(
                    icon: Icons.admin_panel_settings_outlined,
                    size: 92,
                    iconSize: 44,
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Admin Login',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Restricted access — administrators only',
                    style: TextStyle(fontSize: 14.5, color: AppColors.muted),
                  ),
                  const SizedBox(height: 30),
                  SectionCard(
                    child: Column(
                      children: [
                        AppTextField(
                          label: 'Admin ID',
                          icon: Icons.person_outline_rounded,
                          controller: TextEditingController(text: adminId),
                          enabled: false,
                        ),
                        const SizedBox(height: 18),
                        AppTextField(
                          label: 'Password',
                          hint: 'Enter admin password',
                          icon: Icons.lock_outline_rounded,
                          controller: passwordController,
                          obscureText: !_isPasswordVisible,
                          maxLength: 50,
                          textInputAction: TextInputAction.done,
                          errorText: _passwordError,
                          onSubmitted: (_) => loginAdmin(),
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
                                onPressed: loginAdmin,
                              ),
                      ],
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
