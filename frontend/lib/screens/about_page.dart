import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // 👈 لجعل النص من اليمين لليسار
      child: Scaffold(
        appBar: AppBar(
          title: const Text('من نحن'),
          backgroundColor: const Color(0xFFFFEEE7),
          foregroundColor: Color(0xFF60786A),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // ✅ اللوجو
                Center(
                  child: Image.asset(
                    'assets/logo.png',
                    height: 160,
                  ),
                ),
                const SizedBox(height: 30),
                // ✅ نص "من نحن" منسق بشكل أنيق
                const Text(
                  'في حكاية ورد، نؤمن أن لكل وردة حكاية\n'
                  'حكاية ورد هو متجر فلسطيني متخصص في بيع الورود وتنسيق الباقات بكل حب واحترافية.\n'
                  'نوفر خدمة توصيل سريعة وآمنة داخل الضفة الغربية والداخل الفلسطيني، مع ضمان وصول الباقة بأجمل صورة',
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.9,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF444444), // أغمق وأوضح
                  ),
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
