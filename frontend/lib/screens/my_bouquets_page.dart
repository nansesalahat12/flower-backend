import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bouquet.dart';

class MyBouquetsPage extends StatefulWidget {
  final String? userId;
  final List<Bouquet>? bouquets; // اختيارية

  const MyBouquetsPage({Key? key, this.userId, this.bouquets}) : super(key: key);

  @override
  State<MyBouquetsPage> createState() => _MyBouquetsPageState();
}

class _MyBouquetsPageState extends State<MyBouquetsPage> {
  List<Bouquet> bouquets = [];
  bool isLoading = true;
  String userId = '';

  @override
  void initState() {
    super.initState();
    if (widget.bouquets != null) {
      bouquets = widget.bouquets!;
      isLoading = false;
    } else {
      loadUserAndFetchBouquets();
    }
  }

  Future<void> loadUserAndFetchBouquets() async {
    final prefs = await SharedPreferences.getInstance();
    userId = widget.userId ?? prefs.getString('userId') ?? '';
    if (userId.isEmpty) return;

    final url = Uri.parse('http://192.168.1.15:3000/api/bouquets/user/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      setState(() {
        bouquets = data.map((e) => Bouquet.fromJson(e)).toList();
        isLoading = false;
      });
    } else {
      print('فشل تحميل الباقات: ${response.body}');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('باقاتي'),
        backgroundColor: Colors.pink,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : bouquets.isEmpty
              ? const Center(child: Text('لا توجد باقات محفوظة'))
              : ListView.builder(
                  itemCount: bouquets.length,
                  itemBuilder: (context, index) {
                    final bouquet = bouquets[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: Image.network(
                          bouquet.imageUrl,
                          width: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.broken_image),
                        ),
                        title: Text(bouquet.name),
                        subtitle: Text('${bouquet.price} شيكل'),
                      ),
                    );
                  },
                ),
    );
  }
}
