// ✅ نسخة ذكية من CategoryProductsPage تقبل جميع أنواع الفلاتر
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class CategoryProductsPage extends StatefulWidget {
  const CategoryProductsPage({Key? key}) : super(key: key);

  @override
  State<CategoryProductsPage> createState() => _CategoryProductsPageState();
}

class _CategoryProductsPageState extends State<CategoryProductsPage> {
  late Future<List<Product>> _productsFuture;
  String filter = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      filter = ModalRoute.of(context)!.settings.arguments as String;
      setState(() {
        _productsFuture = fetchProductsByFilter(filter);
      });
    });
  }

  Future<List<Product>> fetchProductsByFilter(String filter) async {
    String endpoint = 'http://192.168.1.15:3000/api/products';

    if (filter == 'exclusive') {
      endpoint += '?exclusive=true';
    } else if (filter == 'best_seller') {
      endpoint += '?best_seller=true';
    } else if (filter == 'top_pick') {
      endpoint += '?top_pick=true';
    } else if (filter == 'newest') {
      endpoint += '?sort=newest';
    } else if (filter != 'all') {
      endpoint += '?category=${Uri.encodeComponent(filter)}';
    }

    final response = await http.get(Uri.parse(endpoint));
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List jsonList = decoded['data'];
      return jsonList.map((jsonItem) => Product.fromJson(jsonItem)).toList();
    } else {
      throw Exception('فشل في جلب المنتجات');
    }
  }

  Future<void> addToCart(Product product) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null || userId.isEmpty) {
      List<String> localCart = prefs.getStringList('localCart') ?? [];

      bool alreadyExists = localCart.any((item) {
        final map = jsonDecode(item);
        return map['id'] == product.id;
      });

      if (alreadyExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${product.name} موجود بالفعل في السلة')),
        );
        return;
      }

      localCart.add(jsonEncode({
        'id': product.id,
        'name': product.name,
        'price': product.price,
        'imageUrl': product.imageUrl,
        'category': product.category,
        'color': product.color,
      }));

      await prefs.setStringList('localCart', localCart);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product.name} تمت إضافته للسلة (مؤقتًا)')),
      );
    } else {
      final url = Uri.parse('http://192.168.1.15:3000/cart/add');

      try {
        final response = await http.post(
          url,
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
        } else if (response.statusCode == 409) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${product.name} موجود بالفعل في السلة')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل في الإضافة: ${response.body}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في الاتصال: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          filter == 'exclusive'
              ? 'عروض حصرية'
              : filter == 'best_seller'
                  ? 'الأكثر مبيعًا'
                  : filter == 'top_pick'
                      ? 'اختياراتنا'
                      : filter == 'newest'
                          ? 'جديدنا'
                          : filter,
        ),
        backgroundColor: Colors.pink,
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('لا توجد منتجات في هذه الفئة'));
          } else {
            final products = snapshot.data!;
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.65,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                final imageUrl = product.fullImageUrl;

                return InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/product_details', arguments: product);
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: Image.network(
                            imageUrl,
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, size: 80),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
                          child: Text(
                            product.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('${product.price} شيكل',
                              style: const TextStyle(color: Colors.grey, fontSize: 13)),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () => addToCart(product),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 242, 168, 193),
                              minimumSize: const Size(double.infinity, 36),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text('أضف للسلة', style: TextStyle(fontSize: 13)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
