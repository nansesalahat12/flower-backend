
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/product.dart';
import '../models/cart_item.dart';
import 'product_details_page.dart';
import 'checkout_screen.dart';

class ReadyProductsPage extends StatefulWidget {
  final String? category;

  const ReadyProductsPage({Key? key, this.category}) : super(key: key);

  @override
  State<ReadyProductsPage> createState() => _ReadyProductsPageState();
}

class _ReadyProductsPageState extends State<ReadyProductsPage> {
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = fetchProducts();
  }

  Future<List<Product>> fetchProducts() async {
    final baseUrl = 'http://192.168.1.15:3000/api/products';
    final url = widget.category != null
        ? Uri.parse('$baseUrl?category=${widget.category}')
        : Uri.parse(baseUrl);

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> productList = data['data'];
      return productList.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('فشل في تحميل المنتجات');
    }
  }

  String getFullImageUrl(String imageFileName) {
    return imageFileName.startsWith('http')
        ? imageFileName
        : 'http://192.168.1.15:3000/uploads/$imageFileName';
  }

  Future<void> addToCartOnline(Product product) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? '';

    if (userId.isEmpty) {
      final cartData = prefs.getStringList('guestCart') ?? [];

      final existingIndex = cartData.indexWhere((item) {
        final map = json.decode(item);
        return map['id'] == product.id;
      });

      if (existingIndex != -1) {
        final existing = json.decode(cartData[existingIndex]);
        existing['quantity'] += 1;
        cartData[existingIndex] = json.encode(existing);
      } else {
        final newItem = json.encode({
          'id': product.id,
          'name': product.name,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'quantity': 1,
        });
        cartData.add(newItem);
      }

      await prefs.setStringList('guestCart', cartData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product.name} أُضيف إلى سلة الزائر')),
      );
      return;
    }

    final url = Uri.parse('http://192.168.1.15:3000/cart');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userId': userId,
        'productId': product.id,
        'quantity': 1,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product.name} أُضيف إلى السلة')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل في الإضافة إلى السلة')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category != null
            ? "منتجات: ${widget.category}"
            : "كل المنتجات"),
        backgroundColor: const Color(0xFFFFEEE7),
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('لا توجد منتجات حالياً.'));
          }

          final products = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: GridView.builder(
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
                final product = products[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailsPage(product: product),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                            child: Image.network(
                              getFullImageUrl(product.imageUrl),
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.broken_image, size: 50),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${product.price} شيكل',
                                style: const TextStyle(
                                  color: Colors.teal,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ElevatedButton(
                                    onPressed: () => addToCartOnline(product),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF8B5E3C),
                                      minimumSize: const Size.fromHeight(36),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    child: const Text(
                                      'أضف إلى السلة',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: () async {
                                      final prefs = await SharedPreferences.getInstance();
                                      final userId = prefs.getString('userId') ?? "زائر";

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => CheckoutScreen(
                                            cartItems: [
                                              CartItem(
                                                id: product.id,
                                                product: product,
                                                quantity: 1,
                                              ),
                                            ],
                                            userId: userId,
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFF2A8C1),
                                      minimumSize: const Size.fromHeight(36),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    child: const Text(
                                      'اطلب الآن',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
