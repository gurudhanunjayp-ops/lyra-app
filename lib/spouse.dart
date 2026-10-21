import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:infertilityapp/app_ui.dart';
import 'package:infertilityapp/comman.dart';

class SpousePage extends StatefulWidget {
  final String userId;
  final String name;

  SpousePage({required this.userId, required this.name});

  @override
  _SpousePageState createState() => _SpousePageState();
}

class _SpousePageState extends State<SpousePage> {
  Map<String, dynamic>? spouseDetails;
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchSpouseDetails();
  }

  Future<void> fetchSpouseDetails() async {
    try {
      var response = await http.post(
        Uri.parse(viewspouse),
        body: {'userid': widget.userId},
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['status']) {
          setState(() {
            spouseDetails = jsonData['spouseDetails'] is Map
                ? Map<String, dynamic>.from(jsonData['spouseDetails'])
                : (jsonData['spouseDetails'] is List &&
                        (jsonData['spouseDetails'] as List).isNotEmpty
                    ? Map<String, dynamic>.from(jsonData['spouseDetails'][0])
                    : null);
            isLoading = false;
          });
        } else {
          setState(() {
            hasError = true;
            errorMessage = jsonData['message'];
            isLoading = false;
          });
        }
      } else {
        setState(() {
          hasError = true;
          errorMessage =
              'Failed to load spouse details. Please try again later.';
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

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Spouse Details',
      decor: BgDecor.hearts,
      body: isLoading
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
                      SectionCard(
                        title: 'Spouse Details',
                        child: Column(
                          children: [
                            _DetailTile(
                                icon: Icons.person_outline_rounded,
                                label: 'Name',
                                value: spouseDetails!['Name']),
                            _DetailTile(
                                icon: Icons.phone_outlined,
                                label: 'Contact Number',
                                value: spouseDetails!['Contactnumber']),
                            _DetailTile(
                                icon: Icons.work_outline_rounded,
                                label: 'Occupation',
                                value: spouseDetails!['occupation']),
                            _DetailTile(
                                icon: Icons.cake_outlined,
                                label: 'Age',
                                value: spouseDetails!['Age']),
                            _DetailTile(
                                icon: Icons.history_edu_outlined,
                                label: 'Significant History',
                                value:
                                    spouseDetails!['significanthistory']),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      SectionCard(
                        title: 'Personal History',
                        child: Column(
                          children: [
                            _DetailTile(
                                icon: Icons.smoking_rooms_outlined,
                                label: 'Smoking',
                                value: spouseDetails!['smoking']),
                            _DetailTile(
                                icon: Icons.local_bar_outlined,
                                label: 'Alcohol',
                                value: spouseDetails!['alcohol']),
                            _DetailTile(
                                icon: Icons.health_and_safety_outlined,
                                label: 'Sexual Dysfunction',
                                value:
                                    spouseDetails!['sexualdisfunction']),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      SectionCard(
                        title: 'Semen Analysis',
                        child: Column(
                          children: [
                            _DetailTile(
                                label: 'Volume (ml)',
                                value: spouseDetails!['Volume']),
                            _DetailTile(
                                label: 'Concentration (million/ml)',
                                value: spouseDetails!['Concentration']),
                            _DetailTile(
                                label: 'Total sperm number (million)',
                                value:
                                    spouseDetails!['Total_sperm_number']),
                            _DetailTile(
                                label: 'Motility (%)',
                                value: spouseDetails!['Motility']),
                            _DetailTile(
                                label: 'Progressive Motility (%)',
                                value: spouseDetails![
                                    'Progressive_Motility']),
                            _DetailTile(
                                label: 'Morphology (%)',
                                value: spouseDetails!['Morphology']),
                            _DetailTile(
                                label: 'Viability (%)',
                                value: spouseDetails!['Viability']),
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

class _DetailTile extends StatelessWidget {
  final IconData? icon;
  final String label;
  final String? value;

  const _DetailTile({this.icon, required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 10),
          ],
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
