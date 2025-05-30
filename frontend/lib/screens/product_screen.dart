import 'package:flutter/material.dart';
import 'package:frontend/models/product.dart';
import 'cart_page.dart';

class ProductDetailsPage extends StatelessWidget {
  final Product product;

  const ProductDetailsPage({Key? key, required this.product}) : super(key: key);

  Color _getColorFromName(String colorName) {
    final name = colorName.toLowerCase().trim();

    if (['احمر', 'أحمر', 'red'].contains(name)) return Colors.red;
    if (['ازرق', 'أزرق', 'blue'].contains(name)) return Colors.blue;
    if (['اصفر', 'أصفر', 'yellow'].contains(name)) return Colors.yellow;
    if (['اخضر', 'أخضر', 'green'].contains(name)) return Colors.green;
    if (['اسود', 'أسود', 'black'].contains(name)) return Colors.black;
    if (['ابيض', 'أبيض', 'white'].contains(name)) return Colors.white;

    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final colorDisplay = _getColorFromName(product.color);

    String imageUrl = product.imageUrl.startsWith('http')
        ? product.imageUrl
        : 'http://192.168.1.15/uploads/${product.imageUrl}';

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        backgroundColor: const Color(0xFFFFEEE7),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: product.imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              height: 220,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.image_not_supported, size: 100),
                            )
                          : const Icon(Icons.image, size: 100),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFFEEE7),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${product.price.toStringAsFixed(2)} شيكل',
                    style: TextStyle(fontSize: 20, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Text('اللون: ', style: TextStyle(fontSize: 18)),
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: colorDisplay,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black26),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(product.color, style: TextStyle(fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    'الوصف:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    product.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // هنا يمكن تضيف وظيفة الشراء أو الإضافة للسلة
                      },
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text('أضف إلى السلة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 166, 132, 117),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
