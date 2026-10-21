import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:infertilityapp/app_ui.dart';
import 'package:infertilityapp/tenth_page.dart';
import 'comman.dart';

class SixthPage extends StatefulWidget {
  final String userId;
  final int dayDifference;

  SixthPage({required this.userId, required this.dayDifference});

  @override
  _SixthPageState createState() => _SixthPageState();
}

class _SixthPageState extends State<SixthPage> {
  Map<String, dynamic>? doctorDetails;

  @override
  void initState() {
    super.initState();
    fetchDoctorDetails();
  }

  Future<void> fetchDoctorDetails() async {
    try {
      var response = await http.post(
        Uri.parse(drprofiledisplay),
        body: {'dr_userid': widget.userId.toString()},
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          doctorDetails = data['doctorDetails'] is Map
              ? Map<String, dynamic>.from(data['doctorDetails'])
              : (data['doctorDetails'] is List &&
                      (data['doctorDetails'] as List).isNotEmpty
                  ? Map<String, dynamic>.from(data['doctorDetails'][0])
                  : null);
        });
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'My Profile',
      decor: BgDecor.ekg,
      body: doctorDetails == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          width: 3),
                    ),
                    child: CircleAvatar(
                      radius: 62,
                      backgroundColor: AppColors.surface,
                      backgroundImage: NetworkImage(
                        '$drimage${doctorDetails!['doctorimage']}',
                      ),
                      onBackgroundImageError: (_, __) {},
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    doctorDetails!['dr_name']?.toString() ?? '',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  Text(
                    doctorDetails!['designation']?.toString() ?? '',
                    style: const TextStyle(
                        fontSize: 14.5, color: AppColors.muted),
                  ),
                  const SizedBox(height: 24),
                  SectionCard(
                    child: Column(
                      children: [
                        _InfoTile(
                            icon: Icons.badge_outlined,
                            label: 'User ID',
                            value: doctorDetails!['dr_userid']),
                        _InfoTile(
                            icon: Icons.person_outline_rounded,
                            label: 'Name',
                            value: doctorDetails!['dr_name']),
                        _InfoTile(
                            icon: Icons.email_outlined,
                            label: 'Email',
                            value: doctorDetails!['email']),
                        _InfoTile(
                            icon: Icons.work_outline_rounded,
                            label: 'Designation',
                            value: doctorDetails!['designation']),
                        _InfoTile(
                            icon: Icons.phone_outlined,
                            label: 'Contact',
                            value: doctorDetails!['contact_no']),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  PrimaryButton(
                    label: 'Edit Profile',
                    icon: Icons.edit_rounded,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TenthPage(
                            doctorDetails: doctorDetails!,
                            userId: widget.userId,
                            dayDifference: widget.dayDifference,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final dynamic value;

  const _InfoTile({required this.icon, required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.muted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value != null ? value.toString() : 'N/A',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
