import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infertilityapp/app_ui.dart';
import 'package:infertilityapp/twelfth_page.dart';
import 'package:intl/intl.dart';
import 'comman.dart';

class MedicationsPage extends StatelessWidget {
  final String userId;
  final String name;
  final int dayDifference;

  MedicationsPage(
      {required this.userId, required this.name, required this.dayDifference});

  @override
  Widget build(BuildContext context) {
    TextEditingController medicationController = TextEditingController();
    TextEditingController timeController = TextEditingController();
    TextEditingController dosageController = TextEditingController();
    TextEditingController routeController =
        TextEditingController(); // New controller for Route

    Future<void> sendDataToBackend(BuildContext context) async {
      String medication = medicationController.text;
      String time = timeController.text;
      String dosage = dosageController.text;
      String route = routeController.text; // Retrieve route from text field
      String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final url = medications;

      try {
        final response = await http.post(
          Uri.parse(url),
          body: {
            'userId': userId,
            'medication': medication,
            'time': time,
            'dosage': dosage,
            'route': route, // Include route in the POST request
            'date': currentDate,
          },
        );

        if (response.statusCode == 200) {
          // Successful HTTP POST request
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TwelfthPage(
                    userId: userId,
                    name: name,
                    dayDifference: dayDifference)),
          );
        } else {
          // HTTP request failed
          throw Exception('Failed to save medication details');
        }
      } catch (e) {
        // Error handling
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text("Failed to save medication details"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      }
    }

    return PageScaffold(
      title: 'Medications',
      decor: BgDecor.crosses,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                gradient: kBrandGradient,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Date',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    DateFormat('dd-MM-yyyy').format(DateTime.now()),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SectionCard(
              child: Column(
                children: [
                  AppDropdown<String>(
                    label: 'Medication',
                    icon: Icons.medication_outlined,
                    items: const [
                      'CLOMIPHENE CITRATE',
                      'LETROZOLE',
                      'TAMOXIFEN',
                      'MICRONISED',
                      'METFORMIN',
                      'HCG',
                      'HMG',
                      'PROLUTON',
                    ]
                        .map((m) =>
                            DropdownMenuItem<String>(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (String? value) {
                      medicationController.text = value ?? '';
                      print('Selected Medication: $value');
                    },
                  ),
                  const SizedBox(height: 16),
                  AppDropdown<String>(
                    label: 'Route',
                    icon: Icons.alt_route_rounded,
                    items: const ['Oral', 'Injection']
                        .map((r) =>
                            DropdownMenuItem<String>(value: r, child: Text(r)))
                        .toList(),
                    onChanged: (String? value) {
                      routeController.text = value ?? '';
                      print('Selected Route: $value');
                    },
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Time',
                    hint: 'e.g. Morning / Night',
                    icon: Icons.schedule_outlined,
                    controller: timeController,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Dosage',
                    hint: 'e.g. 50mg',
                    icon: Icons.vaccines_outlined,
                    controller: dosageController,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            PrimaryButton(
              label: 'Next',
              icon: Icons.arrow_forward_rounded,
              onPressed: () => sendDataToBackend(context),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
