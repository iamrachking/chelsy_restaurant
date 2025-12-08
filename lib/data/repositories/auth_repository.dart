import 'package:get/get.dart';
import 'package:chelsy_restaurant/core/services/api_service.dart';
import 'package:chelsy_restaurant/core/services/storage_service.dart';
import 'package:chelsy_restaurant/core/utils/app_logger.dart';
import 'package:chelsy_restaurant/data/models/user_model.dart';

class AuthRepository {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();

  // Register
  Future<Map<String, dynamic>> register({
    required String firstname,
    required String lastname,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
  }) async {
    try {
      final response = await _apiService.post(
        '/register',
        data: {
          'firstname': firstname,
          'lastname': lastname,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          if (phone != null) 'phone': phone,
        },
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final token = data['token'] as String;
        final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);

        // Save token and user
        await _storageService.saveToken(token);
        await _storageService.saveUser(user.toJson());
        await _storageService.setLoggedIn(true);

        AppLogger.info('Registration successful');
        return {'success': true, 'user': user, 'token': token};
      }

      return {'success': false, 'message': response.data['message'] ?? 'Erreur lors de l\'inscription'};
    } catch (e) {
      AppLogger.error('Registration error', e);
      return {'success': false, 'message': e.toString()};
    }
  }

  // Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        '/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final token = data['token'] as String;
        final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);

        // Save token and user
        await _storageService.saveToken(token);
        await _storageService.saveUser(user.toJson());
        await _storageService.setLoggedIn(true);

        AppLogger.info('Login successful');
        return {'success': true, 'user': user, 'token': token};
      }

      return {'success': false, 'message': response.data['message'] ?? 'Erreur lors de la connexion'};
    } catch (e) {
      AppLogger.error('Login error', e);
      return {'success': false, 'message': e.toString()};
    }
  }

  // Logout
  Future<bool> logout() async {
    try {
      await _apiService.post('/logout');
      await _storageService.removeToken();
      await _storageService.removeUser();
      await _storageService.removeFcmToken();
      await _storageService.setLoggedIn(false);
      AppLogger.info('Logout successful');
      return true;
    } catch (e) {
      AppLogger.error('Logout error', e);
      // Clear local data even if API call fails
      await _storageService.removeToken();
      await _storageService.removeUser();
      await _storageService.removeFcmToken();
      await _storageService.setLoggedIn(false);
      return false;
    }
  }

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    try {
      final response = await _apiService.get('/me');
      if (response.data['success'] == true) {
        final userData = response.data['data']['user'] as Map<String, dynamic>;
        final user = UserModel.fromJson(userData);
        await _storageService.saveUser(user.toJson());
        return user;
      }
      return null;
    } catch (e) {
      AppLogger.error('Get current user error', e);
      return null;
    }
  }

  // Forgot password
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await _apiService.post(
        '/forgot-password',
        data: {'email': email},
      );

      return {
        'success': response.data['success'] == true,
        'message': response.data['message'] ?? 'Erreur lors de la demande',
      };
    } catch (e) {
      AppLogger.error('Forgot password error', e);
      return {'success': false, 'message': e.toString()};
    }
  }

  // Reset password
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _apiService.post(
        '/reset-password',
        data: {
          'email': email,
          'token': token,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      return {
        'success': response.data['success'] == true,
        'message': response.data['message'] ?? 'Erreur lors de la réinitialisation',
      };
    } catch (e) {
      AppLogger.error('Reset password error', e);
      return {'success': false, 'message': e.toString()};
    }
  }
}


