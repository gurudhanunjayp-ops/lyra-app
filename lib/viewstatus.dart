import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infertilityapp/app_ui.dart';
import 'comman.dart';

class ViewStatusPage extends StatefulWidget {
  final String userId;

  ViewStatusPage({required this.userId});

  @override
  _ViewStatusPageState createState() => _ViewStatusPageState();
}

class _ViewStatusPageState extends State<ViewStatusPage> {
  List<Map<String, dynamic>> statusList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDataFromDatabase(widget.userId);
  }

  Future<void> fetchDataFromDatabase(String userId) async {
    final url = viewstatus;

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {'userid': userId},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status']) {
          List<Map<String, dynamic>> sortedStatusList =
              List<Map<String, dynamic>>.from(responseData['viewreport']);
          sortedStatusList.sort((a, b) => b['date']
              .compareTo(a['date'])); // Sort by date in descending order
          setState(() {
            statusList =
                sortedStatusList.take(5).toList(); // Take the first 5 elements
            _isLoading = false;
          });
        } else {
          // Handle error if no data found
          print(responseData['message']);
          setState(() => _isLoading = false);
        }
      } else {
        // Handle HTTP error
        print('Failed to fetch data: ${response.statusCode}');
        setState(() => _isLoading = false);
      }
    } catch (error) {
      // Handle other errors
      print('Error fetching data: $error');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'View Status',
      decor: BgDecor.ekg,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : statusList.isEmpty
              ? const Center(
                  child: Text(
                    'No status records found',
                    style: TextStyle(color: AppColors.muted, fontSize: 15),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: statusList.length,
                  itemBuilder: (context, index) {
                    final status = statusList[index];
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
                                  '${status['date']}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 22),
                            _StatusRow('Endometrium Thickness',
                                status['endometrium_thickness']),
                            _StatusRow('Follicular Diameter',
                                status['follicular_diameter']),
                            _StatusRow('RI', status['RI']),
                            _StatusRow('PSV', status['PSV']),
                            _StatusRow('Perifollicular Rate',
                                status['perifollicular_rate']),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final dynamic value;

  const _StatusRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: AppColors.muted),
          ),
          Text(
            value?.toString() ?? '—',
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
