import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bus_track_app/core/api/dio_client.dart';
import 'package:bus_track_app/core/models/auth_response.dart';
import 'package:bus_track_app/core/models/user_model.dart';
import 'dart:convert';
// NotificationService is now a stub – we'll keep the import but it won't do anything
import 'package:bus_track_app/core/services/notification_service.dart';

class AuthProvider extends ChangeNotifier {
  final DioClient _dioClient = DioClient();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  User? _user;
  String? _token;
  bool _isLoading = false;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    await _storage.delete(key: 'token');
    await _storage.delete(key: 'user');

    try {
      final response = await _dioClient.dio.post('/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final authData = AuthResponse.fromJson(response.data);
        _token = authData.token;
        _user = authData.user;

        await _storage.write(key: 'token', value: _token);
        await _storage.write(key: 'user', value: jsonEncode({
          'id': _user!.id,
          'name': _user!.name,
          'email': _user!.email,
          'role_id': _user!.roleId,
        }));

        // Notification service stub – does nothing
        String? fcmToken = await NotificationService.initialize();
        if (fcmToken != null) {
          await NotificationService.registerToken(fcmToken);
        }
        NotificationService.listen();

        print('✅ Login success, token stored');
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('❌ Login error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'user');
    _token = null;
    _user = null;
    notifyListeners();
  }

  Future<void> checkAuth() async {
    final token = await _storage.read(key: 'token');
    final userJson = await _storage.read(key: 'user');
    print('🔍 checkAuth: token=$token, userJson=$userJson');

    if (token != null) {
      _token = token;
      if (userJson != null) {
        try {
          final Map<String, dynamic> map = jsonDecode(userJson);
          _user = User(
            id: map['id'],
            name: map['name'],
            email: map['email'],
            roleId: map['role_id'],
          );
          print('✅ User restored from storage: ${_user?.name}');
          notifyListeners();

          // Stub – does nothing
          String? fcmToken = await NotificationService.initialize();
          if (fcmToken != null) {
            await NotificationService.registerToken(fcmToken);
          }
          NotificationService.listen();
        } catch (e) {
          print('❌ Error decoding user: $e');
          await _fetchUserFromBackend();
        }
      } else {
        await _fetchUserFromBackend();
      }
    } else {
      print('❌ No token found');
    }
  }

  Future<void> _fetchUserFromBackend() async {
    try {
      final dio = DioClient().dio;
      final response = await dio.get('/user');
      if (response.statusCode == 200) {
        final data = response.data;
        _user = User(
          id: data['id'],
          name: data['name'],
          email: data['email'],
          roleId: data['role_id'],
        );
        await _storage.write(key: 'user', value: jsonEncode({
          'id': _user!.id,
          'name': _user!.name,
          'email': _user!.email,
          'role_id': _user!.roleId,
        }));
        print('✅ User fetched from backend: ${_user?.name}');
        notifyListeners();
      }
    } catch (e) {
      print('❌ Failed to fetch user: $e');
      await logout();
    }
  }
}