import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:infertilityapp/app_ui.dart';

class UpdateDate extends StatefulWidget {
  final String userId;

  const UpdateDate({super.key, required this.userId});

  @override
  _UpdateDatePageState createState() => _UpdateDatePageState();
}

class _UpdateDatePageState extends State<UpdateDate> {
  DateTime? _selectedDate;
  int _dayCount = 1;

  @override
  void initState() {
    super.initState();
    _fetchSavedDate();
  }

  Future<void> _fetchSavedDate() async {
    final url = 'http://192.168.40.27:80/infertility/fetchdate.php';
    const headers = {'Content-Type': 'application/json'};
    final body = json.encode({'userId': widget.userId});

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      if (responseData['selectedDate'] != null) {
        setState(() {
          _selectedDate = DateTime.parse(responseData['selectedDate']);
          _calculateDayCount();
        });
      }
    }
  }

  void _calculateDayCount() {
    if (_selectedDate != null) {
      final now = DateTime.now();
      final difference = now.difference(_selectedDate!).inDays;
      setState(() {
        _dayCount = difference + 1;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _calculateDayCount(); // Update day count immediately
        _saveDate(pickedDate);
      });
    }
  }

  Future<void> _saveDate(DateTime date) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('selected_date', date.toIso8601String());

    await http.post(
      Uri.parse('http://192.168.40.27:80/infertility/save_date.php'),
      headers: const {'Content-Type': 'application/json'},
      body: json.encode(
          {'userId': widget.userId, 'selectedDate': date.toIso8601String()}),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      decor: BgDecor.waves,
      title: 'Period Tracker',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 8),
            const GradientIconBadge(
              icon: Icons.calendar_month_rounded,
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
                    '$_dayCount',
                    style: const TextStyle(
                      fontSize: 46,
                      height: 1.05,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.event_outlined,
                            size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          _selectedDate == null
                              ? 'No date selected'
                              : DateFormat.yMMMd().format(_selectedDate!),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  PrimaryButton(
                    label: 'Select Date',
                    icon: Icons.calendar_month_rounded,
                    onPressed: () => _selectDate(context),
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
