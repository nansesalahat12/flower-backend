import 'package:flutter/material.dart';
import '../models/bouquet.dart';

class BouquetDetailsPage extends StatelessWidget {
  final Bouquet bouquet;

  const BouquetDetailsPage({Key? key, required this.bouquet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(bouquet.name),
        backgroundColor: Colors.pink,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
  Center(
  child: Image.network(
    bouquet.imageUrl,
    height: 200,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) =>
        const Icon(Icons.image_not_supported, size: 100),
  ),
),

             
              const SizedBox(height: 20),
              Text(
                bouquet.name,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                '${bouquet.price.toStringAsFixed(2)} شيكل',
                style: TextStyle(fontSize: 20, color: Colors.grey[700]),
              ),
              const SizedBox(height: 10),
              const Text(
                'الوصف:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                bouquet.description,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم إضافة الباقة إلى السلة')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                  ),
                  child: const Text('إضافة إلى السلة'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
