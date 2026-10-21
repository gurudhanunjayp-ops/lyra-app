import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infertilityapp/app_ui.dart';
import 'package:infertilityapp/comman.dart';
import 'package:infertilityapp/fourth_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  TextEditingController userIdController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  String? _userIdError;
  String? _newPasswordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    userIdController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> updatePassword() async {
    final uid = userIdController.text.trim();
    final newPass = newPasswordController.text;
    final confirmPass = confirmPasswordController.text;

    final uidError = AppValidators.userId(uid);
    final newPassError = AppValidators.strongPassword(newPass);
    final confirmError =
        AppValidators.confirmPassword(confirmPass, newPass);

    setState(() {
      _userIdError = uidError;
      _newPasswordError = newPassError;
      _confirmPasswordError = confirmError;
    });

    if (uidError != null || newPassError != null || confirmError != null) {
      return;
    }
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final Uri apiUrl = Uri.parse(patientforgotpass);

      final response = await http.post(
        apiUrl,
        body: {
          'userid': uid,
          'Userid': uid,
          'userId': uid,
          'user_id': uid,
          'password': newPass,
          'repassword': confirmPass,
          'confirm_password': confirmPass,
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        String responseBody = response.body.trim();
        final start = responseBody.indexOf('{');
        final end = responseBody.lastIndexOf('}');
        if (start >= 0 && end > start) {
          responseBody = responseBody.substring(start, end + 1);
        }

        final responseData = json.decode(responseBody);
        final status = responseData['status'];
        final statusStr = status?.toString().toLowerCase().trim();

        if (status == true || statusStr == 'success' || statusStr == 'true' || statusStr == '1') {
          if (!mounted) return;
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Success"),
                content: Text(responseData['message']?.toString() ?? "Password updated successfully!"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => FourthPage()),
                      );
                    },
                    child: const Text("OK"),
                  ),
                ],
              );
            },
          );
        } else {
          _showDialog("Error", responseData['message']?.toString() ?? "Failed to update password.");
        }
      } else {
        _showDialog("Error", "Server returned HTTP ${response.statusCode}. Please try again.");
      }
    } catch (e) {
      _showDialog("Connection Error", "Unable to update password. Please check your connection and try again.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showDialog(String title, String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      decor: BgDecor.waves,
      title: 'Reset Password',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const GradientIconBadge(
              icon: Icons.lock_reset_rounded,
              size: 84,
              iconSize: 42,
            ),
            const SizedBox(height: 14),
            const Text(
              'Set a new password for your patient account',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.5, color: AppColors.muted),
            ),
            const SizedBox(height: 26),
            SectionCard(
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
                    label: 'New Password',
                    hint: 'Enter new password',
                    icon: Icons.lock_outline_rounded,
                    controller: newPasswordController,
                    obscureText: !_isNewPasswordVisible,
                    maxLength: 32,
                    textInputAction: TextInputAction.next,
                    errorText: _newPasswordError,
                    onChanged: (_) {
                      if (_newPasswordError != null) {
                        setState(() => _newPasswordError = null);
                      }
                    },
                    suffixIcon: IconButton(
                      tooltip: _isNewPasswordVisible
                          ? 'Hide password'
                          : 'Show password',
                      icon: Icon(_isNewPasswordVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                      onPressed: () {
                        setState(() {
                          _isNewPasswordVisible = !_isNewPasswordVisible;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  AppTextField(
                    label: 'Confirm Password',
                    hint: 'Re-enter new password',
                    icon: Icons.lock_outline_rounded,
                    controller: confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    maxLength: 32,
                    textInputAction: TextInputAction.done,
                    errorText: _confirmPasswordError,
                    onSubmitted: (_) => updatePassword(),
                    onChanged: (_) {
                      if (_confirmPasswordError != null) {
                        setState(() => _confirmPasswordError = null);
                      }
                    },
                    suffixIcon: IconButton(
                      tooltip: _isConfirmPasswordVisible
                          ? 'Hide password'
                          : 'Show password',
                      icon: Icon(_isConfirmPasswordVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        });
                      },
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
                          label: 'Update Password',
                          icon: Icons.check_rounded,
                          onPressed: updatePassword,
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
