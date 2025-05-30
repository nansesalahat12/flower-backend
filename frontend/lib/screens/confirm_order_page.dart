import 'cart_page.dart';
import 'package:flutter/material.dart';
import '../models/bouquet.dart';
import '../models/cart_item.dart';
class ConfirmOrderPage extends StatelessWidget {
  final String flower;
  final String wrapColor;
  final String message;
  final List<Bouquet> myBouquets;
  final List<CartItem> cartItems;
  const ConfirmOrderPage({
    Key? key,
    required this.flower,
    required this.wrapColor,
    required this.message,
    required this.cartItems,
    required this.myBouquets,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تأكيد الطلب'),
        backgroundColor: Colors.pink,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تفاصيل الباقة:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            Text('نوع الورد: $flower', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('لون التغليف: $wrapColor', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('العبارة المرفقة: $message', style: TextStyle(fontSize: 18)),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _showOrderConfirmed(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: Text('تأكيد الطلب', style: TextStyle(fontSize: 18)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: Text('تعديل', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderConfirmed(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('تم تأكيد الطلب!'),
            content: Text('شكراً لاختيارك حكاية ورد.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: Text('العودة للرئيسية'),
              ),
            ],
          ),
    );
  }
}
