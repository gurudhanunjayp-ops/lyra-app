import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infertilityapp/app_ui.dart';
import 'package:infertilityapp/comman.dart';

class PMedicationPage extends StatefulWidget {
  final String userId;
  PMedicationPage({required this.userId});

  @override
  _PMedicationPageState createState() => _PMedicationPageState();
}

class _PMedicationPageState extends State<PMedicationPage> {
  List<Map<String, dynamic>> medicationDetails = [];
  bool _isLoading = true;

  // Function to fetch medication details from the server
  Future<void> fetchMedicationDetails(String userId) async {
    final response = await http.post(
      Uri.parse(viewmed),
      body: {'userid': userId},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status']) {
        // Sort the medication details by date
        List<Map<String, dynamic>> sortedMedications =
            List<Map<String, dynamic>>.from(data['patientDetails']);
        sortedMedications.sort((a, b) => b['date'].compareTo(a['date']));
        // Take only the latest 5 medication details
        setState(() {
          medicationDetails = sortedMedications.take(5).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text(data['message']),
              actions: <Widget>[
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
    } else {
      setState(() => _isLoading = false);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to fetch medication details'),
            actions: <Widget>[
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
  }

  @override
  void initState() {
    super.initState();
    fetchMedicationDetails(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'My Medications',
      decor: BgDecor.crosses,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : medicationDetails.isEmpty
              ? const Center(
                  child: Text(
                    'No medications found',
                    style: TextStyle(color: AppColors.muted, fontSize: 15),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: medicationDetails.length,
                  itemBuilder: (context, index) {
                    // Access medication details using medicationDetails[index]
                    var medication = medicationDetails[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: SectionCard(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const IconBadge(
                                  icon: Icons.medication_outlined,
                                  size: 40,
                                  iconSize: 22,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    '${medication['Medication']}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${medication['date']}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 22),
                            _MedRow(Icons.alt_route_rounded, 'Route',
                                '${medication['Route']}'),
                            _MedRow(Icons.vaccines_outlined, 'Dosage',
                                '${medication['Dosage']}'),
                            _MedRow(Icons.schedule_outlined, 'Timing',
                                '${medication['Time']}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class _MedRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MedRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: AppColors.muted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14.5,
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
