import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import 'product_details_page.dart';

class ProductSearchPage extends StatefulWidget {
  @override
  _ProductSearchPageState createState() => _ProductSearchPageState();
}

class _ProductSearchPageState extends State<ProductSearchPage> {
  TextEditingController searchController = TextEditingController();
  List<Product> products = [];
  bool isLoading = false;

  String getFullImageUrl(String imageFileName) {
    return 'http://192.168.1.15:3000/uploads/$imageFileName';
  }

  Future<void> searchProducts(String query) async {
    try {
      setState(() => isLoading = true);

      final response = await http.get(
        Uri.parse('http://192.168.1.15:3000/api/products/search?query=$query'),
      );

      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'];

        setState(() {
          products = data.map((item) => Product.fromJson(item)).toList();
        });
      } else {
        throw Exception('فشل تحميل المنتجات');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e')),
      );
    }
  }

  Future<void> addToCartOnline(Product product) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? '';

    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى تسجيل الدخول لإضافة منتجات للسلة')),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('http://192.168.1.15:3000/cart/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "userId": userId,
        "productId": product.id,
        "quantity": 1,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product.name} تمت إضافته إلى السلة')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في الإضافة إلى السلة')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ابحث عن المنتجات'),
        backgroundColor: const Color(0xFFFFEEE7),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'أدخل كلمة البحث',
                hintText: 'مثال: أحمر، ورد، باقة، عيد ميلاد...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFEEE7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                String query = searchController.text.trim();
                if (query.isNotEmpty) {
                  searchProducts(query);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('يرجى إدخال كلمة البحث أولاً')),
                  );
                }
              },
              icon: Icon(Icons.search),
              label: Text('ابحث'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : products.isEmpty
                      ? Center(child: Text('لا توجد منتجات تطابق البحث'))
                      : ListView.builder(
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                            final imageUrl = getFullImageUrl(product.imageUrl);

                            return Card(
                              elevation: 4,
                              margin: EdgeInsets.symmetric(vertical: 8),
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        imageUrl,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            Icon(Icons.broken_image),
                                      ),
                                    ),
                                    title: Text(product.name),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('السعر: ${product.price} شيكل'),
                                        Text('الوصف: ${product.description}'),
                                      ],
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ProductDetailsPage(product: product),
                                        ),
                                      );
                                    },
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                    child: ElevatedButton(
                                      onPressed: () => addToCartOnline(product),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(255, 242, 168, 193),
                                        minimumSize: Size(double.infinity, 40),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                      child: const Text("أضف للسلة"),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
