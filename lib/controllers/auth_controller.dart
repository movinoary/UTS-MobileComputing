import 'package:flutter/material.dart';
import '../services/auth_storage.dart';

class AuthController extends ChangeNotifier {
  final AuthStorage _storage;
  bool _isLoggedIn = false;
  String? _authToken;

  AuthController({AuthStorage? storage}) : _storage = storage ?? AuthStorage();

  bool get isLoggedIn => _isLoggedIn;
  String? get authToken => _authToken;

  Future<void> initialize() async {
    _isLoggedIn = await _storage.readLoginState();
    _authToken = await _storage.readAuthToken();
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    if (username == 'admin' && password == '123qweasd') {
      _isLoggedIn = true;
      _authToken = 'token-${DateTime.now().millisecondsSinceEpoch}';
      await _storage.saveLoginState(true);
      await _storage.saveAuthToken(_authToken!);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _authToken = null;
    await _storage.clear();
    notifyListeners();
  }
}
