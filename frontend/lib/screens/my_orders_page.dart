import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MyOrdersPage extends StatefulWidget {
  final String userId;

  const MyOrdersPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  List<dynamic> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.15:3000/api/orders/${widget.userId}'),
    );

    if (response.statusCode == 200) {
      setState(() {
        orders = json.decode(response.body);
        isLoading = false;
      });
    } else {
      print('فشل تحميل الطلبات: ${response.body}');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طلباتي'),
        backgroundColor: Colors.pink,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(child: Text('لا يوجد طلبات حالياً'))
              : ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final items = order['items'] as List;

                    return Card(
                      margin: const EdgeInsets.all(10),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'طلب رقم ${index + 1}',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ...items.map((item) {
                              final name = item['productId']['name'] ?? 'اسم غير معروف';
                              final price = item['price'];
                              final quantity = item['quantity'];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('$name'),
                                    Text('$quantity × ${price.toStringAsFixed(2)} شيكل'),
                                  ],
                                ),
                              );
                            }).toList(),
                            const Divider(),
                            Text(
                              'المجموع: ${order['total'].toStringAsFixed(2)} شيكل',
                              style: const TextStyle(
                                  color: Colors.deepOrange,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
