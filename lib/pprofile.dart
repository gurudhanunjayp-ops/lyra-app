import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infertilityapp/app_ui.dart';
import 'package:infertilityapp/comman.dart';
import 'package:infertilityapp/fourth_page.dart';
import 'package:infertilityapp/plogin.dart';

class PProfilePage extends StatefulWidget {
  final String userId;
  final String name;
  // Change Int to int

  PProfilePage({required this.userId, required this.name}); // Update constructor

  @override
  _PProfilePageState createState() => _PProfilePageState();
}

class _PProfilePageState extends State<PProfilePage> {
  late String name;
  late String imageUrl;
  late String mobileNumber;
  late String yearOfMarriage;
  late String bloodGroup;

  @override
  void initState() {
    super.initState();
    imageUrl = '';
    mobileNumber = '';
    yearOfMarriage = '';
    bloodGroup = '';
    name = '';
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.post(
      Uri.parse(viewpatient),
      body: {'userId': widget.userId},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status']) {
        setState(() {
          var details = data['patientDetails'];
          if (details is List) {
            details = details.isNotEmpty ? details[0] : null;
          }
          mobileNumber = details?['ContactNo'] ?? '';
          name = details?['Name'] ?? '';
          yearOfMarriage = details?['Marriageyear'] ?? '';
          bloodGroup = details?['Bloodgroup'] ?? '';
          final image = details?['image'];
          if (image != null && image.isNotEmpty) {
            imageUrl = image.startsWith('http') ? image : '$patientimage$image';
          } else {
            imageUrl = ''; // Set imageUrl to empty if image is null or empty
          }
        });
        print('Image fetched successfully'); // Print statement
      } else {
        print(data['message']);
      }
    } else {
      print('Error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'My Profile',
      decor: BgDecor.hearts,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: AppColors.ink),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    PLoginPage(userId: widget.userId, name: widget.name)),
          );
        },
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FourthPage()),
            );
          },
          icon:
              const Icon(Icons.logout_rounded, color: AppColors.primary),
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    width: 3),
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: AppColors.surface,
                backgroundImage:
                    imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                onBackgroundImageError:
                    imageUrl.isNotEmpty ? (_, __) {} : null,
                child: imageUrl.isEmpty
                    ? const Icon(Icons.person_rounded,
                        size: 58, color: AppColors.primary)
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              name.isNotEmpty ? name : widget.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            Text(
              'ID: ${widget.userId}',
              style:
                  const TextStyle(fontSize: 14, color: AppColors.muted),
            ),
            const SizedBox(height: 24),
            SectionCard(
              title: 'Personal Details',
              child: Column(
                children: [
                  _InfoRow(
                      icon: Icons.person_outline_rounded,
                      label: 'Name',
                      value: name),
                  _InfoRow(
                      icon: Icons.badge_outlined,
                      label: 'Patient ID',
                      value: widget.userId),
                  _InfoRow(
                      icon: Icons.phone_outlined,
                      label: 'Mobile Number',
                      value: mobileNumber),
                  _InfoRow(
                      icon: Icons.bloodtype_outlined,
                      label: 'Blood Group',
                      value: bloodGroup),
                  _InfoRow(
                      icon: Icons.favorite_border_rounded,
                      label: 'Year of Marriage',
                      value: yearOfMarriage),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final dynamic value;

  const _InfoRow({required this.icon, required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
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
              (value != null && value.toString().isNotEmpty)
                  ? value.toString()
                  : 'N/A',
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
