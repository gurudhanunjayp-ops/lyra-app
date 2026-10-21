import 'package:flutter/material.dart';
import 'package:nimble_charts/flutter.dart' as charts;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:infertilityapp/app_ui.dart';
import 'comman.dart';

class PGraphPage extends StatefulWidget {
  final String userId;

  PGraphPage({required this.userId});

  @override
  _PGraphPageState createState() => _PGraphPageState();
}

class _PGraphPageState extends State<PGraphPage> {
  List<charts.Series<dynamic, String>> _chartData = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    String url = '$graph?userid=${widget.userId}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status']) {
          List<dynamic> sortedData = List<dynamic>.from(data['data']);
          sortedData.sort((a, b) => b['date']
              .compareTo(a['date'])); // Sort by date in descending order
          final latestData = sortedData.take(5).toList();
          setState(() {
            _chartData = _createChartData(
                latestData); // Update chart data with latest fetched data
          });

          // Check for optimum levels after updating chart data
          _checkOptimumLevels(latestData);
        } else {
          _showErrorDialog(data['message']);
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog('Failed to connect to the server.');
    }
  }

  void _checkOptimumLevels(List<dynamic> data) {
    if (data.isNotEmpty) {
      // Get the latest date from the data
      String latestDate =
          data.first['date']; // Assuming 'date' is the field holding the date

      // Filter data to get entries for the latest date
      List<dynamic> latestData =
          data.where((element) => element['date'] == latestDate).toList();

      // Check if all values for the latest date are in optimum range
      bool allOptimum = latestData.every((element) =>
          (element['endometrium_thickness'] >= 8 &&
              element['endometrium_thickness'] <= 10) &&
          (element['follicular_diameter'] > 17) &&
          (element['RI'] < 0.5) &&
          (element['PSV'] > 11));

      if (allOptimum) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showOptimumDialog();
        });
      }
    }
  }

  void _showOptimumDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Optimum Levels'),
        content: Text('Patient reached optimum level'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  List<charts.Series<dynamic, String>> _createChartData(List<dynamic> data) {
    return [
      charts.Series<dynamic, String>(
        id: 'Endometrium Thickness',
        colorFn: (dynamic sales, _) => (sales['endometrium_thickness'] >= 8 &&
                sales['endometrium_thickness'] <= 10)
            ? charts.MaterialPalette.teal.shadeDefault
            : charts.MaterialPalette.red.shadeDefault,
        domainFn: (dynamic sales, _) => sales['date'],
        measureFn: (dynamic sales, _) => sales['endometrium_thickness'],
        data: data,
        labelAccessorFn: (dynamic sales, _) =>
            '${sales['endometrium_thickness']}',
      ),
      charts.Series<dynamic, String>(
        id: 'Follicular Diameter',
        colorFn: (dynamic sales, _) => (sales['follicular_diameter'] > 17)
            ? charts.MaterialPalette.teal.shadeDefault
            : charts.MaterialPalette.red.shadeDefault,
        domainFn: (dynamic sales, _) => sales['date'],
        measureFn: (dynamic sales, _) => sales['follicular_diameter'],
        data: data,
        labelAccessorFn: (dynamic sales, _) =>
            '${sales['follicular_diameter']}',
      ),
      charts.Series<dynamic, String>(
        id: 'Perifollicular Rate',
        colorFn: (dynamic sales, _) => charts.MaterialPalette.teal.shadeDefault,
        domainFn: (dynamic sales, _) => sales['date'],
        measureFn: (dynamic sales, _) => sales['perifollicular_rate'],
        data: data,
        labelAccessorFn: (dynamic sales, _) =>
            '${sales['perifollicular_rate']}',
      ),
      charts.Series<dynamic, String>(
        id: 'RI',
        colorFn: (dynamic sales, _) => (sales['RI'] < 0.5)
            ? charts.MaterialPalette.teal.shadeDefault
            : charts.MaterialPalette.red.shadeDefault,
        domainFn: (dynamic sales, _) => sales['date'],
        measureFn: (dynamic sales, _) => sales['RI'],
        data: data,
        labelAccessorFn: (dynamic sales, _) => '${sales['RI']}',
      ),
      charts.Series<dynamic, String>(
        id: 'PSV',
        colorFn: (dynamic sales, _) => (sales['PSV'] > 11)
            ? charts.MaterialPalette.teal.shadeDefault
            : charts.MaterialPalette.red.shadeDefault,
        domainFn: (dynamic sales, _) => sales['date'],
        measureFn: (dynamic sales, _) => sales['PSV'],
        data: data,
        labelAccessorFn: (dynamic sales, _) => '${sales['PSV']}',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'My Graph',
      decor: BgDecor.ekg,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SectionCard(
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 1000,
              height: double.infinity,
              child: charts.BarChart(
                _chartData,
                animate: true,
                barGroupingType: charts.BarGroupingType.grouped,
                behaviors: [
                  charts.SeriesLegend(),
                  charts.ChartTitle('Date',
                      behaviorPosition: charts.BehaviorPosition.bottom,
                      titleOutsideJustification:
                          charts.OutsideJustification.middleDrawArea),
                  charts.ChartTitle('Values',
                      behaviorPosition: charts.BehaviorPosition.start,
                      titleOutsideJustification:
                          charts.OutsideJustification.middleDrawArea),
                ],
                defaultRenderer: charts.BarRendererConfig<String>(
                  cornerStrategy: const charts.ConstCornerStrategy(30),
                ),
                selectionModels: [
                  charts.SelectionModelConfig(
                    type: charts.SelectionModelType.info,
                    changedListener: (charts.SelectionModel model) {
                      if (model.hasDatumSelection) {
                        final selectedDatum = model.selectedDatum.first;
                        final measures =
                            selectedDatum.datum['${selectedDatum.series.id}'];
                        final domain = selectedDatum.datum['date'];
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$domain: $measures'),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
