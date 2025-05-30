import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'admin_messages_page.dart';
import '../models/cart_item.dart';
import '../models/bouquet.dart';
import 'special_order_page.dart';
import 'chat_page.dart';
import 'my_ratings_page.dart';
import 'edit_profile_page.dart';
import 'my_orders_page.dart';
import 'my_bouquets_page.dart';
import 'login_page.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String userId = '';
  String userName = 'اسم المستخدم';
  String userEmail = 'sewar@ss.com';
  List<CartItem> cartItems = [];
  List<Bouquet> myBouquets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadUserData().then((_) {
        if (userId.isNotEmpty) {
          fetchUserCartItems();
          fetchUserBouquets();
        }
      });
    });
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId') ?? '';
      userName = prefs.getString('userName') ?? 'اسم المستخدم';
      userEmail = prefs.getString('userEmail') ?? 'sewar@ss.com';
      isLoading = false;
    });
  }

  Future<void> fetchUserCartItems() async {
    if (userId.isEmpty) return;
    final url = Uri.parse('http://192.168.1.15:3000/cart/user/$userId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (mounted) {
        setState(() {
          cartItems = data.map((e) => CartItem.fromJson(e)).toList();
        });
      }
    }
  }

  Future<void> fetchUserBouquets() async {
    if (userId.isEmpty) return;
    final url = Uri.parse('http://192.168.1.15:3000/api/bouquets/user/$userId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (mounted) {
        setState(() {
          myBouquets = data.map((e) => Bouquet.fromJson(e)).toList();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        backgroundColor: const Color(0xFFFFEEE7),
      ),
      body: userId.isEmpty
          ? buildGuestProfile(context)
          : buildUserProfile(context),
    );
  }

  Widget buildGuestProfile(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_outline, size: 100, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'مرحباً بك في حكاية ورد 🌸',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text('سجل دخولك لتتمكن من إدارة حسابك وطلباتك'),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            icon: const Icon(Icons.login),
            label: const Text('تسجيل الدخول'),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF2A8C1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildUserProfile(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: const Color(0xFFF2A8C1),
          child: const Icon(Icons.person, size: 50, color: Colors.white),
        ),
        const SizedBox(height: 15),
        Center(
          child: Text(
            userName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Center(
          child: Text(
            userEmail,
            style: const TextStyle(color: Color(0xFF60786A)),
          ),
        ),
        const SizedBox(height: 30),
        buildProfileOption(context, Icons.shopping_bag, 'طلباتي'),
        buildProfileOption(context, Icons.local_florist, 'باقاتي'),
        buildProfileOption(context, Icons.assignment, 'طلبات خاصة'),
        buildProfileOption(context, Icons.chat, 'الدردشة مع المسؤول'),
        buildProfileOption(context, Icons.edit, 'تعديل البيانات'),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.clear();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
            );
          },
          icon: const Icon(Icons.logout),
          label: const Text('تسجيل الخروج'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget buildProfileOption(BuildContext context, IconData icon, String title) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.pink),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          switch (title) {
            case 'طلباتي':
              Navigator.push(context, MaterialPageRoute(builder: (_) => MyOrdersPage(userId: userId)));
              break;
            case 'باقاتي':
              Navigator.push(context, MaterialPageRoute(builder: (_) => MyBouquetsPage(userId: userId)));
              break;
            case 'طلبات خاصة':
              Navigator.push(context, MaterialPageRoute(builder: (_) => SpecialOrderPage()));
              break;
            case 'الدردشة مع المسؤول':
              Navigator.push(context, MaterialPageRoute(builder: (_) => ChatPage(userId: userId, userName: userName)));
              break;
            case 'تعديل البيانات':
              Navigator.push(context, MaterialPageRoute(builder: (_) => EditProfilePage()));
              break;
          }
        },
      ),
    );
  }
}