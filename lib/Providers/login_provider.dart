import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../Screens/HomePage.dart';
import '../api_constants.dart';

class LoginProvider with ChangeNotifier {
  bool isLoading = false;

  /// Login function
  Future<bool> login(String email, String password, BuildContext context) async {
    isLoading = true;
    notifyListeners();

    try {
      final uri = Uri.parse(ApiConstants.login);
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final result = jsonDecode(response.body);

      isLoading = false;
      notifyListeners();

      if (response.statusCode == 200 && result['token'] != null) {
        final userData = result['user'];
        final token = result['token'];

        // Save session info
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('staff_id', userData['id'].toString());
        await prefs.setString('role', userData['role'].toString());
        await prefs.setString('name', userData['name'] ?? '');
        await prefs.setString('permissions', userData['permissions'] ?? '');
        await prefs.setString('token', token);
        await prefs.setBool('isLoggedIn', true);

        // Navigate to HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage(userData: userData)),
        );

        return true;
      } else {
        showError(context, "Login failed: ${result['message'] ?? 'Unknown error'}");
        return false;
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      showError(context, "Login error: ${e.toString()}");
      return false;
    }
  }

  /// Logout and clear session
  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushReplacementNamed(context, '/login');
  }

  /// Check if user is already logged in
  Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  /// Show snackbar error
  void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
