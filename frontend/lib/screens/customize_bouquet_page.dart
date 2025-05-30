// ✅ كامل الكود المعدل بدون حذف
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '✅ ThankYouPage.dart';

class CustomBouquetPage extends StatefulWidget {
  final String customerName;

  const CustomBouquetPage({required this.customerName, Key? key}) : super(key: key);

  @override
  State<CustomBouquetPage> createState() => _CustomBouquetPageState();
}

class _CustomBouquetPageState extends State<CustomBouquetPage> {
  final List<Map<String, String>> flowers = [
    {'image': 'assets/white.png', 'name': 'أبيض'},
    {'image': 'assets/tulip.png', 'name': 'توليب'},
    {'image': 'assets/lily.png', 'name': 'زنبق'},
    {'image': 'assets/sunflower.png', 'name': 'دوار الشمس'},
  ];

  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  Map<String, int> bouquet = {};
  String? selectedWrap;
  String? selectedRibbon;
  String? ribbonText = '';
  String orderMessage = '';
  String selectedPayment = 'عند الاستلام';
  bool isDepositOnly = true;

  final List<String> wrapOptions = ['كرتون وردي', 'سيلوفان شفاف', 'قماش كتان'];
  final List<String> ribbonOptions = ['وردي', 'ذهبي', 'أبيض'];

  @override
  void dispose() {
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  int getTotalFlowers() => bouquet.values.fold(0, (sum, count) => sum + count);

  void clearOrder() {
    setState(() {
      bouquet.clear();
      selectedWrap = null;
      selectedRibbon = null;
      ribbonText = '';
      orderMessage = '';
    });
  }

  String getWrapImagePath(String wrap) => 'assets/wraps/${wrap.replaceAll(' ', '_')}.png';
  String getRibbonImagePath(String ribbon) => 'assets/ribbons/${ribbon}_ribbon.png';

  Future<void> sendOrderWithInfo({required String phone, required String address, required String paymentMethod}) async {
    final String apiUrl = 'http://192.168.1.15:3000/api/orders';

    final List<Map<String, dynamic>> flowerList = bouquet.entries.map((entry) {
      final flower = flowers.firstWhere((f) => f['image'] == entry.key);
      return {
        "flowerName": flower['name'],
        "quantity": entry.value,
        "price": 25,
      };
    }).toList();

    final int totalPriceRaw = flowerList.fold(0, (sum, f) => sum + ((f['quantity'] as int) * (f['price'] as int)));
    final int totalPrice = isDepositOnly ? 30 : totalPriceRaw;

    final Map<String, dynamic> orderData = {
      "customerName": widget.customerName,
      "phone": phone,
      "address": address,
      "flowers": flowerList,
      "totalPrice": totalPrice,
      "status": "in_progress",
      "wrap": selectedWrap,
      "ribbon": selectedRibbon,
      "ribbonText": ribbonText,
      "message": orderMessage,
      "paymentMethod": paymentMethod,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(orderData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        final String orderId = responseBody['_id'] ?? responseBody['order']?['_id'] ?? '---';

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ThankYouPage(userName: widget.customerName, orderId: orderId),
          ),
        );

        clearOrder();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في إرسال الطلب: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في الاتصال بالخادم: $e')),
      );
    }
  }

  void _showPreviewDialog(String phone, String address, String paymentMethod) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('معاينة الباقة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('📱 الهاتف: $phone'),
            Text('📍 العنوان: $address'),
            Text('💳 الدفع: $paymentMethod'),
            const SizedBox(height: 10),
            if (selectedWrap != null) Image.asset(getWrapImagePath(selectedWrap!), height: 40),
            if (selectedRibbon != null) Image.asset(getRibbonImagePath(selectedRibbon!), height: 40),
            const SizedBox(height: 10),
            ...bouquet.entries.map((entry) {
              final flower = flowers.firstWhere((f) => f['image'] == entry.key);
              return Text('${flower['name']}: ${entry.value}');
            }),
            const SizedBox(height: 10),
            Text('💰 السعر الإجمالي: ${isDepositOnly ? 30 : bouquet.values.fold(0, (sum, q) => sum + (q * 25))} ₪'),
          ],
        ),
        actions: [
          TextButton(child: const Text('رجوع'), onPressed: () => Navigator.pop(context)),
          ElevatedButton(
            child: const Text('تأكيد الطلب'),
            onPressed: () {
              Navigator.pop(context);
              sendOrderWithInfo(phone: phone, address: address, paymentMethod: paymentMethod);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDialog() {
    return AlertDialog(
      title: const Text('معلومات إضافية'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'رقم الهاتف'),
              keyboardType: TextInputType.phone,
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
              items: ['عند الاستلام', 'بطاقة بنكية'].map((method) {
                return DropdownMenuItem(value: method, child: Text(method));
              }).toList(),
              onChanged: (value) => setState(() => selectedPayment = value!),
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              title: const Text('الدفع عربون فقط (30 شيكل)'),
              value: isDepositOnly,
              onChanged: (value) => setState(() => isDepositOnly = value),
            ),
            if (selectedRibbon != null)
              TextField(
                decoration: const InputDecoration(labelText: 'اكتب على الشريط (اختياري)'),
                onChanged: (value) => ribbonText = value,
              ),
            const SizedBox(height: 10),
            TextFormField(
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'رسالة مرفقة (اختياري)',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => orderMessage = value,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(child: const Text('رجوع'), onPressed: () => Navigator.pop(context)),
        ElevatedButton(
          child: const Text('معاينة الباقة'),
          onPressed: () {
            Navigator.pop(context);
            _showPreviewDialog(phoneController.text, addressController.text, selectedPayment);
          },
        ),
      ],
    );
  }

  Widget buildOrderButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: bouquet.isNotEmpty
            ? () => showDialog(context: context, builder: (_) => _buildOrderDialog())
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: bouquet.isNotEmpty ? Colors.green : Colors.grey,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: const Text('إتمام الباقة', style: TextStyle(fontSize: 18, color: Colors.white)),
      ),
    );
  }

  Widget buildFlowerAndOptionsGrid() {
    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(8),
              children: [
                ...flowers.map((flower) => Draggable<Map>(
                      data: {'type': 'flower', 'value': flower['image']!},
                      feedback: Image.asset(flower['image']!, height: 50),
                      child: Column(
                        children: [
                          Image.asset(flower['image']!, height: 70),
                          Text(flower['name']!),
                        ],
                      ),
                    )),
                ...wrapOptions.map((wrap) => Draggable<Map>(
                      data: {'type': 'wrap', 'value': wrap},
                      feedback: Image.asset(getWrapImagePath(wrap), height: 50),
                      child: Column(
                        children: [
                          Image.asset(getWrapImagePath(wrap), height: 50),
                          Text(wrap),
                        ],
                      ),
                    )),
                ...ribbonOptions.map((ribbon) => Draggable<Map>(
                      data: {'type': 'ribbon', 'value': ribbon},
                      feedback: Image.asset(getRibbonImagePath(ribbon), height: 40),
                      child: Column(
                        children: [
                          Image.asset(getRibbonImagePath(ribbon), height: 40),
                          Text(ribbon),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          // ✅ السلة المعدلة لتجنب overflow
          DragTarget<Map>(
            onAccept: (data) {
              setState(() {
                if (data['type'] == 'flower') {
                  bouquet[data['value']] = (bouquet[data['value']] ?? 0) + 1;
                } else if (data['type'] == 'wrap') {
                  selectedWrap = data['value'];
                } else if (data['type'] == 'ribbon') {
                  selectedRibbon = data['value'];
                }
              });
            },
            builder: (context, candidateData, rejectedData) {
              return Container(
                width: 130,
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.pink[50],
                  border: Border.all(color: Colors.pink),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Text('🧺 سلتك'),
                      const SizedBox(height: 10),
                      ...bouquet.entries.map((entry) {
                        final flower = flowers.firstWhere((f) => f['image'] == entry.key);
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(entry.key, height: 30),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${flower['name']}: ${entry.value}',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.red, size: 20),
                              onPressed: () {
                                setState(() {
                                  bouquet[entry.key] = bouquet[entry.key]! - 1;
                                  if (bouquet[entry.key]! <= 0) bouquet.remove(entry.key);
                                });
                              },
                            ),
                          ],
                        );
                      }).toList(),
                      if (selectedWrap != null) ...[
                        const Divider(),
                        const Text('تغليف'),
                        Image.asset(getWrapImagePath(selectedWrap!), height: 40),
                      ],
                      if (selectedRibbon != null) ...[
                        const Divider(),
                        const Text('شريط'),
                        Image.asset(getRibbonImagePath(selectedRibbon!), height: 30),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F0),
      appBar: AppBar(title: const Text('صمم باقتك')),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Text('🌸 إجمالي الورود: ${getTotalFlowers()}', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          buildFlowerAndOptionsGrid(),
          buildOrderButton(),
        ],
      ),
    );
  }
}
