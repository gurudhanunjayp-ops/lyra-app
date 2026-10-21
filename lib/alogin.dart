import 'dart:convert'; // Add this line to import the 'json' library
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Add this line to import the 'http' library
import 'package:infertilityapp/adddoctor.dart';
import 'package:infertilityapp/admin.dart';
import 'package:infertilityapp/app_ui.dart';
import 'package:infertilityapp/second_page.dart';
import 'package:infertilityapp/viewdoctor.dart';

class ALogin extends StatefulWidget {
  @override
  State<ALogin> createState() => _ALoginState();
}

class _ALoginState extends State<ALogin> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Admin()),
        );
      },
      child: Scaffold(
        body: AppBackground(
          decor: BgDecor.dots,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _CircleIconButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Admin()),
                          );
                        },
                      ),
                      _CircleIconButton(
                        icon: Icons.logout_rounded,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SecondPage()),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const GradientIconBadge(
                    icon: Icons.admin_panel_settings_outlined,
                    size: 84,
                    iconSize: 42,
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Admin Panel',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Manage doctors in your clinic',
                    style: TextStyle(fontSize: 14, color: AppColors.muted),
                  ),
                  const SizedBox(height: 28),
                  _AdminTile(
                    title: 'View Doctor List',
                    subtitle: 'See all registered doctors',
                    icon: Icons.groups_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ViewDoctor()),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  _AdminTile(
                    title: 'Add Doctor',
                    subtitle: 'Register a new doctor account',
                    icon: Icons.person_add_alt_1_rounded,
                    onTap: () async {
                      // Make the HTTP request to your PHP script
                      final response = await http.post(Uri.parse(
                          'http://14.139.187.229:8081/Infertilityapp/adddocterid.php'));

                      if (response.statusCode == 200) {
                        // Parse the JSON response
                        var jsonData = json.decode(response.body);
                        if (jsonData['status']) {
                          // Extract the dr_userid
                          String drUserId = jsonData['dr_userid'].toString();

                          // Navigate to AddDoctor page with drUserId
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AddDoctor(drUserId: drUserId),
                            ),
                          );
                        } else {
                          // Handle the case when status is false
                          print('Error: ${jsonData['message']}');
                        }
                      } else {
                        // Handle HTTP errors
                        print('HTTP Error: ${response.statusCode}');
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      shadowColor: AppColors.primary.withValues(alpha: 0.2),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
      ),
    );
  }
}

class _AdminTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _AdminTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      elevation: 3,
      shadowColor: AppColors.primary.withValues(alpha: 0.18),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Row(
            children: [
              IconBadge(icon: icon, size: 58, iconSize: 30),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 18, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
