import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:chelsy_restaurant/core/services/api_service.dart';
import 'package:chelsy_restaurant/core/utils/app_logger.dart';
import 'package:chelsy_restaurant/data/models/user_model.dart';

class ProfileRepository {
  final ApiService _apiService = Get.find<ApiService>();

  // ------------------------------
  // GET PROFILE
  // ------------------------------
  Future<UserModel?> getProfile() async {
    try {
      final response = await _apiService.get('/profile');

      if (response.data['success'] == true) {
        return UserModel.fromJson(
          response.data['data']['user'] as Map<String, dynamic>,
        );
      }
      return null;
    } catch (e) {
      AppLogger.error('Get profile error', e);
      return null;
    }
  }

  // ------------------------------
  // UPDATE PROFILE (TEXT FIELDS)
  // ------------------------------
  Future<Map<String, dynamic>> updateProfile({
    String? firstname,
    String? lastname,
    String? email,
    String? phone,
    String? birthDate,
    String? gender,
  }) async {
    try {
      final data = <String, dynamic>{};

      if (firstname != null) data['firstname'] = firstname;
      if (lastname != null) data['lastname'] = lastname;
      if (email != null) data['email'] = email;
      if (phone != null) data['phone'] = phone;
      if (birthDate != null) data['birth_date'] = birthDate;
      if (gender != null) data['gender'] = gender;

      final response = await _apiService.put('/profile', data: data);

      if (response.data['success'] == true) {
        final user = UserModel.fromJson(
          response.data['data']['user'] as Map<String, dynamic>,
        );
        return {'success': true, 'user': user};
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Erreur lors de la mise à jour',
      };
    } catch (e) {
      AppLogger.error('Update profile error', e);
      return {'success': false, 'message': e.toString()};
    }
  }

  // ------------------------------
  // CHANGE PASSWORD
  // ------------------------------
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      final response = await _apiService.post(
        '/change-password',
        data: {
          'current_password': currentPassword,
          'password': newPassword,
          'password_confirmation': newPasswordConfirmation,
        },
      );

      return {
        'success': response.data['success'] == true,
        'message': response.data['message'] ?? 'Erreur lors du changement',
      };
    } catch (e) {
      AppLogger.error('Change password error', e);
      return {'success': false, 'message': e.toString()};
    }
  }

  // ------------------------------
  // UPDATE PROFILE PICTURE (FINAL)
  // ------------------------------
  Future<Map<String, dynamic>> updateProfilePicture(String imagePath) async {
    try {
      final file = await dio.MultipartFile.fromFile(
        imagePath,
        filename: imagePath.split('/').last,
      );

      // Laravel : upload = POST + _method=PUT
      final formData = dio.FormData.fromMap({'_method': 'PUT', 'avatar': file});

      final response = await _apiService.post('/profile', data: formData);

      if (response.data['success'] == true) {
        final user = UserModel.fromJson(
          response.data['data']['user'] as Map<String, dynamic>,
        );
        return {'success': true, 'user': user};
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Erreur lors de l\'upload',
      };
    } catch (e) {
      AppLogger.error('Update profile picture error', e);

      String errorMessage = 'Erreur lors de la mise à jour de la photo';

      if (e is dio.DioException) {
        final status = e.response?.statusCode;

        if (status == 413) {
          errorMessage = 'Fichier trop volumineux. Taille maximale : 5MB';
        } else if (status == 422) {
          errorMessage = 'Format de fichier invalide (JPG, PNG, WEBP)';
        } else if (e.response?.data is Map) {
          errorMessage = e.response!.data['message'] ?? 'Erreur d\'upload';
        }
      }

      return {'success': false, 'message': errorMessage};
    }
  }
}