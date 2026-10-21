import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:infertilityapp/app_ui.dart';
import 'package:infertilityapp/comman.dart';
import 'package:infertilityapp/fifth_page.dart';

class TenthPage extends StatefulWidget {
  final Map<String, dynamic> doctorDetails;
  final String userId;
  final int dayDifference;

  TenthPage(
      {required this.doctorDetails,
      required this.userId,
      required this.dayDifference});

  @override
  _TenthPageState createState() => _TenthPageState();
}

class _TenthPageState extends State<TenthPage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _designationController;
  late TextEditingController _contactController;

  File? _image;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.doctorDetails['dr_name']);
    _emailController =
        TextEditingController(text: widget.doctorDetails['email']);
    _designationController =
        TextEditingController(text: widget.doctorDetails['designation']);
    _contactController =
        TextEditingController(text: widget.doctorDetails['contact_no']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _designationController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> _submitForm() async {
    // Print the values of form fields before submitting the form
    print('Name: ${_nameController.text}');
    print('Email: ${_emailController.text}');
    print('Designation: ${_designationController.text}');
    print('Contact Number: ${_contactController.text}');

    try {
      var uri = Uri.parse(drprofileedit);
      var request = http.MultipartRequest('POST', uri);

      request.fields['userId'] = widget.doctorDetails['dr_userid'];
      request.fields['dr_name'] = _nameController.text;
      request.fields['email'] = _emailController.text;
      request.fields['designation'] = _designationController.text;
      request.fields['contact_no'] = _contactController.text;

      // Check if an image is selected
      if (_image != null) {
        request.files.add(
            await http.MultipartFile.fromPath('doctorimage', _image!.path));
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        // Success
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile updated successfully')));
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => FifthPage(
                  userId: widget.userId,
                  dayDifference: widget.dayDifference)),
        );
      } else {
        // Error
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update profile')));
      }
    } catch (e) {
      print("Exception: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Edit Profile',
      decor: BgDecor.dots,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GestureDetector(
              onTap: _getImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 62,
                    backgroundColor: AppColors.surface,
                    backgroundImage: _image == null
                        ? NetworkImage(
                            '$drimageedit${widget.doctorDetails['doctorimage']}',
                          ) as ImageProvider
                        : FileImage(_image!),
                    onBackgroundImageError: (_, __) {},
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      gradient: kBrandGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit_rounded,
                        color: Colors.white, size: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            SectionCard(
              child: Column(
                children: [
                  AppTextField(
                    label: 'Name',
                    icon: Icons.person_outline_rounded,
                    controller: _nameController,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Designation',
                    icon: Icons.work_outline_rounded,
                    controller: _designationController,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Contact Number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    controller: _contactController,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            PrimaryButton(
              label: 'Save Changes',
              icon: Icons.check_rounded,
              onPressed: _submitForm,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
