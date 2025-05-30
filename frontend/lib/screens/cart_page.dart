
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/cart_item.dart';
import '../models/product.dart';

class CartPage extends StatefulWidget {
  final String userId;

  const CartPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<CartItem> cartItems = [];
  bool isLoading = true;
  bool isSubmitting = false;

  String customerName = '';
  String phone = '';
  String address = '';
  String selectedPayment = 'كاش عند التسليم';

  @override
  void initState() {
    super.initState();
    print("📦 فتح صفحة السلة للمستخدم: \${widget.userId}");

    if (widget.userId.trim().isEmpty || widget.userId == 'زائر') {
      loadGuestCart();
    } else {
      fetchCart();
    }
  }

  Future<void> loadGuestCart() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> localCart = prefs.getStringList('localCart') ?? [];

    final items = localCart.map((itemJson) {
      final map = jsonDecode(itemJson);
      return CartItem.fromJson(map);
    }).toList();

    setState(() {
      cartItems = items;
      isLoading = false;
    });
  }

  Future<void> fetchCart() async {
    if (widget.userId.trim().isEmpty || widget.userId == 'زائر') {
      print("⛔️ تم إلغاء طلب السلة بسبب userId غير صالح: \${widget.userId}");
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.15:3000/cart/\${widget.userId}'),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List items = decoded['items'] ?? [];

        setState(() {
          cartItems = items.map((e) => CartItem.fromJson(e)).toList();
          isLoading = false;
        });
      } else {
        print("❌ فشل تحميل السلة: \${response.body}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("❌ استثناء أثناء تحميل السلة: \$e");
      setState(() => isLoading = false);
    }
  }

  double get totalAmount => cartItems.fold(0, (sum, item) => sum + item.totalPrice);

  void updateQuantity(int index, int newQuantity) async {
    if (newQuantity < 1) return;

    setState(() {
      cartItems[index].quantity = newQuantity;
    });

    if (widget.userId == 'زائر') {
      final prefs = await SharedPreferences.getInstance();
      final updated = cartItems.map((item) => jsonEncode(item.toJson())).toList();
      await prefs.setStringList('localCart', updated);
    } else {
      await http.put(
        Uri.parse('http://192.168.1.15:3000/cart/update'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': widget.userId,
          'productId': cartItems[index].product.id,
          'quantity': newQuantity
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🛒 سلة المشتريات'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
              ? const Center(child: Text('السلة فارغة'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: item.product.imageUrl.isNotEmpty
                          ? Image.network(item.product.fullImageUrl, width: 60, height: 60)
                          : const Icon(Icons.image, size: 60),
                        title: Text(item.product.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('السعر: \${item.totalPrice.toStringAsFixed(2)} شيكل'),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () => updateQuantity(index, item.quantity - 1),
                                ),
                                Text('\${item.quantity}'),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () => updateQuantity(index, item.quantity + 1),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            if (widget.userId == 'زائر') {
                              final prefs = await SharedPreferences.getInstance();
                              final List<String> localCart = prefs.getStringList('localCart') ?? [];
                              localCart.removeWhere((itemJson) {
                                final map = jsonDecode(itemJson);
                                return map['productId']['id'] == item.product.id;
                              });
                              await prefs.setStringList('localCart', localCart);
                              setState(() => cartItems.removeAt(index));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('🗑️ تم حذف المنتج من السلة')),
                              );
                            } else {
                              await http.delete(
                                Uri.parse('http://192.168.1.15:3000/cart/remove'),
                                headers: {'Content-Type': 'application/json'},
                                body: jsonEncode({
                                  'userId': widget.userId,
                                  'productId': item.product.id
                                }),
                              );
                              fetchCart();
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: cartItems.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: ElevatedButton(
                onPressed: isSubmitting ? null : showCheckoutDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('إتمام الشراء (المجموع: \${totalAmount.toStringAsFixed(2)} شيكل)')
              ),
            ),
    );
  }

  void showCheckoutDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تفاصيل الطلب'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              if (widget.userId == "زائر") ...[
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'الاسم الكامل'),
                ),
                const SizedBox(height: 10),
              ],
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'رقم الهاتف'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'العنوان'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'طريقة الدفع'),
                value: selectedPayment,
                items: ['كاش عند التسليم', 'بطاقة ائتمان (Visa)'].map((method) {
                  return DropdownMenuItem(value: method, child: Text(method));
                }).toList(),
                onChanged: (value) => selectedPayment = value!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('إلغاء'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('تأكيد'),
            onPressed: () {
              if (widget.userId == "زائر") customerName = nameController.text;
              phone = phoneController.text;
              address = addressController.text;
              Navigator.pop(context);
              Future.delayed(const Duration(milliseconds: 100), submitOrderWithInfo);
            },
          ),
        ],
      ),
    );
  }

  Future<void> submitOrderWithInfo() async {
    setState(() => isSubmitting = true);
    try {
      final isGuest = widget.userId == "زائر";
      final orderData = {
        'customerName': isGuest ? customerName : widget.userId,
        'phone': phone,
        'address': address,
        'flowers': cartItems.map((item) => {
          "flowerName": item.product.name,
          "quantity": item.quantity,
          "price": item.product.price,
        }).toList(),
        'totalPrice': totalAmount,
        'paymentMethod': selectedPayment,
        if (!isGuest) 'userId': widget.userId,
      };

      final response = await http.post(
        Uri.parse('http://192.168.1.15:3000/api/orders'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(orderData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (isGuest) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('localCart');
        } else {
          await http.delete(Uri.parse('http://192.168.1.15:3000/cart/clear/\${widget.userId}'));
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
          SnackBar(content: Text('❌ فشل إرسال الطلب: \${response.body}')),
        );
      }
    } catch (e) {
      setState(() => isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ فشل في إرسال الطلب: \$e')),
      );
    }
  }
}
