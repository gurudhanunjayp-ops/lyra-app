import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infertilityapp/app_ui.dart';
import 'package:infertilityapp/comman.dart';

// ViewDoctor Page
class ViewDoctor extends StatefulWidget {
  const ViewDoctor({Key? key}) : super(key: key);

  @override
  _ViewDoctorState createState() => _ViewDoctorState();
}

class _ViewDoctorState extends State<ViewDoctor> {
  List<Map<String, dynamic>> allDoctors = [];
  List<Map<String, dynamic>> displayedDoctors = [];
  String searchString = '';

  @override
  void initState() {
    super.initState();
    fetchAllDoctorsFromDatabase();
  }

  void fetchAllDoctorsFromDatabase() async {
    try {
      var response = await http.post(
        Uri.parse(viewdoctor),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        List<dynamic> doctorsList = data['data'];
        List<Map<String, dynamic>> details = [];
        doctorsList.forEach((doctor) {
          details.add({
            'dr_userid': doctor['dr_userid'],
            'dr_name': doctor['dr_name'],
          });
        });

        setState(() {
          allDoctors = details;
          displayedDoctors = allDoctors.reversed.take(6).toList();
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
      title: 'Doctors',
      decor: BgDecor.crosses,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchString = value.toLowerCase();
                  displayedDoctors = allDoctors
                      .where((doctor) =>
                          doctor['dr_name']
                              .toLowerCase()
                              .contains(searchString) ||
                          doctor['dr_userid']
                              .toString()
                              .contains(searchString))
                      .toList();
                });
              },
              decoration: const InputDecoration(
                hintText: 'Search by name or ID',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          Expanded(
            child: displayedDoctors.isEmpty
                ? const Center(
                    child: Text(
                      'No doctors found',
                      style: TextStyle(color: AppColors.muted, fontSize: 15),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    itemCount: displayedDoctors.length,
                    itemBuilder: (context, index) {
                      final doctor = displayedDoctors[index];
                      return ListCard(
                        icon: Icons.medical_services_outlined,
                        title: doctor['dr_name'],
                        subtitle: 'ID: ${doctor['dr_userid']}',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DoctorPage(
                                  doctorUserId: doctor['dr_userid']),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// DoctorPage
class DoctorPage extends StatefulWidget {
  final int doctorUserId; // Change the data type to int

  const DoctorPage({Key? key, required this.doctorUserId}) : super(key: key);

  @override
  _DoctorPageState createState() => _DoctorPageState();
}

class _DoctorPageState extends State<DoctorPage> {
  Map<String, dynamic>? doctorDetails;

  @override
  void initState() {
    super.initState();
    fetchDoctorDetails();
  }

  void fetchDoctorDetails() async {
    try {
      var response = await http.post(
        Uri.parse(drprofiledisplay),
        body: {
          'dr_userid': widget.doctorUserId.toString()
        }, // Convert int to string here
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
      title: 'Doctor Details',
      decor: BgDecor.crosses,
      body: doctorDetails == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      radius: 58,
                      backgroundColor: AppColors.surface,
                      backgroundImage: NetworkImage(
                        '$drimage${doctorDetails!['doctorimage']}',
                      ),
                      onBackgroundImageError: (_, __) {},
                      child: doctorDetails!['doctorimage'] == null ||
                              doctorDetails!['doctorimage'] == ''
                          ? const Icon(Icons.person_rounded,
                              size: 56, color: AppColors.primary)
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      doctorDetails!['dr_name']?.toString() ?? '',
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      doctorDetails!['designation']?.toString() ?? '',
                      style: const TextStyle(
                          fontSize: 14, color: AppColors.muted),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                SectionCard(
                  child: Column(
                    children: [
                      _InfoRow(
                          icon: Icons.badge_outlined,
                          label: 'User ID',
                          value: doctorDetails!['dr_userid']),
                      _InfoRow(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: doctorDetails!['email']),
                      _InfoRow(
                          icon: Icons.work_outline_rounded,
                          label: 'Designation',
                          value: doctorDetails!['designation']),
                      _InfoRow(
                          icon: Icons.phone_outlined,
                          label: 'Contact No',
                          value: doctorDetails!['contact_no']),
                    ],
                  ),
                ),
              ],
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
            width: 105,
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted),
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
