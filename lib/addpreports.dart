import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infertilityapp/app_ui.dart';
import 'package:infertilityapp/comman.dart';
import 'twelfth_page.dart';
import 'package:intl/intl.dart'; // Import package for date formatting

class AddPReportsPage extends StatefulWidget {
  final String userId;
  final String name;
  final String imageUrl;

  AddPReportsPage(
      {required this.userId, required this.name, required this.imageUrl});

  get dayDifference => null;

  @override
  _AddPReportsPageState createState() => _AddPReportsPageState();
}

class _AddPReportsPageState extends State<AddPReportsPage> {
  DateTime? _selectedDate;
  String? _selectedDay;
  TextEditingController endometriumController = TextEditingController();
  TextEditingController leftOvaryController = TextEditingController();
  TextEditingController rightOvaryController = TextEditingController();
  Map<String, int> dayMap = {
    'Sunday': 1,
    'Monday': 2,
    'Tuesday': 3,
    'Wednesday': 4,
    'Thursday': 5,
    'Friday': 6,
    'Saturday': 7,
  };

  Future<void> saveReport() async {
    // Prepare the form data
    var formData = {
      'Userid': widget.userId,
      'date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
      'day': _selectedDay ??
          '', // Use selected day, or empty string if not selected
      'Endometrium': endometriumController.text,
      'Leftovery': leftOvaryController.text,
      'Rightovery': rightOvaryController.text,
    };

    // Send a POST request to your PHP script
    var response = await http.post(
      Uri.parse(addreports),
      body: formData,
    );

    if (response.statusCode == 200) {
      // Successfully saved report
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
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Report',
      decor: BgDecor.dots,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: double.infinity,
            color: Colors.white,
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.8,
              maxScale: 4.0,
              child: Image.network(
                widget.imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image_outlined,
                      size: 56, color: AppColors.muted),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
