import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Check auth status on app start
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    final isAuth = await AuthService.isAuthenticated();
    if (isAuth) {
      final userData = await AuthService.getUserData();
      if (userData != null) {
        _user = userData;
        _isAuthenticated = true;
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  // Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await AuthService.login( email: email, password: password, );

    if (result['success']) {
      _user = result['user'];
      _isAuthenticated = true;
      _errorMessage = null;
    } else {
      _errorMessage = result['message'];
    }

    _isLoading = false;
    notifyListeners();

    return result;
  }

  // Signup
  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await AuthService.signup( name: name, email: email, password: password, );

    if (result['success']) {
      _user = result['user'];
      _isAuthenticated = true;
      _errorMessage = null;
    } else
    {
      _errorMessage = result['message'];
    }

    _isLoading = false;
    notifyListeners();

    return result;
  }

  // Logout
  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    _isAuthenticated = false;
    _errorMessage = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Update Name
  Future<Map<String, dynamic>> updateName(String name) async {
    _isLoading = true;
    notifyListeners();

    final result = await AuthService.updateName(name);

    if (result['success']) {
      _user = result['user'];
      _errorMessage = null;
    } else {
      _errorMessage = result['message'];
    }

    _isLoading = false;
    notifyListeners();

    return result;
  }

  // Change Password
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await AuthService.changePassword(
      currentPassword: currentPassword, newPassword: newPassword,
    );

    _isLoading = false;
    notifyListeners();

    return result;
  }

  // Delete Account
  Future<Map<String, dynamic>> deleteAccount() async {
    _isLoading = true;
    notifyListeners();

    final result = await AuthService.deleteAccount();
    if (result['success']) {
      _user = null;
      _isAuthenticated = false;
    }

    _isLoading = false;
    notifyListeners();

    return result;
  }
}