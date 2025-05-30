import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'main_home_page.dart';  // تعديل لاستيراد MainHomePage

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final List<String> images = [
    'assets/flower1.png',
    'assets/flower2.png',
    'assets/flower3.png',
    'assets/flower4.png',
    'assets/flower5.png',
    'assets/flower6.png',
    'assets/flower7.png',
    'assets/flower8.png',
    'assets/flower9.png',
    'assets/flower10.png',
    'assets/flower11.png',
    'assets/flower12.png',
    'assets/flower13.png',
    'assets/flower14.png',
    'assets/flower15.png',
    'assets/flower16.png',
  ];

  final ScrollController _scrollController = ScrollController();
  late Timer _timer;
  double scrollPosition = 0;
  String selectedLanguage = 'العربية';

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_scrollController.hasClients) {
        scrollPosition += 2;
        if (scrollPosition >= _scrollController.position.maxScrollExtent) {
          scrollPosition = 0;
          _scrollController.jumpTo(0);
        } else {
          _scrollController.animateTo(
            scrollPosition,
            duration: const Duration(milliseconds: 100),
            curve: Curves.linear,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFEEE7),
      body: Column(
        children: [
          const SizedBox(height: 50),

          // ✅ صور الزهور المتحركة بالأعلى
          SizedBox(
            height: 240,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: images.length ~/ 2,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(6),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          images[index],
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(6),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          images[index + (images.length ~/ 2)],
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // ✅ اللوجو المتحرك من اليسار
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder<Offset>(
                  tween: Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOut,
                  builder: (context, offset, child) {
                    return Transform.translate(
                      offset: Offset(offset.dx * 300, 0),
                      child: child,
                    );
                  },
                  child: Image.asset(
                    'assets/logo.png',
                    width: 220,
                    height: 220,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'أهلاً بك في متجر حكاية ورد - اصنع باقتك بحُب',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),

          // ✅ زر البدء
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainHomePage(userName: 'زائر'), // تعديل هنا
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF60786A),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  ("تسوق الآن"),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),

          // ✅ زر اختيار اللغة بطريقة أنيقة
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: buildLanguageDropdown(),
          ),

          // ✅ الحقوق
          const Text(
            '© 2025 حكاية ورد - جميع الحقوق محفوظة',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontFamily: 'Cairo',
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ✅ زر اللغة بشكل أنيق
 Widget buildLanguageDropdown() {
  return DropdownButton<String>(
    value: selectedLanguage,
    icon: const Icon(Icons.arrow_drop_down),
    iconSize: 20,
    elevation: 4,
    style: const TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    ),
    underline: const SizedBox(),
    onChanged: (String? newValue) {
      setState(() {
        selectedLanguage = newValue!;
        if (selectedLanguage == 'العربية') {
          context.setLocale(const Locale('ar', 'AE'));
        } else {
          context.setLocale(const Locale('en', 'US'));
        }
      });
    },
    items: <String>['العربية', 'English'].map<DropdownMenuItem<String>>((lang) {
      return DropdownMenuItem<String>(
        value: lang,
        child: Text(lang),
      );
    }).toList(),
  );
}
  }

