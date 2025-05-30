import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatWithUserPage extends StatefulWidget {
  final String userId;
  final String userName;

  const ChatWithUserPage({Key? key, required this.userId, required this.userName}) : super(key: key);

  @override
  State<ChatWithUserPage> createState() => _ChatWithUserPageState();
}

class _ChatWithUserPageState extends State<ChatWithUserPage> {
  List<dynamic> messages = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  Future<void> fetchMessages() async {
    final url = Uri.parse('http://192.168.1.15:3000/api/chat/${widget.userId}');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      setState(() {
        messages = json.decode(res.body);
      });
    }
  }

  Future<void> sendMessage(String text) async {
    final url = Uri.parse('http://192.168.1.15:3000/api/chat/send');
    await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': widget.userId,
          'sender': 'admin',
          'message': text,
        }));
    _controller.clear();
    fetchMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الدردشة مع ${widget.userName}'),
        backgroundColor: Colors.pink,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isAdmin = msg['sender'] == 'admin';
                return Align(
                  alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      color: isAdmin ? Colors.blue[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(msg['message']),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: 'اكتب ردك...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_controller.text.trim().isNotEmpty) {
                      sendMessage(_controller.text.trim());
                    }
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
