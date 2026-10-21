import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:infertilityapp/app_ui.dart';
import 'package:infertilityapp/comman.dart';
import 'package:infertilityapp/cycle.dart';
import 'package:infertilityapp/fifth_page.dart';
import 'package:infertilityapp/graph.dart';
import 'package:infertilityapp/medications.dart';
import 'package:infertilityapp/reports.dart';
import 'package:infertilityapp/results.dart';
import 'package:infertilityapp/semenanalysis.dart';
import 'package:infertilityapp/spouse.dart';
import 'package:infertilityapp/third_page.dart';
import 'package:infertilityapp/viewadvice2.dart';
import 'package:infertilityapp/viewstatus.dart';

class TwelfthPage extends StatefulWidget {
  final String userId;
  final String name;
  final int dayDifference;

  TwelfthPage(
      {required this.userId, required this.name, required this.dayDifference});

  @override
  _TwelfthPageState createState() => _TwelfthPageState();
}

class _TwelfthPageState extends State<TwelfthPage> {
  Map<String, dynamic>? patientDetails;
  List<Map<String, dynamic>>? medications;
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchPatientDetails();
    fetchMedications(widget.userId);
  }

  Future<void> fetchPatientDetails() async {
    try {
      final response = await http.post(
        Uri.parse(viewpatient),
        body: {'userId': widget.userId},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData is Map &&
            responseData['status'] == true &&
            responseData['patientDetails'] is Map) {
          setState(() {
            patientDetails =
                Map<String, dynamic>.from(responseData['patientDetails']);
            isLoading = false;
          });
        } else {
          setState(() {
            hasError = true;
            errorMessage = responseData is Map &&
                    responseData['message'] != null
                ? responseData['message'].toString()
                : 'No patient details found.';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          hasError = true;
          errorMessage = 'Server error. Please try again later.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = 'Error fetching data: $e';
        isLoading = false;
      });
    }
  }

  Future<void> fetchMedications(String userId) async {
    try {
      var response = await http.post(
        Uri.parse(viewmed),
        body: {'userid': userId},
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['status']) {
          List<Map<String, dynamic>> sortedMedications =
              List<Map<String, dynamic>>.from(jsonData['patientDetails']);
          sortedMedications.sort((a, b) => b['date'].compareTo(a['date']));
          setState(() {
            medications = sortedMedications.take(5).toList();
          });
        } else {
          print(jsonData['message']);
        }
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => FifthPage(
                      userId: widget.userId,
                      dayDifference: widget.dayDifference)),
              ModalRoute.withName('/'),
            );
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.ink),
        ),
        title: const Text('Patient Details'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              onPressed: () {
                _scaffoldKey.currentState?.openEndDrawer();
              },
              icon: const Icon(Icons.menu_rounded, color: AppColors.ink),
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            bottomLeft: Radius.circular(28),
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
              decoration: const BoxDecoration(gradient: kBrandGradient),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    child: const Icon(Icons.person_rounded,
                        color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _DrawerItem(
              icon: Icons.medication_outlined,
              title: 'Medications',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MedicationsPage(
                          userId: widget.userId,
                          name: widget.name,
                          dayDifference: widget.dayDifference)),
                );
              },
            ),
            _DrawerItem(
              icon: Icons.science_outlined,
              title: 'Spouse Reports',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SemenAnalysisPage(
                          userId: widget.userId,
                          name: widget.name,
                          dayDifference: widget.dayDifference)),
                );
              },
            ),
            _DrawerItem(
              icon: Icons.description_outlined,
              title: 'View Reports',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ReportsPage(
                          userId: widget.userId,
                          name: widget.name,
                          dayDifference: widget.dayDifference)),
                );
              },
            ),
            _DrawerItem(
              icon: Icons.insights_rounded,
              title: 'View Graph',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => GraphPage(
                          userId: widget.userId,
                          name: widget.name,
                          dayDifference: widget.dayDifference)),
                );
              },
            ),
            _DrawerItem(
              icon: Icons.people_alt_outlined,
              title: 'Spouse Details',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SpousePage(
                          userId: widget.userId, name: widget.name)),
                );
              },
            ),
            _DrawerItem(
              icon: Icons.fact_check_outlined,
              title: 'View Status',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ViewStatusPage(userId: widget.userId)),
                );
              },
            ),
            _DrawerItem(
              icon: Icons.tips_and_updates_outlined,
              title: 'View Advice',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ViewAdvicePage2(
                          userId: widget.userId,
                          name: widget.name,
                          dayDifference: widget.dayDifference)),
                );
              },
            ),
            _DrawerItem(
              icon: Icons.event_repeat_outlined,
              title: 'Cycle Update',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CyclePage(userId: widget.userId)),
                );
              },
            ),
            _DrawerItem(
              icon: Icons.calendar_month_outlined,
              title: 'View Results',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ResultsPage(userId: widget.userId)),
                );
              },
            ),
            const Divider(height: 28, indent: 20, endIndent: 20),
            _DrawerItem(
              icon: Icons.logout_rounded,
              title: 'Logout',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ThirdPage()),
                ); // Add logout logic here
              },
            ),
          ],
        ),
      ),
      body: AppBackground(
        decor: BgDecor.ekg,
        child: SafeArea(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary))
              : hasError
                  ? Center(
                      child: Text(errorMessage,
                          style: const TextStyle(color: AppColors.muted)))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 58,
                            backgroundColor: AppColors.surface,
                            backgroundImage: (patientDetails!['image'] !=
                                        null &&
                                    patientDetails!['image'].isNotEmpty)
                                ? NetworkImage(
                                    '$patientimage${patientDetails!['image']}')
                                : null,
                            onBackgroundImageError:
                                (patientDetails!['image'] != null &&
                                        patientDetails!['image'].isNotEmpty)
                                    ? (_, __) {}
                                    : null,
                            child: (patientDetails!['image'] == null ||
                                    patientDetails!['image'].isEmpty)
                                ? const Icon(Icons.person_rounded,
                                    size: 56, color: AppColors.primary)
                                : null,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                            ),
                          ),
                          Text(
                            'ID: ${widget.userId}',
                            style: const TextStyle(
                                fontSize: 14, color: AppColors.muted),
                          ),
                          const SizedBox(height: 22),
                          SectionCard(
                            title: 'Patient Details',
                            child: Column(
                              children: [
                                _DetailRow('Name', patientDetails!['Name']),
                                _DetailRow('Contact No',
                                    patientDetails!['ContactNo']),
                                _DetailRow('Age', patientDetails!['Age']),
                                _DetailRow('Gender', patientDetails!['Gender']),
                                _DetailRow('Height', patientDetails!['Height']),
                                _DetailRow('Weight', patientDetails!['Weight']),
                                _DetailRow('Marriage Year',
                                    patientDetails!['Marriageyear']),
                                _DetailRow('Blood Group',
                                    patientDetails!['Bloodgroup']),
                                _DetailRow('Occupation',
                                    patientDetails!['occupation']),
                                _DetailRow('BMI', patientDetails!['BMI']),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          SectionCard(
                            title: 'Medical History',
                            child: Column(
                              children: [
                                _DetailRow('Medical History',
                                    patientDetails!['Medicalhistory']),
                                _DetailRow('Specification',
                                    patientDetails!['Specifications']),
                                _DetailRow('Contraceptive History',
                                    patientDetails!['contraceptive_history']),
                                _DetailRow('Last Menstrual Period',
                                    patientDetails!['last_menstrual_period']),
                                _DetailRow('Menstrual History',
                                    patientDetails!['menstrual_history']),
                                _DetailRow('Flow', patientDetails!['flow']),
                                _DetailRow('Consanguineous',
                                    patientDetails!['consanguineous']),
                                _DetailRow('Coital History',
                                    patientDetails!['coital_history']),
                                _DetailRow('Obstetric History',
                                    patientDetails!['obstetric_history']),
                                _DetailRow('Surgical History',
                                    patientDetails!['surgical_history']),
                                _DetailRow(
                                    'Smoking', patientDetails!['smoking']),
                                _DetailRow(
                                    'Alcohol', patientDetails!['alcohol']),
                              ],
                            ),
                          ),
                          if (medications != null &&
                              medications!.isNotEmpty) ...[
                            const SizedBox(height: 18),
                            SectionCard(
                              title: 'Medications',
                              child: Column(
                                children: medications!
                                    .map((medication) =>
                                        _MedicationTile(medication))
                                    .toList(),
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerItem(
      {required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 24),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      onTap: onTap,
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String? value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.muted,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              (value != null && value!.trim().isNotEmpty) ? value! : '—',
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicationTile extends StatelessWidget {
  final Map<String, dynamic> medication;

  const _MedicationTile(this.medication);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.medication_outlined,
                color: AppColors.primary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${medication['Medication']}',
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  Text(
                    '${medication['date']}',
                    style: const TextStyle(
                        fontSize: 12.5, color: AppColors.muted),
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
