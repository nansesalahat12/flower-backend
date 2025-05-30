import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/product.dart';
import '../models/cart_item.dart';
import 'customize_bouquet_page.dart';
import 'ready_products_page.dart';
import 'cart_page.dart' as cart_ui;
import 'product_search_page.dart';
import 'product_details_page.dart';
import 'customer_reviews_page.dart';
import 'profilepage.dart';
import 'login_page.dart';

class MainHomePage extends StatefulWidget {
  final String userName;
  final int initialTabIndex;

  const MainHomePage({Key? key, required this.userName, this.initialTabIndex = 0}) : super(key: key);

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  List<Product> products = [];
  List<Product> exclusiveProducts = [];
  List<Product> bestSellingProducts = [];
  List<CartItem> cartItems = [];
  List<Product> newestProducts = [];

  late int _selectedIndex;
  int _currentSlide = 0;
  bool isLoggedIn = false;
  String? userId;
  int cartCount = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTabIndex;
    fetchProducts();
    fetchExclusiveProducts();
    fetchBestSellingProducts();
    checkLoginStatus();
    updateCartCount();
    fetchNewProducts();
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    checkLoginStatus();
    updateCartCount();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('userId');
    setState(() {
      isLoggedIn = id != null && id.isNotEmpty;
      userId = id;
    });
  }

  Future<void> updateCartCount() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('userId');

    if (id == null || id.isEmpty) {
      final localCart = prefs.getStringList('localCart') ?? [];
      setState(() {
        cartCount = localCart.length;
      });
    } else {
      final response = await http.get(
        Uri.parse('http://192.168.1.15:3000/cart/$id'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List items = data['items'] ?? [];
        setState(() {
          cartCount = items.length;
        });
      }
    }
  }

  Future<void> addToCartOnline(Product product) async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('userId');

    if (id == null || id.isEmpty) {
      // زائر → خزّن المنتج محليًا
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

      localCart.add(
        jsonEncode({
          '_id': product.id,
          'quantity': 1,
          'productId': {
            'id': product.id,
            'name': product.name,
            'price': product.price,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'category': product.category,
            'color': product.color,
            'exclusive': product.exclusive,
            'best_seller': product.bestSeller,
            'top_pick': product.topPick,
            'stock': product.stock,
            'createdAt': product.createdAt?.toIso8601String(),
          },
        }),
      );

      await prefs.setStringList('localCart', localCart);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product.name} تمت إضافته للسلة (مؤقتًا)')),
      );

      await updateCartCount(); // ✅ تحديث الشارة

      // ✅ فتح السلة مباشرة وبعد الرجوع يتم التحديث
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => cart_ui.CartPage(userId: 'زائر')),
      );
      await updateCartCount(); // ✅ تحديث بعد الرجوع
    } else {
      // مستخدم مسجل → خزّن في السيرفر
      final response = await http.post(
        Uri.parse('http://192.168.1.15:3000/cart/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "userId": id,
          "productId": product.id,
          "quantity": 1,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${product.name} تمت إضافته إلى السلة')),
        );

        await updateCartCount(); // ✅ تحديث الشارة

        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => cart_ui.CartPage(userId: id)),
        );
        await updateCartCount(); // ✅ تحديث بعد الرجوع
      } else if (response.statusCode == 409) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${product.name} موجود بالفعل في السلة')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ فشل في إضافة المنتج للسلة')),
        );
      }
    }
  }

  Future<void> fetchProducts() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.15:3000/api/products'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        products =
            (data['data'] as List).map((e) => Product.fromJson(e)).toList();
      });
    }
  }

  Future<void> fetchExclusiveProducts() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.15:3000/api/products?exclusive=true'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        exclusiveProducts =
            (data['data'] as List).map((e) => Product.fromJson(e)).toList();
      });
    }
  }

  Future<void> fetchBestSellingProducts() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.15:3000/api/products?best_seller=true'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        bestSellingProducts =
            (data['data'] as List).map((e) => Product.fromJson(e)).toList();
      });
    }
  }

  Future<void> fetchNewProducts() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.15:3000/api/products?sort=newest'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        newestProducts =
            (data['data'] as List).map((e) => Product.fromJson(e)).toList();
      });
    }
  }

void _onItemTapped(int index) {
  setState(() {
    _selectedIndex = index;
  });
}



  @override
  Widget build(BuildContext context) {
final List<Widget> pages = [
  buildHomePage(),
  cart_ui.CartPage(userId: userId ?? 'زائر'),
  const UserProfilePage(), // ✅ يعرض دائمًا صفحة البروفايل سواء مسجل أو لا
];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart),
                if (cartCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$cartCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'السلة',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
        ],
        selectedItemColor: const Color.fromARGB(255, 242, 168, 193),
        unselectedItemColor: Colors.grey,
      ),
      floatingActionButton: SizedBox(
        width: 160,
        height: 50,
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/customize_bouquet',
              arguments: widget.userName,
            );
          },
          label: const Text(
            'صمّم باقتك',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          icon: const Icon(Icons.add_box_outlined),
          backgroundColor: const Color(0xFFF2A8C1),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget buildHomePage() {
    return Scaffold(
      backgroundColor: const Color(0xFFFFEEE7),
      appBar: AppBar(
        title: Image.asset('assets/logo.png', height: 60),
        centerTitle: true,
        backgroundColor: const Color(0xFFFFEEE7),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(context, '/product_search'),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.white,
            elevation: 4,
            onSelected: (value) {
              if (value == 'all') {
                Navigator.pushNamed(context, '/all_products');
              } else {
                Navigator.pushNamed(
                  context,
                  '/category_products',
                  arguments: value,
                );
              }
            },
            itemBuilder:
                (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'all',
                    child: Text(
                      'عرض جميع المنتجات',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    enabled: false,
                    child: Text('المناسبات'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'تخرج',
                    child: Text('التخرج'),
                  ),
                  const PopupMenuItem<String>(value: 'حب', child: Text('الحب')),
                  const PopupMenuItem<String>(
                    value: 'سلامة',
                    child: Text('السلامة'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'مبروك للعروسين',
                    child: Text('مبروك للعرسان'),
                  ),
                  const PopupMenuDivider(),
                ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildCarouselSlider(),
            const SizedBox(height: 25),
            const Text(
  "اختر باقة لمناسبتك",
  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
),
SizedBox(height: 12),
            buildCategoryRow(),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "افضل الباقات",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                TextButton(
                  onPressed:
                      () => Navigator.pushNamed(context, '/all_products'),
                  child: const Text("عرض الكل"),
                ),
              ],
            ),
            buildHorizontalProductList(products.take(5).toList(), cardHeight: 230, highlight: true),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "عروض حصرية",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                TextButton(
                  onPressed:
                      () => Navigator.pushNamed(
                        context,
                        '/category_products',
                        arguments: 'exclusive',
                      ),
                  child: const Text("عرض الكل"),
                ),
              ],
            ),
            buildHorizontalProductList(
              exclusiveProducts,
              cardHeight: 280,
              highlight: true,
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "الأكثر مبيعًا",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                TextButton(
                  onPressed:
                      () => Navigator.pushNamed(
                        context,
                        '/category_products',
                        arguments: 'best_seller',
                      ),
                  child: const Text("عرض الكل"),
                ),
              ],
            ),
            buildHorizontalProductList(
              bestSellingProducts,
              cardHeight: 280,
              highlight: true,
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "جديدنا",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed:
                      () => Navigator.pushNamed(
                        context,
                        '/category_products',
                        arguments: 'newest',
                      ),
                  child: const Text("عرض الكل"),
                ),
              ],
            ),
            buildHorizontalProductList(newestProducts, cardHeight: 230, highlight: true),
            const SizedBox(height: 25), // ⭐ أضف هاي
      buildFooter(),              // ⭐ وأضف هاي
          ],
        ),
      ),
    );
  }

  Widget buildHorizontalProductList(
    List<Product> productList, {
    double cardHeight = 230,
    bool highlight = false,
  }) {
    return SizedBox(
      height: cardHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: productList.length,
        itemBuilder: (context, index) {
          final product = productList[index];
          return buildProductCard(
            product,
            cardHeight: cardHeight,
            highlight: highlight,
            
          );
        },
      ),
    );
  }

Widget buildProductCard(
  Product product, {
  double cardHeight = 230,
  bool highlight = false,
}) {
  return Container(
    width: 180,
    margin: const EdgeInsets.symmetric(horizontal: 8),
    child: Card(
      elevation: highlight ? 6 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: highlight
            ? const BorderSide(
                color: Color.fromARGB(255, 242, 168, 193),
                width: 1.5,
              )
            : BorderSide.none,
      ),
      shadowColor: highlight
          ? const Color.fromARGB(100, 242, 168, 193)
          : Colors.black12,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailsPage(product: product),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              product.fullImageUrl,
              height: cardHeight * 0.45,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: cardHeight * 0.45,
                width: double.infinity,
                color: Colors.grey[200],
                alignment: Alignment.center,
                child: const Icon(
                  Icons.image_not_supported,
                  color: Colors.grey,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                product.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '${product.price.toStringAsFixed(2)} شيكل',
                style: TextStyle(
                  color: product.exclusive == true ? Colors.red : Colors.black,
                  decoration: product.exclusive == true
                      ? TextDecoration.underline
                      : TextDecoration.none,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ElevatedButton(
                onPressed: () => addToCartOnline(product),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 242, 168, 193),
                  minimumSize: const Size.fromHeight(30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text("أضف للسلة"),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
}
  Widget buildCarouselSlider() {
    List<String> slides = ['slide1.png', 'slide2.png', 'slide3.png'];

    return Column(
      children: [
        CarouselSlider(
          items:
              slides.map((slide) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(10),
                      ),
                      child: Image.asset(
                        'assets/$slide',
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 20,
                      left: 16,
                      child: Image.asset(
                        'assets/logo.png',
                        height: 70,
                        width: 70,
                      ),
                    ),
                  ],
                );
              }).toList(),
          options: CarouselOptions(
            height: MediaQuery.of(context).size.height * 0.45,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 3),
            enlargeCenterPage: true,
            viewportFraction: 1.0,
            onPageChanged: (index, reason) {
              setState(() {
                _currentSlide = index;
              });
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(slides.length, (index) {
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    _currentSlide == index
                        ? const Color.fromARGB(255, 234, 153, 180)
                        : Colors.grey,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget buildCategoryRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        buildCategoryItem(icon: Icons.favorite, title: 'حب', category: 'حب'),
        buildCategoryItem(icon: Icons.school, title: 'تخرج', category: 'تخرج'),
        buildCategoryItem(
          icon: Icons.card_giftcard,
          title: 'شكر',
          category: 'شكر',
        ),
        buildCategoryItem(
          icon: Icons.diversity_1,
          title: 'للعروسين',
          category: 'مبروك للعروسين',
        ),
      ],
    );
  }

  Widget buildCategoryItem({
    required IconData icon,
    required String title,
    required String category,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/category_products', arguments: category);
      },
      child: Column(
        children: [
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFF5EDE3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 36, color: Colors.brown[400]),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget buildFooter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Divider(thickness: 1, color: Colors.grey),
        const SizedBox(height: 8),
        const Text(
          "العنوان: نابلس.فلسطين",
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF60786A)),
        ),
        const SizedBox(height: 4),
        const Text(
          "رقم الهاتف: 0594929188",
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF60786A)),
        ),
        const SizedBox(height: 4),
        const Text(
          "info@hakayaward.ps",
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF60786A)),
        ),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 24,
          runSpacing: 12,
          children: [
            buildFooterLinkWithIcon(Icons.info_outline, 'من نحن', '/about_us'),
            buildFooterLinkWithIcon(
              Icons.phone_in_talk,
              'تواصل معنا',
              '/contact_us',
            ),
            buildFooterLinkWithIcon(
              Icons.local_shipping,
              'الشحن والتوصيل',
              '/shipping',
            ),
            buildFooterLinkWithIcon(Icons.reviews, 'آراء العملاء', '/reviews'),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          "© Hakaya Ward 2023. جميع الحقوق محفوظة.",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget buildFooterLinkWithIcon(
    IconData icon,
    String title,
    String routeName,
  ) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, routeName),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Color(0xFF60786A), size: 18),
          const SizedBox(width: 4),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF60786A),
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }
}
