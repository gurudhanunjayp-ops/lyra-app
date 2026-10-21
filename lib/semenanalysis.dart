import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:infertilityapp/app_ui.dart';
import 'package:infertilityapp/comman.dart';
import 'package:infertilityapp/twelfth_page.dart';

class SemenAnalysisPage extends StatefulWidget {
  final String userId;
  final String name;
  final int dayDifference;

  SemenAnalysisPage(
      {required this.userId, required this.name, required this.dayDifference});

  @override
  _SemenAnalysisPageState createState() => _SemenAnalysisPageState();
}

class _SemenAnalysisPageState extends State<SemenAnalysisPage> {
  final TextEditingController _volumeController = TextEditingController();
  final TextEditingController _concentrationController =
      TextEditingController();
  final TextEditingController _totalSpermNumberController =
      TextEditingController();
  final TextEditingController _motilityController = TextEditingController();
  final TextEditingController _progressiveMotilityController =
      TextEditingController();
  final TextEditingController _morphologyController = TextEditingController();
  final TextEditingController _viabilityController = TextEditingController();

  Future<void> sendSemenDataToBackend() async {
    var url = addspouse;
    var response = await http.post(Uri.parse(url), body: {
      'userid': widget.userId,
      'Volume': _volumeController.text,
      'Concentration': _concentrationController.text,
      'Total_sperm_number': _totalSpermNumberController.text,
      'Motility': _motilityController.text,
      'Progressive_Motility': _progressiveMotilityController.text,
      'Morphology': _morphologyController.text,
      'Viability': _viabilityController.text,
    });

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['status']) {
        // Handle successful response
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Success'),
              content: Text('Data submitted successfully'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TwelfthPage(
                              userId: widget.userId,
                              name: widget.name,
                              dayDifference: widget.dayDifference)),
                    );
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        // Handle error response
        showDialog(
          context: context,
          builder: (BuildContext context) {
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
      // Handle server error
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(
                'Failed to connect to the server. Please try again later.'),
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
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Semen Analysis',
      decor: BgDecor.dots,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SectionCard(
              title: 'Enter Results',
              child: Column(
                children: [
                  AppTextField(
                    label: 'Volume (ml)',
                    icon: Icons.science_outlined,
                    keyboardType: TextInputType.number,
                    controller: _volumeController,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Concentration (million/ml)',
                    icon: Icons.science_outlined,
                    keyboardType: TextInputType.number,
                    controller: _concentrationController,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Total Sperm Number (million)',
                    icon: Icons.science_outlined,
                    keyboardType: TextInputType.number,
                    controller: _totalSpermNumberController,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Motility (%)',
                    icon: Icons.science_outlined,
                    keyboardType: TextInputType.number,
                    controller: _motilityController,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Progressive Motility (%)',
                    icon: Icons.science_outlined,
                    keyboardType: TextInputType.number,
                    controller: _progressiveMotilityController,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Morphology (%)',
                    icon: Icons.science_outlined,
                    keyboardType: TextInputType.number,
                    controller: _morphologyController,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Viability (%)',
                    icon: Icons.science_outlined,
                    keyboardType: TextInputType.number,
                    controller: _viabilityController,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Submit',
              icon: Icons.check_rounded,
              onPressed: sendSemenDataToBackend,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
