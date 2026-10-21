import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infertilityapp/app_ui.dart';
import 'package:infertilityapp/comman.dart';
import 'package:infertilityapp/eleventh_page.dart';
import 'package:infertilityapp/seventh_page.dart';
import 'package:infertilityapp/third_page.dart';
import 'sixth_page.dart'; // Import statement for the SixthPage

class FifthPage extends StatefulWidget {
  final String userId; // Declare userId variable to store the received user ID
  final int dayDifference;

  // Constructor to receive the user ID as a parameter
  FifthPage({required this.userId, required this.dayDifference});

  @override
  _FifthPageState createState() => _FifthPageState();
}

class _FifthPageState extends State<FifthPage> {
  Map<String, dynamic>? userData;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    // Fetch user data when the page is initialized
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      var url = Uri.parse(doctorprofile);
      var response = await http.post(
        url,
        body: {'userId': widget.userId},
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            var d = data['data'];
            if (d is List) {
              d = d.isNotEmpty ? d[0] : null;
            }
            userData = d is Map ? Map<String, dynamic>.from(d) : null;
          });
        } else {
          print('Error: ${data['message']}');
        }
      } else {
        print('Failed to load user data: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception caught: $e');
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });

    await fetchUserData();

    // Add a delay of 1 second before setting _isRefreshing to false
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _isRefreshing = false;
    });
  }

  Future<void> _addPatient() async {
    // Send form data to PHP server
    var url = Uri.parse(patientid);
    var response = await http.post(
      url,
      body: {
        'name': ' ', // Replace with user input
        'contactno': ' ', // Replace with user input
        'age': ' ', // Replace with user input
        'gender': ' ', // Replace with user input
        'height': ' ', // Replace with user input
        'weight': ' ', // Replace with user input
        'address': ' ', // Replace with user input
        'marriageyear': ' ', // Replace with user input
        'bloodgroup': ' ', // Replace with user input
        'medicalhistory': ' ', // Replace with user input
        'password': ' ', // Replace with user input
        'repassword': ' ', // Replace with user input
      },
    );

    // Handle response
    if (response.statusCode == 200) {
      // Successful response
      var data = json.decode(response.body);
      print('Response data: $data'); // Print response data for debugging
      if (data['status'] == true) {
        // Patient registration successful
        // Extract the patient ID from the response using the correct key
        int patientId = data['Userid'];

        // Navigate to the SeventhPage with User ID
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SeventhPage(
              userId: patientId.toString(),
              dayDifference: widget.dayDifference,
            ), // Convert to string
          ),
        );
      } else {
        // Error in registration
        print('Error: ${data['message']}');
      }
    } else {
      // Error in HTTP request
      print('Failed to register patient: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // Navigate to the ThirdPage when back button is pressed
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => ThirdPage()),
          ModalRoute.withName('/'), // This ensures that ThirdPage becomes the new root
        );
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Dashboard'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SixthPage(
                        userId: widget.userId,
                        dayDifference: widget.dayDifference,
                      ),
                    ),
                  ); // Pass the userId to SixthPage
                },
                child: const CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.surface,
                  child: Icon(Icons.person_rounded,
                      color: AppColors.primary, size: 24),
                ),
              ),
            ),
          ],
        ),
        body: AppBackground(
          decor: BgDecor.ekg,
          child: RefreshIndicator(
            onRefresh: _refreshData,
            color: AppColors.primary,
            child: _isRefreshing
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : ListView(
                    padding: const EdgeInsets.fromLTRB(24, 110, 24, 24),
                    children: [
                      const Text(
                        'Hello, Doctor',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'What would you like to do today?',
                        style: TextStyle(fontSize: 14.5, color: AppColors.muted),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          gradient: kBrandGradient,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Patient Care',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Register and manage your patients with ease',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      height: 1.4,
                                      color:
                                          Colors.white.withValues(alpha: 0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.groups_rounded,
                                  color: Colors.white, size: 34),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _DashboardTile(
                        title: 'Add Patient Details',
                        subtitle: 'Register a new patient',
                        icon: Icons.person_add_alt_1_rounded,
                        onTap: _addPatient,
                      ),
                      const SizedBox(height: 16),
                      _DashboardTile(
                        title: 'View / Modify Patients',
                        subtitle: 'Manage existing records',
                        icon: Icons.people_alt_outlined,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EleventhPage(
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
        ),
      ),
    );
  }
}

class _DashboardTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _DashboardTile({
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
      elevation: 4,
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
                      style:
                          const TextStyle(fontSize: 13, color: AppColors.muted),
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
