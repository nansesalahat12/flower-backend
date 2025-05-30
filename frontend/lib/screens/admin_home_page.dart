import 'package:flutter/material.dart';
import 'add_product_page.dart';
import 'main_home_page.dart';
import 'ready_products_page.dart';
import 'orders_page.dart'; // ✅ استدعاء صفحة عرض الطلبات
import 'chat_page.dart';
import 'admin_messages_page.dart';
class AdminHomePage extends StatelessWidget {
  final String userName;

  const AdminHomePage({Key? key, required this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFEEE7),
      appBar: AppBar(
        title: const Text('لوحة تحكم الأدمن'),
        backgroundColor: const Color(0xFF5F7E6E),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'العودة للرئيسية',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => MainHomePage(userName: userName)),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 30),

            // ✅ إضافة منتج
            ElevatedButton.icon(
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('إضافة منتج جديد', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE5B19B),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddProductPage()),
                );
              },
            ),

            const SizedBox(height: 16),

            // ✅ عرض المنتجات
            ElevatedButton.icon(
              icon: const Icon(Icons.view_list, color: Colors.white),
              label: const Text('عرض جميع المنتجات', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE5B19B),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReadyProductsPage()),
                );
              },
            ),

            const SizedBox(height: 16),

            // ✅ عرض الطلبات الجديدة
            ElevatedButton.icon(
              icon: const Icon(Icons.receipt_long, color: Colors.white),
              label: const Text('عرض الطلبات', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE5B19B),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OrdersPage()),
                );
              },
            ),

            const SizedBox(height: 16),

            // ✅ زر فتح رسائل المستخدمين
            ElevatedButton.icon(
              icon: const Icon(Icons.chat, color: Colors.white),
              label: const Text('رسائل المستخدمين', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE5B19B),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminChatPage()),
                );
              },
            ),

            const SizedBox(height: 16),

            // ✅ تسجيل الخروج
            ElevatedButton.icon(
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text('تسجيل الخروج', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE5B19B),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => MainHomePage(userName: userName)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
