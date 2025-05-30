import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart'; // تأكد من إضافة lucide_icons في pubspec.yaml

class ShippingPage extends StatelessWidget {
  const ShippingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // 👈 النص من اليمين لليسار
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الشحن والتوصيل'),
          backgroundColor: const Color(0xFFFFEEE7),
          foregroundColor: const Color(0xFF60786A),
        ),
        body: const SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.truck, // أيقونة شاحنة
                  size: 80,
                  color: Color(0xFF60786A),
                ),
                SizedBox(height: 30),
                Text(
                  '1. نقوم بالتوصيل داخل جميع مناطق فلسطين24إلى 48 ساعة.\n'
                  '2. يمكنك اختيار الوقت المناسب للتوصيل أثناء إتمام الطلب.\n'
                  '3. نوفر توصيلًا مجانيًا للطلبات التي تتجاوز قيمتها 200 شيكل.\n'
                  '4. نحرص دائمًا على توصيل باقاتك بأمان وفي أفضل حال، لأن رضاك هو أولويتنا.',
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.9,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF444444),
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
