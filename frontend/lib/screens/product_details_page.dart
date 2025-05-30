import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'cart_page.dart';

import '../models/product.dart';
import '../models/cart_item.dart';
import 'product_details_page.dart';
import 'checkout_screen.dart';

class ProductDetailsPage extends StatefulWidget {
  final Product product;

  const ProductDetailsPage({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  List<Product> _relatedProducts = [];
  bool isFavorite = false;

  String getFullImageUrl(String imageFileName) {
    return imageFileName.startsWith('http')
        ? imageFileName
        : 'http://192.168.1.15:3000/uploads/$imageFileName';
  }

  @override
  void initState() {
    super.initState();
    fetchRelatedProducts();
  }

  Future<void> fetchRelatedProducts() async {
    final url = Uri.parse(
        'http://192.168.1.15:3000/api/products?category=${widget.product.category}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> productsData = data['data'];

      final List<Product> all = productsData
          .map((json) => Product.fromJson(json))
          .where((p) => p.id != widget.product.id)
          .toList();

      setState(() {
        _relatedProducts = all;
      });
    }
  }

  Future<void> addToCart() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? '';

    if (userId.isEmpty) {
      List<String> localCart = prefs.getStringList('localCart') ?? [];

      bool alreadyExists = localCart.any((item) {
        final map = jsonDecode(item);
        return map['id'] == widget.product.id;
      });

      if (!alreadyExists) {
        localCart.add(jsonEncode({
          'id': widget.product.id,
          'name': widget.product.name,
          'price': widget.product.price,
          'imageUrl': widget.product.imageUrl,
          'category': widget.product.category,
          'color': widget.product.color,
        }));
        await prefs.setStringList('localCart', localCart);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.product.name} تمت إضافته للسلة (مؤقتًا)')),
      );
    } else {
      final url = Uri.parse('http://192.168.1.15:3000/cart/add');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'productId': widget.product.id,
          'quantity': 1,
        }),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تمت الإضافة إلى السلة')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        backgroundColor: const Color(0xFFFFEEE7),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                isFavorite = !isFavorite;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isFavorite ? 'تمت الإضافة إلى المفضلة' : 'تمت الإزالة من المفضلة',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                getFullImageUrl(product.imageUrl),
                height: 250,
                width: double.infinity,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.image_not_supported, size: 100),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              product.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              '${product.price.toStringAsFixed(2)} شيكل',
              style: TextStyle(
                fontSize: 20,
                color: Colors.teal[700],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            const Text('الوصف:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(
              product.description,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => addToCart(),
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text('إضافة إلى السلة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 191, 161, 148),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      final userId = prefs.getString('userId') ?? "زائر";

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CheckoutScreen(
                            cartItems: [
                              CartItem(
                                id: widget.product.id,
                                product: widget.product,
                                quantity: 1,
                              ),
                            ],
                            userId: userId,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 154, 116, 98),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('اطلب الآن', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            if (_relatedProducts.isNotEmpty) ...[
              const Text('منتجات مشابهة',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              SizedBox(
                height: 230,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _relatedProducts.length,
                  itemBuilder: (context, index) {
                    final p = _relatedProducts[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailsPage(product: p),
                          ),
                        );
                      },
                      child: Container(
                        width: 160,
                        margin: const EdgeInsets.only(right: 12),
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                child: Image.network(
                                  getFullImageUrl(p.imageUrl),
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.broken_image, size: 60),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text('${p.price} شيكل',
                                        style: const TextStyle(color: Colors.teal)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
