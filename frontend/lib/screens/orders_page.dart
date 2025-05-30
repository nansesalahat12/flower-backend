import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List<dynamic> orders = [];
  bool isLoading = true;
  bool isError = false;
  String selectedStatus = 'all';

  Future<void> _fetchOrders() async {
    final String apiUrl = 'http://192.168.1.15:3000/api/orders';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          orders = jsonDecode(response.body);
          isLoading = false;
          isError = false;
        });
      } else {
        setState(() {
          isLoading = false;
          isError = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في جلب البيانات: ${response.statusCode}')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        isError = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في الاتصال بالخادم: $e')),
      );
    }
  }

  Future<void> _updateOrderStatus(String orderId, String status) async {
    final String apiUrl = 'http://192.168.1.15:3000/api/orders/approve';

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'orderId': orderId, 'status': status}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(status == 'approved' ? 'تمت الموافقة على الطلب' : 'تم رفض الطلب')),
        );
        _fetchOrders();
      } else {
        final decoded = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('⚠️ فشل في تحديث الطلب: ${decoded['message'] ?? decoded['error'] ?? 'غير معروف'}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ فشل في الاتصال بالخادم: $e')),
      );
    }
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return 'غير متوفر';
    final dateTime = DateTime.tryParse(isoDate);
    if (dateTime == null) return 'غير صالح';
    return '${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _translateStatus(String? status) {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'approved':
        return 'تمت الموافقة';
      case 'rejected':
        return 'تم الرفض';
      default:
        return 'غير محددة';
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = selectedStatus == 'all'
        ? orders
        : orders.where((order) => order['status'] == selectedStatus).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('الطلبات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchOrders,
            tooltip: 'تحديث',
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isError
              ? const Center(child: Text('حدث خطأ أثناء تحميل البيانات'))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: DropdownButtonFormField<String>(
                        value: selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'فلترة حسب الحالة',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('الكل')),
                          DropdownMenuItem(value: 'pending', child: Text('قيد الانتظار')),
                          DropdownMenuItem(value: 'approved', child: Text('تمت الموافقة')),
                          DropdownMenuItem(value: 'rejected', child: Text('تم الرفض')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedStatus = value!;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: filteredOrders.isEmpty
                          ? const Center(child: Text('لا توجد طلبات لهذه الحالة.'))
                          : ListView.builder(
                              itemCount: filteredOrders.length,
                              itemBuilder: (context, index) {
                                final order = filteredOrders[index];

                                return Card(
                                  margin: const EdgeInsets.all(10),
                                  child: ListTile(
                                    title: Text('العميل: ${order['customerName'] ?? 'غير معروف'}'),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('الهاتف: ${order['phone'] ?? 'غير متوفر'}'),
                                        Text('العنوان: ${order['address'] ?? 'غير متوفر'}'),
                                        Text.rich(
                                          TextSpan(
                                            text: 'الحالة: ',
                                            children: [
                                              TextSpan(
                                                text: _translateStatus(order['status']),
                                                style: TextStyle(
                                                  color: order['status'] == 'approved'
                                                      ? Colors.green
                                                      : order['status'] == 'rejected'
                                                          ? Colors.red
                                                          : Colors.orange,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text('السعر الإجمالي: ${(order['totalPrice'] ?? 0)} شيكل'),
                                        Text(
                                          'تاريخ الطلب: ${_formatDate(order['createdAt'])}',
                                          style: const TextStyle(color: Colors.grey),
                                        ),
                                        const SizedBox(height: 6),
                                        Text('الزهور:', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        ...(order['flowers'] as List).map((flower) {
                                          final name = flower['flowerName'] ?? 'غير معروف';
                                          final quantity = flower['quantity']?.toString() ?? '0';
                                          return Text('- $name (الكمية: $quantity)');
                                        }).toList(),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.check, color: Colors.green),
                                          onPressed: () => _updateOrderStatus(order['_id'], 'approved'),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close, color: Colors.red),
                                          onPressed: () => _updateOrderStatus(order['_id'], 'rejected'),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}
