import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infertilityapp/app_ui.dart';
import 'package:infertilityapp/comman.dart';
import 'package:infertilityapp/viewadvice2.dart';
import 'package:intl/intl.dart';

class AdvicePage extends StatelessWidget {
  final String userId;
  final String name;
  final int dayDifference;

  AdvicePage(
      {required this.userId, required this.name, required this.dayDifference});

  final TextEditingController _adviceController = TextEditingController();

  Future<void> _addAdvice(BuildContext context) async {
    // Get the current date
    DateTime now = DateTime.now();
    String formattedDate = "${now.year}-${now.month}-${now.day}";

    // Get the entered advice
    String advice = _adviceController.text;

    // Send data to the PHP backend script
    final response = await http.post(
      Uri.parse(addadvice),
      body: {
        'userid': userId,
        'date': formattedDate,
        'addadvice': advice,
      },
    );

    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      // Successful request
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text("Your advice is added successfully"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ViewAdvicePage2(
                            userId: userId,
                            name: name,
                            dayDifference: dayDifference)),
                  );
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    } else {
      // Request failed
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text("Failed to add advice. Please try again later."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Dismiss the dialog
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
      title: 'Add Advice',
      decor: BgDecor.hearts,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 8),
            const GradientIconBadge(
              icon: Icons.tips_and_updates_outlined,
              size: 76,
              iconSize: 38,
            ),
            const SizedBox(height: 20),
            SectionCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.event_outlined,
                          size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('dd MMM yyyy').format(DateTime.now()),
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _adviceController,
                    maxLines: 10,
                    textAlign: TextAlign.start,
                    style:
                        const TextStyle(fontSize: 15.5, color: AppColors.ink),
                    decoration: const InputDecoration(
                      hintText: 'Write your advice here...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Add Advice',
              icon: Icons.add_rounded,
              onPressed: () => _addAdvice(context),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
