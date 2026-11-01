import 'package:flutter/material.dart';
import '../data/auth_repository.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _authRepository.isAuthenticated;

  // Ação de Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.signIn(email: email, password: password);
      _isLoading = false;
      notifyListeners();
      return true; // Sucesso
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false; // Falha
    }
  }

  // Ação de Registo
  Future<bool> register(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.signUp(email: email, password: password);
      _isLoading = false;
      notifyListeners();
      return true; // Sucesso
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false; // Falha
    }
  }

  // Ação de Logout
  Future<void> logout() async {
    await _authRepository.signOut();
    notifyListeners();
  }
}