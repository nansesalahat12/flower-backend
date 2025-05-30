
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

import 'main_home_page.dart';
import 'admin_home_page.dart';
import 'signup_page.dart';
import 'profilepage.dart';
import '../widgets/custom_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? emailError;
  String? passwordError;

  bool isValidEmail(String email) {
    final RegExp emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,4}$');
    return emailRegex.hasMatch(email);
  }

  Future<void> _loginUser(BuildContext context) async {
    setState(() {
      emailError = null;
      passwordError = null;

      if (emailController.text.isEmpty) {
        emailError = tr("enter_email");
      } else if (!isValidEmail(emailController.text.trim())) {
        emailError = tr("invalid_email");
      }

      if (passwordController.text.isEmpty) {
        passwordError = tr("enter_password");
      }
    });

    if (emailError != null || passwordError != null) return;

    final String apiUrl = "http://192.168.1.15:3000/users/signin";

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "email": emailController.text.trim(),
        "password": passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      final email = responseData['email'] ?? emailController.text.trim();
      final name = responseData['name'] ?? 'مستخدم';
      final userId = responseData['_id'] ?? '';

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userEmail', email);
      await prefs.setString('userName', name);
      await prefs.setString('userId', userId);

      if (email == "admin@flowerapp.com") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("أهلاً بك أيها المدير")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AdminHomePage(userName: name)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr("login_success"))),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const MainHomePage(initialTabIndex: 2, userName: ''),
          ),
        );
      }
    } else {
      final error = jsonDecode(response.body)['error'] ?? tr("login_failed");
      setState(() {
        passwordError = "\${tr('error')}: \$error";
      });
    }
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr("forgot_password")),
        content: Text(tr("reset_password_instructions")),
        actions: [
          TextButton(
            child: Text(tr("close")),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFEEE7),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                tr('login'),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5F7E6E),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                tr('to_continue'),
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              CustomTextField(
                label: tr('email'),
                keyboardType: TextInputType.emailAddress,
                controller: emailController,
                errorText: emailError,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: tr('password'),
                obscureText: true,
                controller: passwordController,
                errorText: passwordError,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _showForgotPasswordDialog,
                  child: Text(
                    tr("forgot_password"),
                    style: const TextStyle(color: Color(0xFF5F7E6E)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _loginUser(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5F7E6E),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    tr('log_in'),
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SignUpPage()),
                  );
                },
                child: Text(tr("no_account_sign_up")),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
