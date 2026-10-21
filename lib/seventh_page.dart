import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:infertilityapp/app_ui.dart';
import 'package:intl/intl.dart';
import 'eight_page.dart';

class SeventhPage extends StatefulWidget {
  final String userId;
  final int dayDifference;

  SeventhPage({required this.userId, required this.dayDifference});

  @override
  _SeventhPageState createState() => _SeventhPageState();
}

class _SeventhPageState extends State<SeventhPage> {
  DateTime? _selectedDate;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactNoController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _marriageYearController =
      TextEditingController();
  final TextEditingController _bloodgroupController = TextEditingController();
  final TextEditingController _medicalHistoryController =
      TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _BMIController = TextEditingController();
  final TextEditingController _contraceptiveHistoryController =
      TextEditingController();
  final TextEditingController _lastMenstrualPeriodController =
      TextEditingController();
  final TextEditingController _menstrualhistoryController =
      TextEditingController();
  final TextEditingController _flowController = TextEditingController();
  final TextEditingController _coitalHistoryController =
      TextEditingController();
  final TextEditingController _obstetricHistoryController =
      TextEditingController();
  final TextEditingController _surgicalHistoryController =
      TextEditingController();
  String? consanguineous;
  String? smoking;
  String? alcohol;

  File? _imageFile;
  final picker = ImagePicker();

  Future<void> _getImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              ListTile(
                leading:
                    const Icon(Icons.photo_camera, color: AppColors.primary),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final pickedFile =
                      await picker.getImage(source: ImageSource.camera);
                  _setImageFile(pickedFile);
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.photo_library, color: AppColors.primary),
                title: const Text('Gallery'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final pickedFile =
                      await picker.getImage(source: ImageSource.gallery);
                  _setImageFile(pickedFile);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _setImageFile(PickedFile? pickedFile) {
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> sendDataToBackend() async {
    var url = 'http://14.139.187.229:8081/Infertilityapp/addpatient.php';
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.fields['userid'] = widget.userId;
    request.fields['name'] = _nameController.text;
    request.fields['contactno'] = _contactNoController.text;
    request.fields['age'] = _ageController.text;
    request.fields['gender'] = _genderController.text;
    request.fields['height'] = _heightController.text;
    request.fields['weight'] = _weightController.text;
    request.fields['marriageyear'] = _marriageYearController.text;
    request.fields['bloodgroup'] = _bloodgroupController.text;
    request.fields['medicalhistory'] = _medicalHistoryController.text;
    request.fields['occupation'] = _occupationController.text;
    request.fields['BMI'] = _BMIController.text;
    request.fields['contraceptive_history'] =
        _contraceptiveHistoryController.text;
    request.fields['last_menstrual_period'] =
        _lastMenstrualPeriodController.text;
    request.fields['menstrual_history'] = _menstrualhistoryController.text;
    request.fields['flow'] = _flowController.text;
    request.fields['coital_history'] = _coitalHistoryController.text;
    request.fields['obstetric_history'] = _obstetricHistoryController.text;
    request.fields['surgical_history'] = _surgicalHistoryController.text;
    request.fields['consanguineous'] = consanguineous ?? '';
    request.fields['smoking'] = smoking ?? '';
    request.fields['alcohol'] = alcohol ?? '';

    if (_imageFile != null) {
      var pic = await http.MultipartFile.fromPath("image", _imageFile!.path);
      request.files.add(pic);
    }

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var data = jsonDecode(responseData);
      if (data['status']) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EightPage(
              userId: widget.userId,
              dayDifference: widget.dayDifference,
            ),
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text(data['message']),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(
                'Failed to connect to the server. Please try again later.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _setSmoking(String value) {
    setState(() {
      smoking = value;
    });
  }

  void _setconsanguineous(String value) {
    setState(() {
      consanguineous = value;
    });
  }

  void _setAlcohol(String value) {
    setState(() {
      alcohol = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Add Patient',
      decor: BgDecor.crosses,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _getImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 56,
                    backgroundColor: AppColors.surface,
                    backgroundImage:
                        _imageFile != null ? FileImage(_imageFile!) : null,
                    child: _imageFile == null
                        ? const Icon(Icons.person_rounded,
                            size: 52, color: AppColors.primary)
                        : null,
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      gradient: kBrandGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_a_photo_rounded,
                        color: Colors.white, size: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SectionCard(
              title: 'Basic Details',
              child: Column(
                children: [
                  AppTextField(
                    label: 'Patient ID',
                    controller: TextEditingController(text: widget.userId),
                    icon: Icons.badge_outlined,
                    enabled: false,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Name',
                    hint: 'Full name',
                    icon: Icons.person_outline_rounded,
                    controller: _nameController,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Mobile Number',
                    hint: 'Contact number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    controller: _contactNoController,
                  ),
                  const SizedBox(height: 16),
                  AppDropdown<int>(
                    label: 'Year of Marriage',
                    icon: Icons.favorite_border_rounded,
                    items: List.generate(
                      DateTime.now().year - 1969,
                      (index) => DropdownMenuItem<int>(
                        value: DateTime.now().year - index,
                        child:
                            Text((DateTime.now().year - index).toString()),
                      ),
                    ),
                    onChanged: (int? value) {
                      _marriageYearController.text = value?.toString() ?? '';
                      print('Selected year: $value');
                    },
                  ),
                  const SizedBox(height: 16),
                  AppDropdown<String>(
                    label: 'Blood Group',
                    icon: Icons.bloodtype_outlined,
                    items: const [
                      'A+',
                      'A-',
                      'B+',
                      'B-',
                      'AB+',
                      'AB-',
                      'O+',
                      'O-'
                    ]
                        .map((bg) =>
                            DropdownMenuItem<String>(value: bg, child: Text(bg)))
                        .toList(),
                    onChanged: (String? value) {
                      _bloodgroupController.text = value ?? '';
                      print('Selected blood group: $value');
                    },
                  ),
                  const SizedBox(height: 16),
                  AppDropdown<int>(
                    label: 'Age',
                    icon: Icons.cake_outlined,
                    items: [
                      const DropdownMenuItem<int>(
                          value: 18, child: Text('18')),
                      const DropdownMenuItem<int>(
                          value: 19, child: Text('19')),
                      // Add other ages up to 60+
                      for (int i = 20; i <= 60; i++)
                        DropdownMenuItem<int>(
                            value: i, child: Text(i.toString())),
                      const DropdownMenuItem<int>(
                          value: 61, child: Text('60+')),
                    ],
                    onChanged: (int? value) {
                      _ageController.text = value?.toString() ?? '';
                      print('Selected age: $value');
                    },
                  ),
                  const SizedBox(height: 16),
                  AppDropdown<String>(
                    label: 'Gender',
                    icon: Icons.wc_outlined,
                    items: const ['Female', 'Male', 'Other']
                        .map((g) =>
                            DropdownMenuItem<String>(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (String? value) {
                      _genderController.text = value ?? '';
                      print('Selected Gender: $value');
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'Height',
                          hint: 'cm',
                          icon: Icons.height_rounded,
                          keyboardType: TextInputType.number,
                          controller: _heightController,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: AppTextField(
                          label: 'Weight',
                          hint: 'kg',
                          icon: Icons.monitor_weight_outlined,
                          keyboardType: TextInputType.number,
                          controller: _weightController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'Occupation',
                          hint: 'Occupation',
                          icon: Icons.work_outline_rounded,
                          controller: _occupationController,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: AppTextField(
                          label: 'BMI',
                          hint: '0.0',
                          icon: Icons.monitor_heart_outlined,
                          keyboardType: TextInputType.number,
                          controller: _BMIController,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SectionCard(
              title: 'Medical History',
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Last Menstrual Period',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        readOnly: true,
                        controller: _lastMenstrualPeriodController,
                        onTap: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null &&
                              pickedDate != _selectedDate) {
                            setState(() {
                              _selectedDate = pickedDate;
                              _lastMenstrualPeriodController.text =
                                  DateFormat('dd/MM/yyyy')
                                      .format(_selectedDate!);
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
                  const SizedBox(height: 16),
                  AppDropdown<String>(
                    label: 'Menstrual History',
                    icon: Icons.event_repeat_outlined,
                    items: const ['regular', 'irregular']
                        .map((v) =>
                            DropdownMenuItem<String>(value: v, child: Text(v)))
                        .toList(),
                    onChanged: (String? value) {
                      _menstrualhistoryController.text = value ?? '';
                      print('Selected menstrual history: $value');
                    },
                  ),
                  const SizedBox(height: 16),
                  AppDropdown<String>(
                    label: 'Flow',
                    icon: Icons.water_drop_outlined,
                    items: const ['scanty', 'moderate', 'severe']
                        .map((v) =>
                            DropdownMenuItem<String>(value: v, child: Text(v)))
                        .toList(),
                    onChanged: (String? value) {
                      _flowController.text = value ?? '';
                      print('Selected flow: $value');
                    },
                  ),
                  const SizedBox(height: 16),
                  YesNoField(
                    label: 'Consanguineous',
                    value: consanguineous,
                    onChanged: _setconsanguineous,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Contraceptive History',
                    icon: Icons.history_edu_outlined,
                    controller: _contraceptiveHistoryController,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Coital History',
                    icon: Icons.history_edu_outlined,
                    controller: _coitalHistoryController,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Obstetric History',
                    icon: Icons.history_edu_outlined,
                    controller: _obstetricHistoryController,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Surgical History',
                    icon: Icons.history_edu_outlined,
                    controller: _surgicalHistoryController,
                  ),
                  const SizedBox(height: 16),
                  YesNoField(
                    label: 'Smoking',
                    value: smoking,
                    onChanged: _setSmoking,
                  ),
                  const SizedBox(height: 16),
                  YesNoField(
                    label: 'Alcohol',
                    value: alcohol,
                    onChanged: _setAlcohol,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Medical History',
                    hint: 'Any relevant medical history',
                    icon: Icons.medical_information_outlined,
                    controller: _medicalHistoryController,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Next',
              icon: Icons.arrow_forward_rounded,
              onPressed: sendDataToBackend,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}


