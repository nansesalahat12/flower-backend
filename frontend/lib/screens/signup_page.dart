import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/screens/main_home_page.dart';
import 'package:easy_localization/easy_localization.dart';
import '../widgets/custom_text_field.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isLoading = false;

  Future<void> _registerUser(BuildContext context) async {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('email_invalid'.tr())),
      );
      return;
    }

    final password = passwordController.text;
    final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$');
    if (!passwordRegex.hasMatch(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('password_invalid'.tr())),
      );
      return;
    }

    if (password != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('password_mismatch'.tr())),
      );
      return;
    }

    setState(() => isLoading = true);

    const String apiUrl = "http://192.168.1.15:3000/users/register";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "name": fullNameController.text,
          "phone": phoneController.text,
          "address": addressController.text,
          "email": emailController.text,
          "city": cityController.text,
          "password": passwordController.text,
        }),
      );

      setState(() => isLoading = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("signup_success".tr())),
        );

        // حفظ الاسم قبل المسح
        final userName = fullNameController.text;

        // مسح الحقول
        fullNameController.clear();
        phoneController.clear();
        addressController.clear();
        emailController.clear();
        cityController.clear();
        passwordController.clear();
        confirmPasswordController.clear();

        // التنقل إلى الصفحة الرئيسية
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainHomePage(userName: userName),
          ),
        );
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'signup_failed'.tr();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${'signup_failed'.tr()}: $error")),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${'signup_failed'.tr()}: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFEEE7),
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'sign_up'.tr(),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5F7E6E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'sign_up_subtitle'.tr(),
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 32),
                    CustomTextField(label: 'full_name'.tr(), controller: fullNameController),
                    const SizedBox(height: 16),
                    CustomTextField(label: 'phone'.tr(), controller: phoneController),
                    const SizedBox(height: 16),
                    CustomTextField(label: 'address'.tr(), controller: addressController),
                    const SizedBox(height: 16),
                    CustomTextField(label: 'email'.tr(), controller: emailController),
                    const SizedBox(height: 16),
                    CustomTextField(label: 'city'.tr(), controller: cityController),
                    const SizedBox(height: 16),
                    CustomTextField(label: 'password'.tr(), controller: passwordController, obscureText: true),
                    const SizedBox(height: 16),
                    CustomTextField(label: 'confirm_password'.tr(), controller: confirmPasswordController, obscureText: true),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : () => _registerUser(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5F7E6E),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(
                                'sign_up'.tr(),
                                style: const TextStyle(fontSize: 18, color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
