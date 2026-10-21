import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:infertilityapp/app_ui.dart';
import 'comman.dart';
import 'package:intl/intl.dart';

class CyclePage extends StatefulWidget {
  final String userId; // Define userId variable

  CyclePage({Key? key, required this.userId})
      : super(key: key); // Accept userId as a parameter

  @override
  _CyclePageState createState() => _CyclePageState();
}

class _CyclePageState extends State<CyclePage> {
  DateTime? _selectedDate;
  int _dayCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchSavedDate();
  }

  Future<void> _fetchSavedDate() async {
    final url = fetchdate;
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({'userId': widget.userId});

    print('Request URL: $url'); // Debugging
    print('Request Headers: $headers'); // Debugging
    print('Request Body: $body'); // Debugging

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    print('Response Status: ${response.statusCode}'); // Debugging
    print('Response Body: ${response.body}'); // Debugging

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print('Response Data: $responseData'); // Debugging

      if (responseData['selectedDate'] != null) {
        setState(() {
          _selectedDate = DateTime.parse(responseData['selectedDate']);
          _calculateDayCount();
        });
      }
    } else {
      print('Failed to load date from backend');
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

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Cycle Update',
      decor: BgDecor.waves,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: SectionCard(
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const GradientIconBadge(
                  icon: Icons.event_repeat_rounded,
                  size: 76,
                  iconSize: 38,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Patient on cycle',
                  style: TextStyle(fontSize: 15, color: AppColors.muted),
                ),
                const SizedBox(height: 18),
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: kBrandGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 108,
                      height: 108,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'DAY',
                            style: TextStyle(
                              fontSize: 12,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.muted,
                            ),
                          ),
                          Text(
                            '$_dayCount',
                            style: const TextStyle(
                              fontSize: 40,
                              height: 1.05,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                if (_selectedDate != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Started ${DateFormat.yMMMd().format(_selectedDate!)}',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
