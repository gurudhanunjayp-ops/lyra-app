import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:infertilityapp/app_ui.dart';
import 'package:infertilityapp/comman.dart';

class AddDoctor extends StatefulWidget {
  final String drUserId;

  AddDoctor({required this.drUserId});

  @override
  _AddDoctorState createState() => _AddDoctorState();
}

class _AddDoctorState extends State<AddDoctor> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController specController = TextEditingController();
  File? _image;

  Future getImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 12),
              ListTile(
                leading:
                    const Icon(Icons.photo_camera, color: AppColors.primary),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop(ImageSource.camera);
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.photo_library, color: AppColors.primary),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    ).then((source) async {
      if (source != null) {
        final pickedFile = await ImagePicker().getImage(
          source: source,
        );

        setState(() {
          if (pickedFile != null) {
            _image = File(pickedFile.path);
          } else {
            print('No image selected.');
          }
        });
      }
    });
  }

  Future<void> submitData() async {
    final uri = Uri.parse(adddoctor);

    var request = http.MultipartRequest('POST', uri)
      ..fields['dr_userid'] = widget.drUserId
      ..fields['dr_name'] = nameController.text
      ..fields['contact_no'] = phoneController.text
      ..fields['email'] = emailController.text
      ..fields['designation'] = specController.text;

    if (_image != null) {
      request.files.add(
          await http.MultipartFile.fromPath('doctorimage', _image!.path));
    }

    var response = await request.send();
    if (response.statusCode == 200) {
      // Success
      print('Doctor details added successfully.');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Doctor details added successfully.'),
        backgroundColor: Colors.grey,
      ));
      // Navigate to previous page
      Navigator.pop(context);
    } else {
      // Error
      print('Error adding doctor details.');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error adding doctor details.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Add Doctor',
      decor: BgDecor.crosses,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 8),
            GestureDetector(
              onTap: getImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    key: UniqueKey(), // Add a UniqueKey
                    radius: 62,
                    backgroundColor: AppColors.surface,
                    backgroundImage:
                        _image != null ? FileImage(_image!) : null,
                    child: _image == null
                        ? const Icon(Icons.person_rounded,
                            size: 60, color: AppColors.primary)
                        : null,
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      gradient: kBrandGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_a_photo_rounded,
                        color: Colors.white, size: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'User ID: ${widget.drUserId}',
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            SectionCard(
              child: Column(
                children: [
                  AppTextField(
                    label: 'Name',
                    hint: 'Enter full name',
                    icon: Icons.person_outline_rounded,
                    controller: nameController,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Email',
                    hint: 'Enter email address',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    controller: emailController,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Phone',
                    hint: 'Enter contact number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    controller: phoneController,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Specialisation',
                    hint: 'e.g. Gynaecologist',
                    icon: Icons.work_outline_rounded,
                    controller: specController,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            PrimaryButton(
              label: 'Submit',
              icon: Icons.check_rounded,
              onPressed: submitData,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
