import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

// الصفحات
import 'screens/welcome_page.dart';
import 'screens/main_home_page.dart';
import 'screens/ready_products_page.dart';
import 'screens/login_page.dart';
import 'screens/signup_page.dart';
import 'screens/cart_page.dart';
import 'screens/product_search_page.dart';
import 'screens/category_products_page.dart';
import 'screens/about_page.dart';
import 'screens/customer_reviews_page.dart';
import 'screens/contact_us_page.dart';
import 'screens/checkout_screen.dart';
import 'screens/shipping_page.dart';
import 'screens/customize_bouquet_page.dart';
import 'screens/profilepage.dart';
import 'screens/product_details_page.dart';
import 'models/product.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en', 'US'), Locale('ar', 'AE')],
      path: 'assets/translation',
      fallbackLocale: const Locale('ar', 'AE'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Product App',
      theme: ThemeData(primarySwatch: Colors.pink, fontFamily: 'Cairo'),
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      initialRoute: '/welcome',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
          case '/welcome':
            return MaterialPageRoute(builder: (_) => const WelcomePage());
          case '/home':
            return MaterialPageRoute(builder: (_) => const MainHomePage(userName: 'زائر'));
          case '/all_products':
            return MaterialPageRoute(builder: (_) => const ReadyProductsPage());
          case '/login':
            return MaterialPageRoute(builder: (_) => LoginPage());
          case '/signup':
            return MaterialPageRoute(builder: (_) => const SignUpPage());
          case '/profile':
            return MaterialPageRoute(builder: (_) => const UserProfilePage());
          case '/cart':
            return MaterialPageRoute(builder: (_) => CartPage(userId: 'guest'));
          case '/search':
          case '/product_search':
            return MaterialPageRoute(builder: (_) => ProductSearchPage());
          case '/about_us':
            return MaterialPageRoute(builder: (_) => AboutPage());
          case '/reviews':
            return MaterialPageRoute(builder: (_) => const CustomerReviewsPage());
          case '/contact_us':
            return MaterialPageRoute(builder: (_) => const ContactUsPage());
          case '/shipping':
            return MaterialPageRoute(builder: (_) => const ShippingPage());
          case '/customize_bouquet':
            final userName = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => CustomBouquetPage(customerName: userName),
            );
          case '/category_products':
            final category = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => const CategoryProductsPage(),
              settings: RouteSettings(arguments: category),
            );
          case '/product_details':
            final product = settings.arguments as Product;
            return MaterialPageRoute(
              builder: (_) => ProductDetailsPage(product: product),
            );
          default:
            return MaterialPageRoute(builder: (_) => const WelcomePage());
        }
      },
    );
  }
}
