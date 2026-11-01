import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../models/user_model.dart';

enum AuthState { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthState _state = AuthState.unknown;
  UserModel? _user;
  String? _error;

  AuthState get state => _state;
  UserModel? get user => _user;
  String? get error => _error;
  bool get isLoggedIn => _state == AuthState.authenticated;

  // Cek token yang tersimpan di startup
  Future<void> init() async {
    final token = await ApiClient.getToken();
    if (token == null) {
      _state = AuthState.unauthenticated;
      notifyListeners();
      return;
    }
    // Verifikasi token masih valid
    final res = await ApiClient.get('/auth/me', auth: true);
    if (res['ok'] == true) {
      _user = UserModel.fromJson(res['user']);
      _state = AuthState.authenticated;
    } else {
      await ApiClient.clearToken();
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _error = null;
    final res = await ApiClient.post('/auth/login', {
      'email': email,
      'password': password,
    });
    if (res['ok'] == true) {
      await ApiClient.saveToken(res['token']);
      _user = UserModel.fromJson(res['user']);
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } else {
      _error = res['error'] ?? 'Login gagal';
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, String wa) async {
    _error = null;
    final res = await ApiClient.post('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
      'wa': wa,
    });
    if (res['ok'] == true) {
      await ApiClient.saveToken(res['token']);
      _user = UserModel.fromJson(res['user']);
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } else {
      _error = res['error'] ?? 'Registrasi gagal';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await ApiClient.clearToken();
    _user = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }

  Future<bool> updateProfile(String name, String phone) async {
    final res = await ApiClient.patch('/auth/profile', {
      'name': name,
      'phone': phone,
    }, auth: true);
    if (res['ok'] == true) {
      _user = UserModel.fromJson(res['user']);
      notifyListeners();
      return true;
    }
    return false;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
