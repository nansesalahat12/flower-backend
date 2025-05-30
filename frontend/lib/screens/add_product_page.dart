import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/models/product.dart';
import 'package:frontend/services/api_service.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({Key? key}) : super(key: key);

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();
  final categoryController = TextEditingController();
  final colorController = TextEditingController();
  final stockController = TextEditingController();

  final apiService = ApiService();
  bool _isLoading = false;
  File? _image;
  final ImagePicker _picker = ImagePicker();

  // الحقول الإضافية
  bool isExclusive = false;
  bool isBestSeller = false;
  bool isTopPick = false;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<void> _submitProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final product = Product(
          name: nameController.text,
          price: double.tryParse(priceController.text) ?? 0,
          description: descriptionController.text,
          imageUrl: '', // سيُضاف تلقائياً من السيرفر
          category: categoryController.text,
          color: colorController.text,
          exclusive: isExclusive,
          bestSeller: isBestSeller,
          topPick: isTopPick,
          stock: int.tryParse(stockController.text) ?? 0,
        );

        final success = await apiService.addProduct(product, _image);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تمت إضافة المنتج بنجاح')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('فشل في إضافة المنتج')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة منتج')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(controller: nameController, label: 'اسم المنتج'),
              _buildTextField(
                controller: priceController,
                label: 'السعر',
                isNumber: true,
                validator: _validatePrice,
              ),
              _buildTextField(controller: descriptionController, label: 'الوصف'),
              _buildTextField(controller: categoryController, label: 'الفئة'),
              _buildTextField(controller: colorController, label: 'اللون'),
              _buildTextField(
                controller: stockController,
                label: 'الكمية المتوفرة',
                isNumber: true,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _image == null
                      ? const Center(child: Icon(Icons.add_a_photo, size: 40))
                      : Image.file(_image!, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('منتج حصري (Exclusive)'),
                value: isExclusive,
                onChanged: (value) => setState(() => isExclusive = value ?? false),
              ),
              CheckboxListTile(
                title: const Text('الأكثر مبيعاً (Best Seller)'),
                value: isBestSeller,
                onChanged: (value) => setState(() => isBestSeller = value ?? false),
              ),
              CheckboxListTile(
                title: const Text('خيار مميز (Top Pick)'),
                value: isTopPick,
                onChanged: (value) => setState(() => isTopPick = value ?? false),
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'إضافة المنتج',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isNumber = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: validator ??
            (value) => value == null || value.isEmpty ? 'هذا الحقل مطلوب' : null,
      ),
    );
  }

  String? _validatePrice(String? value) {
    if (value == null || value.isEmpty) return 'هذا الحقل مطلوب';
    if (double.tryParse(value) == null) return 'يرجى إدخال سعر صالح';
    return null;
  }
}
