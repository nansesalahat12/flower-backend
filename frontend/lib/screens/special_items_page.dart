import 'package:flutter/material.dart';

class SpecialOrderPage extends StatefulWidget {
  @override
  _SpecialOrderPageState createState() => _SpecialOrderPageState();
}

class _SpecialOrderPageState extends State<SpecialOrderPage> {
  final TextEditingController specialItemController = TextEditingController(); // ✅ اسم الباقة
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  DateTime? selectedDate;

  void sendSpecialOrder() {
    if (specialItemController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        phoneController.text.isEmpty ||
        selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى تعبئة جميع الحقول المطلوبة')),
      );
      return;
    }

    // 👇 هنا تقدر ترسل الطلب للسيرفر أو Firebase
    // FirebaseFirestore.instance.collection('special_orders').add({...});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم إرسال الطلب بنجاح')),
    );
    Navigator.pop(context);
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('طلب خاص'), backgroundColor: Colors.pink),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: specialItemController,
              decoration: InputDecoration(
                labelText: 'اسم الباقة الخاصة',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'وصف الطلب',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: 'رقم الهاتف',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16),
            ListTile(
              title: Text(
                selectedDate == null
                    ? 'اختر تاريخ التوصيل'
                    : 'تاريخ التوصيل: ${selectedDate!.toLocal().toString().split(' ')[0]}',
              ),
              trailing: Icon(Icons.calendar_today),
              onTap: pickDate,
            ),
            SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                labelText: 'ملاحظات إضافية (اختياري)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: sendSpecialOrder,
              child: Text('إرسال الطلب'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
            ),
          ],
        ),
      ),
    );
  }
}
