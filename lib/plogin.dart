import 'package:flutter/material.dart';
import 'package:infertilityapp/app_ui.dart';
import 'package:infertilityapp/comman.dart';
import 'package:infertilityapp/results.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:infertilityapp/fourth_page.dart';
import 'package:infertilityapp/padvice.dart';
import 'package:infertilityapp/pgraph.dart';
import 'package:infertilityapp/pmedication.dart';
import 'package:infertilityapp/pprofile.dart';
import 'package:infertilityapp/preports.dart';
import 'dart:io';

class PLoginPage extends StatefulWidget {
  final String userId;
  final String name;

  PLoginPage({required this.userId, required this.name});

  @override
  _PLoginPageState createState() => _PLoginPageState();
}

class _PLoginPageState extends State<PLoginPage> {
  DateTime? _selectedDate;
  int _dayCount = 0;
  Timer? _timer;

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

    final headers = {'Content-Type': 'application/json'};
    final body = json.encode(
        {'userId': widget.userId, 'selectedDate': date.toIso8601String()});

    final response1 = await http.post(
      Uri.parse(savedate),
      headers: headers,
      body: body,
    );

    if (response1.statusCode == 200) {
      print('Date saved successfully');
    } else {
      print('Failed to save date to backend');
      print('Response status: ${response1.statusCode}');
      print('Response body: ${response1.body}');
    }
    final response2 = await http.post(
      Uri.parse(saveperioddate),
      headers: headers,
      body: body,
    );

    if (response2.statusCode == 200) {
      print('Date saved successfully to saveperioddate');
    } else {
      print('Failed to save date to saveperioddate backend');
      print('Response status: ${response2.statusCode}');
      print('Response body: ${response2.body}');
    }
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    DateTime? fertileStartDate;
    DateTime? fertileEndDate;

    if (_selectedDate != null) {
      fertileStartDate = _selectedDate!.add(Duration(days: 14));
      fertileEndDate = _selectedDate!.add(Duration(days: 18));
    }
    final Uri whatsApp = Uri.parse('http://wasap.my/919444311000');
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => FourthPage(),
          ),
          ModalRoute.withName('/'), // Make sure this matches your- route name
        );
      },
      child: Scaffold(
        key: _scaffoldKey,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _RoundIconButton(
                icon: Icons.menu_rounded,
                onTap: () {
                  _scaffoldKey.currentState
                      ?.openDrawer(); // Open drawer when menu icon is tapped
                },
              ),
              _RoundIconButton(
                asset: 'assets/whats.png',
                onTap: () async {
                  launchUrl(whatsApp);
                },
              ),
            ],
          ),
        ),
        drawer: Drawer(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
                decoration: const BoxDecoration(gradient: kBrandGradient),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.white.withValues(alpha: 0.25),
                      child: const Icon(Icons.person_rounded,
                          color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        widget.name.isNotEmpty
                            ? widget.name
                            : 'Patient Menu',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _DrawerTile(
                icon: Icons.account_circle_outlined,
                title: 'Patient Profile',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PProfilePage(
                            userId: widget.userId, name: widget.name)),
                  );
                },
              ),
              _DrawerTile(
                icon: Icons.add_photo_alternate_outlined,
                title: 'Add Reports',
                onTap: () {
                  _launchWhatsApp();
                },
              ),
              _DrawerTile(
                icon: Icons.calendar_month_outlined,
                title: 'Period History',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ResultsPage(userId: widget.userId)),
                  );
                },
              ),
              const Divider(height: 28, indent: 20, endIndent: 20),
              _DrawerTile(
                icon: Icons.logout_rounded,
                title: 'Logout',
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => FourthPage()),
                    ModalRoute.withName('/'),
                  );
                },
              ),
            ],
          ),
        ),
        body: AppBackground(
          decor: BgDecor.hearts,
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          _selectedDate == null
                              ? 'Track your cycle'
                              : 'Started ${DateFormat.yMMMd().format(_selectedDate!)}',
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: 132,
                          height: 132,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: kBrandGradient,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 112,
                              height: 112,
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
                                      fontSize: 42,
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
                        if (_selectedDate != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.water_drop_outlined,
                                    size: 18, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'Fertile window: ${DateFormat.yMMMd().format(fertileStartDate!)} – ${DateFormat.yMMMd().format(fertileEndDate!)}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      height: 1.4,
                                      color: AppColors.ink,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 18),
                        PrimaryButton(
                          label: _selectedDate == null
                              ? 'Select Start Date'
                              : 'Update Start Date',
                          icon: Icons.calendar_month_rounded,
                          onPressed: () => _selectDate(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.95,
                    children: [
                      FeatureCard(
                        title: 'Reports',
                        icon: Icons.description_outlined,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PReportsPage(
                                    userId: widget.userId,
                                    name: widget.name)),
                          );
                        },
                      ),
                      FeatureCard(
                        title: 'Advices',
                        icon: Icons.tips_and_updates_outlined,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    PAdvicePage(userId: widget.userId)),
                          );
                        },
                      ),
                      FeatureCard(
                        title: 'Graphs',
                        icon: Icons.insights_rounded,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    PGraphPage(userId: widget.userId)),
                          );
                        },
                      ),
                      FeatureCard(
                        title: 'Medications',
                        icon: Icons.medication_outlined,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    PMedicationPage(userId: widget.userId)),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchWhatsApp() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading:
                    const Icon(Icons.photo_camera, color: AppColors.primary),
                onTap: () {
                  _pickImage(ImageSource.camera, widget.userId);
                  Navigator.pop(context);
                },
                title: Text('Take Photo'),
              ),
              ListTile(
                leading:
                    const Icon(Icons.photo_library, color: AppColors.primary),
                onTap: () {
                  _pickImage(ImageSource.gallery, widget.userId);
                  Navigator.pop(context);
                },
                title: Text('Choose from Gallery'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source, String userId) async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: source);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      uploadImage(imageFile, userId);
    }
  }

  Future<void> uploadImage(File imageFile, String userId) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(uploadimg),
      );
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
        ),
      );
      request.fields['Userid'] = userId;

      var streamedResponse = await request.send();

      if (streamedResponse.statusCode == 200) {
        // Show Snackbar on successful upload
        Navigator.of(context).pop();
        _showSnackbar('Image uploaded successfully');
      } else {
        // Show Snackbar on failed upload
        Navigator.of(context).pop();
        _showSnackbar('Image upload failed');
      }
    } catch (error) {
      print('Error: $error');
      // Show Snackbar on error
      _showSnackbar('Error: $error');
    }
  }

  void _showSnackbar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData? icon;
  final String? asset;
  final VoidCallback onTap;

  const _RoundIconButton({this.icon, this.asset, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      shadowColor: AppColors.primary.withValues(alpha: 0.2),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: asset != null
              ? Image.asset(asset!, width: 24, height: 24)
              : Icon(icon, color: AppColors.primary, size: 24),
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 26),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15.5),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: onTap,
    );
  }
}
