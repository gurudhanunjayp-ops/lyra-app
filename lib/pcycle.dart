import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:infertilityapp/app_ui.dart';

class PCyclePage extends StatefulWidget {
  final String userId;
  final String name;

  PCyclePage({super.key, required this.userId, required this.name});

  @override
  _PCyclePageState createState() => _PCyclePageState();
}

class _PCyclePageState extends State<PCyclePage> {
  DateTime? _selectedDate;
  int _dayDifference = 0;

  @override
  void initState() {
    super.initState();
    _fetchInitialDate();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _calculateDayDifference();
  }

  void _fetchInitialDate() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.40.27:80/infertility/updatecycle.php'),
        body: {
          'userid': widget.userId,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          setState(() {
            _selectedDate = DateTime.parse(data['initial_date']);
          });
        } else {
          // Handle error if initial date not fetched
        }
      } else {
        // Handle HTTP error
      }
    } catch (error) {
      // Handle network or other errors
    }
  }

  void _updateCycleDate(int dayDifference) async {
    if (_selectedDate != null) {
      try {
        final response = await http.post(
          Uri.parse('http://192.168.40.27:80/infertility/updatedate.php'),
          body: {
            'userid': widget.userId,
            'updatedate': DateFormat('yyyy-MM-dd').format(_selectedDate!),
            'dayDifference': dayDifference.toString(),
          },
        );

        // Handle response...
        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          if (responseData['status'] == true) {
            _updateDayDifference(dayDifference);
          }
        }
      } catch (error) {
        // Handle network or other errors
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: const Text("Please select a date."),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  void _updateDayDifference(int dayDifference) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.40.27:80/infertility/daydifference.php'),
        body: {
          'userid': widget.userId,
          'dayDifference': dayDifference.toString(),
        },
      );

      // Handle response...
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == true) {
          // Pass dayDifference back to previous page
          if (mounted) Navigator.pop(context, dayDifference);
        }
      }
    } catch (error) {
      // Handle network or other errors
    }
  }

  void _calculateDayDifference() {
    if (_selectedDate != null) {
      DateTime now = DateTime.now();
      DateTime selectedDay = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
      );

      int differenceInDays = now.difference(selectedDay).inDays;
      differenceInDays += 1;

      setState(() {
        _dayDifference = differenceInDays;
      });
    }
  }

  Future<void> _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
      _calculateDayDifference();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      decor: BgDecor.dots,
      title: 'Cycle Update',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 8),
            const GradientIconBadge(
              icon: Icons.event_repeat_rounded,
              size: 84,
              iconSize: 42,
            ),
            const SizedBox(height: 14),
            const Text(
              'Update the first day of your current cycle',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.5, color: AppColors.muted),
            ),
            const SizedBox(height: 26),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cycle start date',
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
                              _selectedDate != null
                                  ? DateFormat('dd MMM yyyy')
                                      .format(_selectedDate!)
                                  : 'Select first day of your cycle',
                              style: TextStyle(
                                fontSize: 15,
                                color: _selectedDate != null
                                    ? AppColors.ink
                                    : AppColors.muted,
                                fontWeight: _selectedDate != null
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                          const Icon(Icons.expand_more_rounded,
                              color: AppColors.muted),
                        ],
                      ),
                    ),
                  ),
                  if (_selectedDate != null) ...[
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.timelapse_rounded,
                              size: 20, color: AppColors.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Cycle day $_dayDifference',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 26),
                  PrimaryButton(
                    label: 'Save',
                    icon: Icons.check_rounded,
                    onPressed: () => _updateCycleDate(_dayDifference),
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
