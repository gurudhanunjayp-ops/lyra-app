import 'package:flutter/material.dart';
import 'package:infertilityapp/app_ui.dart';
import 'package:infertilityapp/comman.dart';
import 'fifth_page.dart';
import 'ninth_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EightPage extends StatefulWidget {
  final String userId;
  final int dayDifference;

  EightPage({required this.userId, required this.dayDifference});

  @override
  _EightPageState createState() => _EightPageState();
}

class _EightPageState extends State<EightPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactNoController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _significanthistoryController =
      TextEditingController();
  String smoking = '';
  String alcohol = '';
  String sexualdisfunction = '';

  Future<void> sendDataToBackend() async {
    var url = addspouse;
    var response = await http.post(Uri.parse(url), body: {
      'userid': widget.userId,
      'name': _nameController.text,
      'contactno': _contactNoController.text,
      'age': _ageController.text,
      'occupation': _occupationController.text,
      'significanthistory': _significanthistoryController.text,
      'smoking': smoking,
      'alcohol': alcohol,
      'sexualdisfunction': sexualdisfunction,
    });

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['status']) {
        // Data successfully sent to backend
        // Show dialog when NEXT is tapped
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                'Previous treatment?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              content: const Text(
                'Have you undergone this treatment before?',
                style: TextStyle(fontSize: 14.5),
              ),
              actions: [
                TextButton(
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
                  child: const Text('No'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NinthPage(
                              userId: widget.userId,
                              dayDifference: widget.dayDifference)),
                    );
                  },
                  child: const Text('Yes'),
                ),
              ],
            );
          },
        );
      } else {
        // Error occurred
        // Show error message
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
      // Error occurred
      // Show error message
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

  void _setSmoking(String value) {
    setState(() {
      smoking = value;
    });
  }

  void _setAlcohol(String value) {
    setState(() {
      alcohol = value;
    });
  }

  void _setSexualDisfunction(String value) {
    setState(() {
      sexualdisfunction = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Add Spouse',
      decor: BgDecor.hearts,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SectionCard(
              title: 'Spouse Details',
              child: Column(
                children: [
                  AppTextField(
                    label: 'Name',
                    hint: 'Full name',
                    icon: Icons.person_outline_rounded,
                    controller: _nameController,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Contact Number',
                    hint: 'Phone number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    controller: _contactNoController,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'Age',
                          hint: 'Age',
                          icon: Icons.cake_outlined,
                          keyboardType: TextInputType.number,
                          controller: _ageController,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: AppTextField(
                          label: 'Occupation',
                          hint: 'Occupation',
                          icon: Icons.work_outline_rounded,
                          controller: _occupationController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Significant History',
                    hint: 'Any relevant history',
                    icon: Icons.history_edu_outlined,
                    controller: _significanthistoryController,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SectionCard(
              title: 'Personal History',
              child: Column(
                children: [
                  YesNoField(
                    label: 'Smoking',
                    value: smoking.isEmpty ? null : smoking,
                    onChanged: _setSmoking,
                  ),
                  const SizedBox(height: 16),
                  YesNoField(
                    label: 'Alcohol',
                    value: alcohol.isEmpty ? null : alcohol,
                    onChanged: _setAlcohol,
                  ),
                  const SizedBox(height: 16),
                  YesNoField(
                    label: 'Sexual Dysfunction',
                    value:
                        sexualdisfunction.isEmpty ? null : sexualdisfunction,
                    onChanged: _setSexualDisfunction,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            PrimaryButton(
              label: 'Next',
              icon: Icons.arrow_forward_rounded,
              onPressed: sendDataToBackend,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
