import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main_home_page.dart';
import 'cart_page.dart';
import 'profilepage.dart';
import 'login_page.dart';

class MainWrapperPage extends StatefulWidget {
  const MainWrapperPage({Key? key}) : super(key: key);

  @override
  State<MainWrapperPage> createState() => _MainWrapperPageState();
}

class _MainWrapperPageState extends State<MainWrapperPage> {
  int _selectedIndex = 0;
  String userId = '';
  bool isLoading = true;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    loadUserId();
  }

  Future<void> loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final storedId = prefs.getString('userId');

    if (storedId == null || storedId.isEmpty) {
      // المستخدم غير مسجل دخول ➜ يرجع لتسجيل الدخول
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
    } else {
      setState(() {
        userId = storedId;
        isLoading = false;

        _pages = [
          MainHomePage(userName: userId),
          CartPage(userId: userId),
          const UserProfilePage(),
        ];
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFFF2A8C1),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'السلة'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
        ],
      ),
    );
  }
}
