import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:infertilityapp/app_ui.dart';
import 'comman.dart';

class ResultsPage extends StatefulWidget {
  final String userId;
  ResultsPage({required this.userId});

  @override
  _ResultsPageState createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  List<String> dates = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDates();
  }

  Future<void> _fetchDates() async {
    final response = await http.post(
      Uri.parse(fetchperioddate), // Replace with your actual URL
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userid': widget.userId,
        'userId': widget.userId,
        'Userid': widget.userId,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data.containsKey('dates')) {
        setState(() {
          dates = List<String>.from(data['dates']);
          dates.sort(
              (a, b) => b.compareTo(a)); // Sort dates in descending order
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Period History',
      decor: BgDecor.waves,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : dates.isEmpty
              ? const Center(
                  child: Text(
                    'No records found',
                    style: TextStyle(color: AppColors.muted, fontSize: 15),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: dates.length,
                  itemBuilder: (context, index) {
                    return ListCard(
                      icon: Icons.calendar_month_outlined,
                      title: dates[index],
                      subtitle: 'Recorded period date',
                    );
                  },
                ),
    );
  }
}
