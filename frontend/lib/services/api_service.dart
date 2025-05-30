import 'dart:convert';
import 'dart:io'; // لتعامل مع الملفات
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // لتحليل الملفات
import 'package:mime/mime.dart'; // لاكتشاف نوع MIME للملف
import 'package:frontend/models/product.dart';
import 'package:frontend/models/order.dart';

class ApiService {
  final String baseUrl = 'http://192.168.1.15:3000/api';

  // جلب جميع المنتجات
  Future<List<Product>> fetchAllProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((product) => Product.fromJson(product)).toList();
    } else {
      throw Exception('فشل في تحميل جميع المنتجات');
    }
  }

  // جلب المنتجات حسب اللون
  Future<List<Product>> fetchProductsByColor(String color) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/search-by-color?color=$color'),
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> productsJson = json.decode(response.body);
      return productsJson.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('فشل في تحميل المنتجات حسب اللون');
    }
  }

  // إضافة منتج جديد مع رفع الصورة
  Future<bool> addProduct(Product product, File? image) async {
    final uri = Uri.parse('$baseUrl/products');
    final request = http.MultipartRequest('POST', uri);

    // البيانات النصية
    request.fields['name'] = product.name;
    request.fields['price'] = product.price.toString();
    request.fields['description'] = product.description;
    request.fields['category'] = product.category;
    request.fields['color'] = product.color;

    // الصورة
    if (image != null) {
      final mimeType = lookupMimeType(image.path);
      final imageStream = http.ByteStream(image.openRead());
      final imageLength = await image.length();
      final multipartFile = http.MultipartFile(
        'image',
        imageStream,
        imageLength,
        filename: image.path.split('/').last,
        contentType: mimeType != null
            ? MediaType.parse(mimeType)
            : MediaType('application', 'octet-stream'),
      );
      request.files.add(multipartFile);
    }

    final response = await request.send();

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      print('فشل في الإضافة. كود الاستجابة: ${response.statusCode}');
      return false;
    }
  }

  // جلب الطلبات
  Future<List<Order>> fetchOrders() async {
    final response = await http.get(Uri.parse('$baseUrl/orders'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((order) => Order.fromJson(order)).toList();
    } else {
      throw Exception('فشل في تحميل الطلبات. الكود: ${response.statusCode}');
    }
  }

  // تحديث حالة الطلب (موافقة أو رفض)
  Future<void> updateOrderApproval(String id, bool approved) async {
    final response = await http.put(
      Uri.parse('$baseUrl/orders/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'approved': approved}),
    );

    if (response.statusCode != 200) {
      throw Exception('فشل في تحديث حالة الطلب');
    }
  }
}