import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final String userId;

  const CheckoutScreen({Key? key, required this.cartItems, required this.userId}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool isSubmitting = false;

  double get totalAmount =>
      widget.cartItems.fold(0, (sum, item) => sum + item.totalPrice);

  Future<void> sendOrder({
    required String name,
    required String phone,
    required String address,
    required String paymentMethod,
  }) async {
    setState(() => isSubmitting = true);

    final List<Map<String, dynamic>> flowers = widget.cartItems.map((item) {
      return {
        'flowerName': item.product.name,
        'price': item.product.price,
        'quantity': item.quantity,
      };
    }).toList();

    final body = {
      'customerName': name,
      'phone': phone,
      'address': address,
      'flowers': flowers,
      'totalPrice': totalAmount,
      'paymentMethod': paymentMethod,
      if (widget.userId != "زائر") 'userId': widget.userId,
    };

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.15:3000/api/orders'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (widget.userId != "زائر") {
          await http.delete(
            Uri.parse('http://192.168.1.15:3000/cart/clear/${widget.userId}'),
          );
        } else {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('guestCart');
        }

        setState(() => isSubmitting = false);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ تم إرسال الطلب بنجاح')),
        );

        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        setState(() => isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ فشل: ${response.body}')),
        );
      }
    } catch (e) {
      setState(() => isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ خطأ في الاتصال: $e')),
      );
    }
  }

  void _showCheckoutDialog() {
    final nameController = TextEditingController(text: widget.userId == "زائر" ? "" : widget.userId);
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    final cardNameController = TextEditingController();
    final cardPasswordController = TextEditingController();

    String selectedPayment = 'كاش عند التسليم';
    bool showCardFields = false;
    bool showPayPalButton = false;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('معلومات التوصيل'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  if (widget.userId == "زائر")
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'الاسم الكامل'),
                    ),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'رقم الهاتف'),
                    keyboardType: TextInputType.phone,
                  ),
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: 'العنوان'),
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedPayment,
                    decoration: const InputDecoration(labelText: 'طريقة الدفع'),
                    items: ['كاش عند التسليم', 'بطاقة ائتمان (Visa)'].map((method) {
                      return DropdownMenuItem(value: method, child: Text(method));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedPayment = value!;
                        showCardFields = selectedPayment == 'بطاقة ائتمان (Visa)';
                        showPayPalButton = selectedPayment == 'بطاقة ائتمان (Visa)';
                      });
                    },
                  ),
                  if (showCardFields) ...[
                    const SizedBox(height: 10),
                    TextField(
                      controller: cardNameController,
                      decoration: const InputDecoration(labelText: 'اسم الحساب على البطاقة'),
                    ),
                    TextField(
                      controller: cardPasswordController,
                      decoration: const InputDecoration(labelText: 'الرقم السري'),
                      obscureText: true,
                    ),
                  ],
                  if (showPayPalButton)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('🚧 الدفع عبر PayPal غير متاح حاليًا')),
                          );
                        },
                        icon: const Icon(Icons.payment),
                        label: const Text('الدفع عبر PayPal'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  final phone = phoneController.text.trim();
                  final address = addressController.text.trim();

                  if (name.isEmpty || phone.isEmpty || address.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('يرجى تعبئة جميع الحقول')),
                    );
                    return;
                  }

                  if (showCardFields &&
                      (cardNameController.text.trim().isEmpty ||
                          cardPasswordController.text.trim().isEmpty)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('يرجى تعبئة بيانات البطاقة')),
                    );
                    return;
                  }

                  Navigator.pop(context); // إغلاق البوكس

                  Future.delayed(const Duration(milliseconds: 100), () {
                    sendOrder(
                      name: name,
                      phone: phone,
                      address: address,
                      paymentMethod: selectedPayment,
                    );
                  });
                },
                child: const Text('تأكيد الطلب'),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تأكيد الطلب')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('تفاصيل السلة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: widget.cartItems.map((item) {
                  return ListTile(
                    title: Text(item.product.name),
                    subtitle: Text('الكمية: ${item.quantity}'),
                    trailing: Text('${item.totalPrice.toStringAsFixed(2)} ش'),
                  );
                }).toList(),
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('الإجمالي:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('${totalAmount.toStringAsFixed(2)} شيكل'),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isSubmitting ? null : _showCheckoutDialog,
              child: isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('إتمام الطلب'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
