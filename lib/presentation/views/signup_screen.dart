
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/auth_controller.dart';

class SignupScreen extends GetView<AuthController> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final Rx<XFile?> _profileImage = Rx<XFile?>(null);

  SignupScreen({super.key});

  void _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    _profileImage.value = image;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Obx(() {
                return CircleAvatar(
                  radius: 50,
                  backgroundImage: _profileImage.value != null
                      ? FileImage(File(_profileImage.value!.path))
                      : null,
                  child: _profileImage.value == null
                      ? const Icon(Icons.camera_alt, size: 50)
                      : null,
                );
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_profileImage.value != null) {
                  controller.signUp(
                    email: _emailController.text,
                    password: _passwordController.text,
                    fullName: _nameController.text,
                    profileImage: _profileImage.value!,
                  );
                } else {
                  Get.snackbar('Error', 'Please select a profile image');
                }
              },
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
