import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:chelsy_restaurant/core/services/api_service.dart';
import 'package:chelsy_restaurant/core/utils/app_logger.dart';

class ReviewRepository {
  final ApiService _apiService = Get.find<ApiService>();

  // Create review
  Future<Map<String, dynamic>> createReview({
    int? orderId,
    int? dishId,
    required int rating,
    int? restaurantRating,
    int? deliveryRating,
    String? comment,
    List<String>? images,
  }) async {
    try {
      // Vérifier qu'au moins orderId ou dishId est fourni
      if (orderId == null && dishId == null) {
        return {'success': false, 'message': 'order_id ou dish_id est requis'};
      }

      // Valider la note
      if (rating < 1 || rating > 5) {
        return {'success': false, 'message': 'La note doit être entre 1 et 5'};
      }

      final data = <String, dynamic>{
        'rating': rating,
        if (orderId != null) 'order_id': orderId,
        if (dishId != null) 'dish_id': dishId,
        if (comment != null && comment.trim().isNotEmpty)
          'comment': comment.trim(),
        // Toujours envoyer images, même vide
        'images': images ?? [],
      };

      AppLogger.info('Creating review with data: $data');

      final response = await _apiService.post('/reviews', data: data);

      AppLogger.info(
        'Review response: ${response.statusCode} - ${response.data}',
      );

      if (response.statusCode == 201 || response.data['success'] == true) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'Avis créé avec succès',
          'data': response.data['data'],
        };
      }

      // Extraire le message d'erreur détaillé
      String errorMessage = 'Erreur lors de la création de l\'avis';
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        AppLogger.error('Review error response: $responseData');

        if (responseData['message'] != null) {
          errorMessage = responseData['message'] as String;
        } else if (responseData['errors'] != null) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          AppLogger.error('Validation errors: $errors');
          if (errors.isNotEmpty) {
            final errorEntries = <String>[];
            errors.forEach((key, value) {
              if (value is List && value.isNotEmpty) {
                errorEntries.add('$key: ${value.first}');
              } else if (value is String) {
                errorEntries.add('$key: $value');
              }
            });
            if (errorEntries.isNotEmpty) {
              errorMessage = errorEntries.join('\n');
            }
          }
        }
      }

      return {'success': false, 'message': errorMessage};
    } catch (e) {
      AppLogger.error('Create review exception', e);
      String errorMessage = 'Erreur lors de la création de l\'avis';

      // Gérer les erreurs DioException
      if (e is dio.DioException) {
        AppLogger.error('🔴 DioException details:');
        AppLogger.error('Status code: ${e.response?.statusCode}');
        AppLogger.error('Response data: ${e.response?.data}');
        AppLogger.error('Message: ${e.message}');

        if (e.response != null) {
          final responseData = e.response!.data;
          AppLogger.error('Full response body: $responseData');

          if (responseData is Map<String, dynamic>) {
            // Essayer d'extraire les erreurs
            if (responseData['errors'] != null) {
              final errors = responseData['errors'];
              AppLogger.error(
                'Errors object: $errors (type: ${errors.runtimeType})',
              );

              if (errors is Map<String, dynamic>) {
                final errorEntries = <String>[];
                errors.forEach((key, value) {
                  AppLogger.error(
                    '  - $key: $value (type: ${value.runtimeType})',
                  );
                  if (value is List && value.isNotEmpty) {
                    errorEntries.add('$key: ${value.first}');
                  } else if (value is String) {
                    errorEntries.add('$key: $value');
                  }
                });
                if (errorEntries.isNotEmpty) {
                  errorMessage = errorEntries.join('\n');
                }
              }
            } else if (responseData['message'] != null) {
              errorMessage = responseData['message'] as String;
            }
          }
          AppLogger.error('Final error message: $errorMessage');
        }

        if (e.response?.statusCode == 422) {
          errorMessage = 'Erreur de validation:\n$errorMessage';
        } else if (e.response?.statusCode == 401) {
          errorMessage = 'Vous devez être connecté';
        } else if (e.response?.statusCode == 403) {
          errorMessage = 'Vous n\'avez pas la permission';
        } else if (e.response?.statusCode == 404) {
          errorMessage = 'Ressource non trouvée';
        } else if (e.response?.statusCode == 500) {
          errorMessage = 'Erreur serveur. Essayez plus tard';
        }
      }

      return {'success': false, 'message': errorMessage};
    }
  }

  // Get dish reviews with pagination
  Future<Map<String, dynamic>> getDishReviews(
    int dishId, {
    int page = 1,
  }) async {
    try {
      final response = await _apiService.get(
        '/dishes/$dishId/reviews',
        queryParameters: {'page': page, 'per_page': 10},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>?;

        if (data == null) {
          return {'reviews': [], 'pagination': null};
        }

        // Récupérer les avis et filtrer les valeurs nulles
        final reviewsList =
            (data['reviews'] as List<dynamic>?)
                ?.whereType<Map<String, dynamic>>()
                .toList() ??
            [];

        final pagination = data['pagination'] as Map<String, dynamic>?;

        return {'reviews': reviewsList, 'pagination': pagination};
      }

      return {'reviews': [], 'pagination': null};
    } catch (e) {
      AppLogger.error('Get dish reviews error', e);

      if (e is dio.DioException) {
        if (e.response?.statusCode == 404) {
          return {'reviews': [], 'pagination': null};
        }
      }

      return {'reviews': [], 'pagination': null};
    }
  }

  // Get order reviews
  Future<Map<String, dynamic>> getOrderReviews(
    int orderId, {
    int page = 1,
  }) async {
    try {
      final response = await _apiService.get(
        '/orders/$orderId/reviews',
        queryParameters: {'page': page, 'per_page': 10},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>?;

        if (data == null) {
          return {'reviews': [], 'pagination': null};
        }

        final reviewsList =
            (data['reviews'] as List<dynamic>?)
                ?.whereType<Map<String, dynamic>>()
                .toList() ??
            [];

        final pagination = data['pagination'] as Map<String, dynamic>?;

        return {'reviews': reviewsList, 'pagination': pagination};
      }

      return {'reviews': [], 'pagination': null};
    } catch (e) {
      AppLogger.error('Get order reviews error', e);
      return {'reviews': [], 'pagination': null};
    }
  }

  // Update review
  Future<Map<String, dynamic>> updateReview(
    int reviewId, {
    int? rating,
    String? comment,
    List<String>? images,
  }) async {
    try {
      final data = <String, dynamic>{
        if (rating != null) 'rating': rating,
        if (comment != null) 'comment': comment,
        if (images != null) 'images': images,
      };

      final response = await _apiService.put('/reviews/$reviewId', data: data);

      if (response.statusCode == 200 && response.data['success'] == true) {
        return {'success': true, 'message': 'Avis mis à jour avec succès'};
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Erreur lors de la mise à jour',
      };
    } catch (e) {
      AppLogger.error('Update review error', e);
      return {'success': false, 'message': 'Erreur lors de la mise à jour'};
    }
  }

  // Delete review
  Future<Map<String, dynamic>> deleteReview(int reviewId) async {
    try {
      final response = await _apiService.delete('/reviews/$reviewId');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return {'success': true, 'message': 'Avis supprimé avec succès'};
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Erreur lors de la suppression',
      };
    } catch (e) {
      AppLogger.error('Delete review error', e);
      return {'success': false, 'message': 'Erreur lors de la suppression'};
    }
  }
}
