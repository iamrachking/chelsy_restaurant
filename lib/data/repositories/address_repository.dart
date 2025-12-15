import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:chelsy_restaurant/core/services/api_service.dart';
import 'package:chelsy_restaurant/core/utils/app_logger.dart';
import 'package:chelsy_restaurant/data/models/address_model.dart';

class AddressRepository {
  final ApiService _apiService = Get.find<ApiService>();

  // Get addresses
  Future<List<AddressModel>> getAddresses() async {
    try {
      final response = await _apiService.get('/addresses');
      if (response.data['success'] == true) {
        final addresses = response.data['data']['addresses'] as List<dynamic>;
        return addresses
            .map((a) => AddressModel.fromJson(a as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      AppLogger.error('Get addresses error', e);
      return [];
    }
  }

  // Create address
  Future<Map<String, dynamic>> createAddress(AddressModel address) async {
    try {
      final response = await _apiService.post(
        '/addresses',
        data: address.toCreateJson(),
      );

      if (response.data['success'] == true) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'Adresse créée avec succès',
        };
      }

      // Extraire le message d'erreur détaillé
      String errorMessage = 'Erreur lors de la création de l\'adresse';
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['message'] != null) {
          errorMessage = responseData['message'] as String;
        } else if (responseData['errors'] != null) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          if (errors.isNotEmpty) {
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              errorMessage = firstError.first as String;
            } else if (firstError is String) {
              errorMessage = firstError;
            }
          }
        }
      }

      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      AppLogger.error('Create address error', e);
      String errorMessage = 'Erreur lors de la création de l\'adresse';
      
      // Gérer les erreurs DioException
      if (e is dio.DioException) {
        if (e.response != null) {
          final responseData = e.response!.data;
          if (responseData is Map<String, dynamic>) {
            if (responseData['message'] != null) {
              errorMessage = responseData['message'] as String;
            } else if (responseData['errors'] != null) {
              final errors = responseData['errors'] as Map<String, dynamic>;
              if (errors.isNotEmpty) {
                final firstError = errors.values.first;
                if (firstError is List && firstError.isNotEmpty) {
                  errorMessage = firstError.first as String;
                }
              }
            }
          }
        }
        
        if (e.response?.statusCode == 422) {
          errorMessage = 'Erreur de validation. Vérifiez vos informations';
        }
      }
      
      return {'success': false, 'message': errorMessage};
    }
  }

  // Update address
  Future<Map<String, dynamic>> updateAddress(
    int id,
    AddressModel address,
  ) async {
    try {
      final response = await _apiService.put(
        '/addresses/$id',
        data: address.toCreateJson(),
      );

      if (response.data['success'] == true) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'Adresse modifiée avec succès',
        };
      }

      // Extraire le message d'erreur détaillé
      String errorMessage = 'Erreur lors de la modification de l\'adresse';
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['message'] != null) {
          errorMessage = responseData['message'] as String;
        } else if (responseData['errors'] != null) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          if (errors.isNotEmpty) {
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              errorMessage = firstError.first as String;
            } else if (firstError is String) {
              errorMessage = firstError;
            }
          }
        }
      }

      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      AppLogger.error('Update address error', e);
      String errorMessage = 'Erreur lors de la modification de l\'adresse';
      
      // Gérer les erreurs DioException
      if (e is dio.DioException) {
        if (e.response != null) {
          final responseData = e.response!.data;
          if (responseData is Map<String, dynamic>) {
            if (responseData['message'] != null) {
              errorMessage = responseData['message'] as String;
            } else if (responseData['errors'] != null) {
              final errors = responseData['errors'] as Map<String, dynamic>;
              if (errors.isNotEmpty) {
                final firstError = errors.values.first;
                if (firstError is List && firstError.isNotEmpty) {
                  errorMessage = firstError.first as String;
                }
              }
            }
          }
        }
        
        if (e.response?.statusCode == 422) {
          errorMessage = 'Erreur de validation. Vérifiez vos informations';
        }
      }
      
      return {'success': false, 'message': errorMessage};
    }
  }

  // Set default address
  Future<Map<String, dynamic>> setDefaultAddress(int id) async {
    try {
      // Mettre à jour l'adresse avec is_default: true
      // L'API devrait automatiquement retirer le statut défaut des autres adresses
      final response = await _apiService.put(
        '/addresses/$id',
        data: {'is_default': true},
      );

      if (response.data['success'] == true) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'Adresse définie par défaut avec succès',
        };
      }

      // Extraire le message d'erreur détaillé
      String errorMessage = 'Erreur lors de la définition de l\'adresse par défaut';
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['message'] != null) {
          errorMessage = responseData['message'] as String;
        } else if (responseData['errors'] != null) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          if (errors.isNotEmpty) {
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              errorMessage = firstError.first as String;
            } else if (firstError is String) {
              errorMessage = firstError;
            }
          }
        }
      }

      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      AppLogger.error('Set default address error', e);
      String errorMessage = 'Erreur lors de la définition de l\'adresse par défaut';
      
      // Gérer les erreurs DioException
      if (e is dio.DioException) {
        if (e.response != null) {
          final responseData = e.response!.data;
          if (responseData is Map<String, dynamic>) {
            if (responseData['message'] != null) {
              errorMessage = responseData['message'] as String;
            } else if (responseData['errors'] != null) {
              final errors = responseData['errors'] as Map<String, dynamic>;
              if (errors.isNotEmpty) {
                final firstError = errors.values.first;
                if (firstError is List && firstError.isNotEmpty) {
                  errorMessage = firstError.first as String;
                }
              }
            }
          }
        }
        
        if (e.response?.statusCode == 422) {
          errorMessage = 'Erreur de validation. Vérifiez vos informations';
        }
      }
      
      return {'success': false, 'message': errorMessage};
    }
  }

  // Delete address
  Future<bool> deleteAddress(int id) async {
    try {
      final response = await _apiService.delete('/addresses/$id');
      return response.data['success'] == true;
    } catch (e) {
      AppLogger.error('Delete address error', e);
      return false;
    }
  }
}
