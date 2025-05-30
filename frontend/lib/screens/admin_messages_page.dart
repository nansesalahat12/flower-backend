// ✅ صفحة تعرض المستخدمين الذين راسلوا الأدمن
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'chat_with_user_page.dart';

import 'dart:convert';


class AdminChatPage extends StatefulWidget {
  const AdminChatPage({Key? key}) : super(key: key);

  @override
  State<AdminChatPage> createState() => _AdminChatPageState();
}

class _AdminChatPageState extends State<AdminChatPage> {
  List<dynamic> users = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final url = Uri.parse('http://192.168.1.15:3000/api/chat/users');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        users = json.decode(response.body);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('رسائل المستخدمين'),
        backgroundColor: Colors.pink,
      ),
      body: users.isEmpty
          ? const Center(child: Text('لا توجد محادثات'))
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(user['userName'] ?? 'مستخدم'),
                  subtitle: Text(user['_id']),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatWithUserPage(userId: user['_id'], userName: user['userName']),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
