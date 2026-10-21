import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infertilityapp/app_ui.dart';
import 'twelfth_page.dart';
import 'package:intl/intl.dart'; // Import package for date formatting
import 'comman.dart';

class AddReportsPage extends StatefulWidget {
  final String userId;
  final String name;
  final String imageUrl;
  final int dayDifference;

  AddReportsPage({
    required this.userId,
    required this.name,
    required this.imageUrl,
    required this.dayDifference,
  });

  @override
  _AddReportsPageState createState() => _AddReportsPageState();
}

class _AddReportsPageState extends State<AddReportsPage> {
  DateTime? _selectedDate;
  TextEditingController endometriumController = TextEditingController();
  TextEditingController folliculardiameterController = TextEditingController();
  TextEditingController RIController = TextEditingController();
  TextEditingController PSVController = TextEditingController();
  TextEditingController perifollicularrateController = TextEditingController();
  TextEditingController FSHController = TextEditingController();
  TextEditingController LHController = TextEditingController();
  TextEditingController TSHController = TextEditingController();
  TextEditingController ProlactinController = TextEditingController();
  TextEditingController AMHController = TextEditingController();
  TextEditingController HSGReportController = TextEditingController();

  Future<void> saveReport() async {
    // Prepare the form data
    var formData = {
      'Userid': widget.userId,
      'date': DateFormat('yyyy-MM-dd').format(_selectedDate!), // Use selected date
      'endometrium_thickness': endometriumController.text,
      'follicular_diameter': folliculardiameterController.text,
      'RI': RIController.text,
      'PSV': PSVController.text,
      'perifollicular_rate': perifollicularrateController.text,
      'FSH': FSHController.text,
      'LH': LHController.text,
      'TSH': TSHController.text,
      'Prolactin': ProlactinController.text,
      'AMH': AMHController.text,
      'HSG_report': HSGReportController.text,
    };

    try {
      // Send a POST request to your PHP script
      var response = await http.post(
        Uri.parse(addreports),
        body: formData,
      );

      if (response.statusCode == 200) {
        // Successfully saved report
        var responseBody = response.body;
        print("Response Body: $responseBody");
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Success"),
              content: Text("Reports saved successfully"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TwelfthPage(
                              userId: widget.userId,
                              name: widget.name,
                              dayDifference: widget.dayDifference)),
                    );
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      } else {
        // Failed to save report
        print("Failed to save report. Status code: ${response.statusCode}");
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text("Failed to save reports"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print("Error occurred while saving report: $e");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("An error occurred. Please try again."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Add Reports',
      decor: BgDecor.ekg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Container(
                height: 240,
                width: double.infinity,
                color: Colors.white,
                child: InteractiveViewer(
                  panEnabled: true,
                  boundaryMargin: const EdgeInsets.all(20),
                  minScale: 0.9,
                  maxScale: 3.0,
                  child: Image.network(
                    widget.imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(Icons.broken_image_outlined,
                          size: 48, color: AppColors.muted),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Report Date',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  readOnly: true,
                  controller: TextEditingController(
                    text: _selectedDate != null
                        ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                        : '',
                  ),
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null && pickedDate != _selectedDate) {
                      setState(() {
                        _selectedDate = pickedDate;
                      });
                    }
                  },
                  decoration: const InputDecoration(
                    hintText: 'Select date',
                    prefixIcon: Icon(Icons.calendar_month_outlined),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SectionCard(
              title: 'Scan Reports',
              child: Column(
                children: [
                  AppTextField(
                      label: 'Endometrium Thickness',
                      controller: endometriumController),
                  const SizedBox(height: 14),
                  AppTextField(
                      label: 'Follicular Diameter',
                      controller: folliculardiameterController),
                  const SizedBox(height: 14),
                  AppTextField(
                      label: 'Perifollicular Rate',
                      controller: perifollicularrateController),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SectionCard(
              title: 'Follicular Flow Parameters',
              child: Column(
                children: [
                  AppTextField(label: 'RI', controller: RIController),
                  const SizedBox(height: 14),
                  AppTextField(label: 'PSV', controller: PSVController),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SectionCard(
              title: 'Blood Investigations',
              child: Column(
                children: [
                  AppTextField(label: 'FSH', controller: FSHController),
                  const SizedBox(height: 14),
                  AppTextField(label: 'LH', controller: LHController),
                  const SizedBox(height: 14),
                  AppTextField(label: 'TSH', controller: TSHController),
                  const SizedBox(height: 14),
                  AppTextField(
                      label: 'Prolactin', controller: ProlactinController),
                  const SizedBox(height: 14),
                  AppTextField(label: 'AMH', controller: AMHController),
                  const SizedBox(height: 14),
                  AppTextField(
                      label: 'HSG Report',
                      controller: HSGReportController,
                      maxLines: 2),
                ],
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Save Report',
              icon: Icons.check_rounded,
              onPressed: saveReport,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
