import 'package:flutter/material.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تواصل معنا'),
        backgroundColor: const Color(0xFFFFEEE7),  // نفس لون خلفية الصفحات
        foregroundColor: Colors.black87,            // لون النص في الـ AppBar
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFFFEEE7),     // نفس لون الخلفية في الصفحات
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'رقم الهاتف: +966567891044',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'البريد الإلكتروني: info@hakaward.ps',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
