import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveUserData({
  required String name,
  required String email,
  required String phone,
  required String address,
  required String city,
}) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('userName', name);
  await prefs.setString('userEmail', email);
  await prefs.setString('userPhone', phone);
  await prefs.setString('userAddress', address);
  await prefs.setString('userCity', city);
}
