import 'package:get/get.dart';
import 'package:chelsy_restaurant/core/services/api_service.dart';
import 'package:chelsy_restaurant/core/utils/app_logger.dart';
import 'package:chelsy_restaurant/data/models/dish_model.dart';

class FavoriteRepository {
  final ApiService _apiService = Get.find<ApiService>();

  // Get favorites
  Future<List<DishModel>> getFavorites() async {
    try {
      final response = await _apiService.get('/favorites');
      if (response.data['success'] == true) {
        final data = response.data['data'];
        List<dynamic> favoritesList;
        
        // Gérer différents formats de réponse
        if (data is Map<String, dynamic> && data['favorites'] != null) {
          favoritesList = data['favorites'] as List<dynamic>;
        } else if (data is List<dynamic>) {
          favoritesList = data;
        } else {
          favoritesList = [];
        }
        
        return favoritesList
            .map((f) {
              try {
                // Le favori peut être directement un dish ou avoir un champ 'dish'
                Map<String, dynamic> dishData;
                if (f is Map<String, dynamic>) {
                  if (f.containsKey('dish') && f['dish'] is Map<String, dynamic>) {
                    dishData = f['dish'] as Map<String, dynamic>;
                  } else {
                    dishData = f;
                  }
                  return DishModel.fromJson(dishData);
                }
                return null;
              } catch (e) {
                AppLogger.error('Error parsing favorite dish', e);
                return null;
              }
            })
            .whereType<DishModel>()
            .toList();
      }
      return [];
    } catch (e) {
      AppLogger.error('Get favorites error', e);
      return [];
    }
  }

  // Add favorite
  Future<bool> addFavorite(int dishId) async {
    try {
      final response = await _apiService.post(
        '/favorites',
        data: {'dish_id': dishId},
      );
      return response.data['success'] == true;
    } catch (e) {
      AppLogger.error('Add favorite error', e);
      return false;
    }
  }

  // Remove favorite
  Future<bool> removeFavorite(int favoriteId) async {
    try {
      final response = await _apiService.delete('/favorites/$favoriteId');
      return response.data['success'] == true;
    } catch (e) {
      AppLogger.error('Remove favorite error', e);
      return false;
    }
  }

  // Check if dish is favorite (by dish_id)
  Future<int?> getFavoriteIdByDishId(int dishId) async {
    try {
      final favorites = await getFavorites();
      for (var favorite in favorites) {
        if (favorite.id == dishId) {
          // We need to get the favorite ID from the API response
          final response = await _apiService.get('/favorites');
          if (response.data['success'] == true) {
            final favoritesList = response.data['data']['favorites'] as List<dynamic>;
            for (var fav in favoritesList) {
              if (fav['dish_id'] == dishId) {
                return fav['id'] as int;
              }
            }
          }
        }
      }
      return null;
    } catch (e) {
      AppLogger.error('Get favorite ID error', e);
      return null;
    }
  }
}

