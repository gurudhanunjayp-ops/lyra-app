import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:infertilityapp/app_ui.dart';

class PeriodTrackerHomePage extends StatefulWidget {
  final String userId;

  const PeriodTrackerHomePage({super.key, required this.userId});

  @override
  _PeriodTrackerHomePageState createState() => _PeriodTrackerHomePageState();
}

class _PeriodTrackerHomePageState extends State<PeriodTrackerHomePage> {
  DateTime? selectedDate;
  int? dayDifference;
  DateTime? fertileStartDate;
  DateTime? fertileEndDate;

  @override
  void initState() {
    super.initState();
    // Fetch saved period start date and fertile period from backend
    fetchPeriodData();
  }

  Future<void> fetchPeriodData() async {
    try {
      final response = await http.get(Uri.parse(
          'http://192.168.40.27:80/infertility/get_period.php?userid=${widget.userId}'));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          selectedDate = DateTime.parse(data['date']);
          dayDifference = DateTime.now().difference(selectedDate!).inDays + 1;
          if (data['fertileStart'] != null && data['fertileEnd'] != null) {
            fertileStartDate = DateTime.parse(data['fertileStart']);
            fertileEndDate = DateTime.parse(data['fertileEnd']);
          } else {
            fertileStartDate = null;
            fertileEndDate = null;
          }
        });
        // Check fertile period if necessary
        checkFertilePeriod();
      }
    } catch (e) {
      // Handle network or other errors
    }
  }

  Future<void> savePeriodData(DateTime selectedDate, int days) async {
    try {
      // Calculate fertile period (typically day 14 to day 18)
      fertileStartDate = selectedDate.add(const Duration(days: 14));
      fertileEndDate = selectedDate.add(const Duration(days: 18));

      await http.post(
        Uri.parse('http://192.168.40.27:80/infertility/save_period.php'),
        body: {
          'userid': widget.userId,
          'date': DateFormat('yyyy-MM-dd').format(selectedDate),
          'days': days.toString(),
          'fertileStart': DateFormat('yyyy-MM-dd').format(fertileStartDate!),
          'fertileEnd': DateFormat('yyyy-MM-dd').format(fertileEndDate!),
        },
      );
    } catch (e) {
      // Handle network or other errors
    }
  }

  void checkFertilePeriod() {
    if (selectedDate != null &&
        fertileStartDate != null &&
        fertileEndDate != null) {
      DateTime currentDate = DateTime.now();
      if (currentDate.isAfter(fertileStartDate!) &&
          currentDate.isBefore(fertileEndDate!)) {
        // Show fertile period notification
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _showFertilePeriodNotification();
        });
      }
    }
  }

  void _showFertilePeriodNotification() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Fertile Period'),
          content: const Text('You are in your fertile period.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasData = selectedDate != null &&
        dayDifference != null &&
        fertileStartDate != null &&
        fertileEndDate != null;

    return PageScaffold(
      decor: BgDecor.hearts,
      title: 'Period Tracker',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 8),
            const GradientIconBadge(
              icon: Icons.water_drop_rounded,
              size: 84,
              iconSize: 42,
            ),
            const SizedBox(height: 18),
            SectionCard(
              child: Column(
                children: [
                  const Text(
                    'Current cycle day',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${dayDifference ?? 0}',
                    style: const TextStyle(
                      fontSize: 46,
                      height: 1.05,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Divider(height: 1),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Icon(Icons.spa_outlined,
                          size: 20, color: AppColors.primary),
                      const SizedBox(width: 10),
                      const Text(
                        'Fertile period',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      hasData
                          ? 'From ${DateFormat('dd MMM yyyy').format(fertileStartDate!)} to ${DateFormat('dd MMM yyyy').format(fertileEndDate!)}'
                          : 'Fertile period not available',
                      style: const TextStyle(
                        fontSize: 14.5,
                        color: AppColors.muted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            PrimaryButton(
              label: 'Edit Period Date',
              icon: Icons.edit_calendar_rounded,
              onPressed: () async {
                final DateTime? picked = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditPeriodDatePage(),
                  ),
                );
                if (picked != null) {
                  updateSelectedDate(picked);
                }
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void updateSelectedDate(DateTime date) async {
    setState(() {
      selectedDate = date;
      dayDifference = DateTime.now().difference(selectedDate!).inDays + 1;
    });

    // Save selected date, days, and fertile period to backend
    await savePeriodData(selectedDate!, dayDifference!);
  }
}

class EditPeriodDatePage extends StatefulWidget {
  const EditPeriodDatePage({super.key});

  @override
  _EditPeriodDatePageState createState() => _EditPeriodDatePageState();
}

class _EditPeriodDatePageState extends State<EditPeriodDatePage> {
  DateTime selectedDate = DateTime.now();

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      decor: BgDecor.hearts,
      title: 'Select Period Start Date',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 8),
            const GradientIconBadge(
              icon: Icons.event_available_rounded,
              size: 84,
              iconSize: 42,
            ),
            const SizedBox(height: 14),
            const Text(
              'Choose the first day of your period',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.5, color: AppColors.muted),
            ),
            const SizedBox(height: 26),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Period start date',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _pickDate,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFC9E8E2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded,
                              size: 20, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              DateFormat('dd MMM yyyy').format(selectedDate),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                          const Icon(Icons.expand_more_rounded,
                              color: AppColors.muted),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  PrimaryButton(
                    label: 'Save',
                    icon: Icons.check_rounded,
                    onPressed: () => Navigator.pop(context, selectedDate),
                  ),
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
