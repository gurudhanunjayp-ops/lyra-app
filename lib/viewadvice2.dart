import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infertilityapp/app_ui.dart';
import 'package:infertilityapp/comman.dart';

class ViewAdvicePage2 extends StatefulWidget {
  final String userId;
  final String name;
  final int dayDifference;

  ViewAdvicePage2(
      {required this.userId, required this.name, required this.dayDifference});

  @override
  _ViewAdvicePage2State createState() => _ViewAdvicePage2State();
}

class _ViewAdvicePage2State extends State<ViewAdvicePage2> {
  late List<Map<String, dynamic>> advices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDataFromApi();
  }

  Future<void> fetchDataFromApi() async {
    final url = Uri.parse(viewadvice);
    final response = await http.post(url, body: {
      'userid': widget.userId,
    });

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        if (jsonData['viewadvices'] != null) {
          final allAdvices =
              List<Map<String, dynamic>>.from(jsonData['viewadvices']);
          // Sort advices based on date (assuming 'Date' is a timestamp)
          allAdvices.sort((a, b) => b['Date'].compareTo(a['Date']));
          // Take only the latest 5 advices
          advices = allAdvices.take(5).toList();
        }
        _isLoading = false;
      });
    } else {
      print('Failed to fetch data: ${response.statusCode}');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'View Advices',
      decor: BgDecor.hearts,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : advices.isEmpty
              ? const Center(
                  child: Text(
                    'No advices yet',
                    style: TextStyle(color: AppColors.muted, fontSize: 15),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: advices.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: SectionCard(
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
                                  '${advices[index]['Date']}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${advices[index]['Addadvices']}',
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.5,
                                color: AppColors.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
