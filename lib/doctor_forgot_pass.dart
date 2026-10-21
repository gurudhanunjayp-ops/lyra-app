import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infertilityapp/app_ui.dart';
import 'package:infertilityapp/comman.dart';
import 'package:infertilityapp/third_page.dart';

class DoctorForgotPasswordPage extends StatefulWidget {
  @override
  _DoctorForgotPasswordPageState createState() =>
      _DoctorForgotPasswordPageState();
}

class _DoctorForgotPasswordPageState extends State<DoctorForgotPasswordPage> {
  TextEditingController userIdController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool _isPasswordVisible =
      false; // Add this variable to track password visibility

  Future<void> updatePassword() async {
    final Uri apiUrl = Uri.parse(drforgotpass);

    final response = await http.post(
      apiUrl,
      body: {
        'userid': userIdController.text,
        'password': newPasswordController.text,
        'repassword': confirmPasswordController.text,
      },
    );

    final responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      if (responseData['status'] == true) {
        // Show success dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Success"),
              content: Text(responseData['message']),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ThirdPage()),
                    );
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      } else {
        // Show error dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text(responseData['message']),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      }
    } else {
      // Show error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Failed to update password"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
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
              'Set a new password for your doctor account',
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
                  ),
                  const SizedBox(height: 18),
                  AppTextField(
                    label: 'New Password',
                    hint: 'Enter new password',
                    icon: Icons.lock_outline_rounded,
                    controller: newPasswordController,
                    obscureText: !_isPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                        // Automatically hide the password after 1 second
                        Future.delayed(Duration(seconds: 1), () {
                          setState(() {
                            _isPasswordVisible = false;
                          });
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
                    obscureText: !_isPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                        // Automatically hide the password after 1 second
                        Future.delayed(Duration(seconds: 1), () {
                          setState(() {
                            _isPasswordVisible = false;
                          });
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 26),
                  PrimaryButton(
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
