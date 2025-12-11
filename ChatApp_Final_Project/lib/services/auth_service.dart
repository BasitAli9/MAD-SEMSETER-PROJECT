import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/user_model.dart';

class AuthService
{
  // Login
  static Future<Map<String, dynamic>> login({ required String email, required String password,})
  async
  {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({ 'email': email, 'password': password, }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Save token
        await _saveToken(data['token']);

        // Save user data
        await _saveUserData(data['user']);

        return { 'success': true,
          'message': data['message'],
          'user': UserModel.fromJson(data['user']),
          'token': data['token'],
        };
      }
      else
      {
        return {
          'success': false, 'message': data['message'] ?? 'Login failed',
        };
      }
    }
    catch (e)
    {
      return { 'success': false, 'message': 'Connection error. Please check your internet.',};
    }
  }

  // Signup
  static Future<Map<String, dynamic>> signup({ required String name, required String email, required String password,})
  async
  {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.signupUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        // Save token
        await _saveToken(data['token']);

        // Save user data
        await _saveUserData(data['user']);

        return {
          'success': true, 'message': data['message'],
          'user': UserModel.fromJson(data['user']),
          'token': data['token'],
        };
      }
      else
      {
        return { 'success': false, 'message': data['message'] ?? 'Signup failed',};
      }
    }
    catch (e) {
      return { 'success': false, 'message': 'Connection error. Please check your internet.',};
    }
  }

  // Get Current User
  static Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final token = await getToken();

      if (token == null) {  return { 'success': false, 'message': 'No token found', };  }

      final response = await http.get(
        Uri.parse(ApiConfig.getCurrentUserUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        await _saveUserData(data['user']);

        return { 'success': true, 'user': UserModel.fromJson(data['user']), };
      }
      else
      {
        return { 'success': false, 'message': data['message'] ?? 'Failed to get user', };
      }
    }
    catch (e)
    {
      return { 'success': false, 'message': 'Connection error', };
    }
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }

  // Save token
  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Get token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Save user data
  static Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(userData));
  }

  // Get user data
  static Future<UserModel?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');

    if (userData != null) { return UserModel.fromJson(jsonDecode(userData)); }

    return null;
  }

  // Check if authenticated
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null;
  }

  // Update Name
  static Future<Map<String, dynamic>> updateName(String name) async
  {
    try {
      final token = await getToken();
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/auth/update-name'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'name': name}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        await _saveUserData(data['user']);
        return {
          'success': true, 'message': data['message'],
          'user': UserModel.fromJson(data['user']),
        };
      }
      else
      {
        return { 'success': false, 'message': data['message'] ?? 'Failed to update name',};
      }
    }
    catch (e)
    {
      return { 'success': false, 'message': 'Connection error', };
    }
  }

  // Change Password
  static Future<Map<String, dynamic>> changePassword({ required String currentPassword, required String newPassword,})
  async
  {
    try {
      final token = await getToken();
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/auth/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({ 'currentPassword': currentPassword, 'newPassword': newPassword, }),
      );

      final data = jsonDecode(response.body);
      return {
        'success': data['success'] == true,
        'message': data['message'] ?? 'Failed to change password',
      };
    }
    catch (e)
    {
      return { 'success': false, 'message': 'Connection error', };
    }
  }

  // Delete Account
  static Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final token = await getToken();
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/auth/delete-account'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        await logout();
      }

      return {
        'success': data['success'] == true,
        'message': data['message'] ?? 'Failed to delete account',
      };
    }
    catch (e)
    {
      return { 'success': false,  'message': 'Connection error', };
    }
  }
}