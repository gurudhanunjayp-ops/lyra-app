import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infertilityapp/app_ui.dart';
import 'fifth_page.dart';
import 'comman.dart';

class NinthPage extends StatelessWidget {
  final String userId;
  final int dayDifference;

  NinthPage({required this.userId, required this.dayDifference});

  TextEditingController _specificationsController = TextEditingController();

  Future<void> _saveSpecifications(BuildContext context) async {
    // Get the entered specifications
    String specifications = _specificationsController.text;

    // Prepare the POST request body
    Map<String, String> requestBody = {
      'userid': userId,
      'Specifications': specifications,
    };

    // Send the POST request
    http.Response response = await http.post(
      Uri.parse(speci),
      body: requestBody,
    );

    // Parse the response JSON
    Map<String, dynamic> responseData = json.decode(response.body);

    if (responseData['status'] == true) {
      // Show success dialog if the specifications were saved successfully
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Success"),
            content: Text("Your specifications were added successfully."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FifthPage(
                            userId: userId, dayDifference: dayDifference)),
                  );
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    } else {
      // Show error dialog if there was an error saving the specifications
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text(responseData['message']),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
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
      title: 'Specifications',
      decor: BgDecor.dots,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 8),
            const GradientIconBadge(
              icon: Icons.assignment_outlined,
              size: 76,
              iconSize: 38,
            ),
            const SizedBox(height: 14),
            const Text(
              'Add treatment specifications\nfor this patient',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.4,
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 22),
            SectionCard(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _specificationsController,
                maxLines: 10,
                textAlign: TextAlign.start,
                style: const TextStyle(fontSize: 15.5, color: AppColors.ink),
                decoration: const InputDecoration(
                  hintText: 'Enter specifications here...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Save',
              icon: Icons.check_rounded,
              onPressed: () => _saveSpecifications(context),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
