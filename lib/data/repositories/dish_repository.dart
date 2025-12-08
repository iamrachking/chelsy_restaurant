import 'package:get/get.dart';
import 'package:chelsy_restaurant/core/services/api_service.dart';
import 'package:chelsy_restaurant/core/utils/app_logger.dart';
import 'package:chelsy_restaurant/core/constants/app_constants.dart';
import 'package:chelsy_restaurant/data/models/dish_model.dart';
import 'package:chelsy_restaurant/data/models/category_model.dart';

class DishRepository {
  final ApiService _apiService = Get.find<ApiService>();

  Future<Map<String, dynamic>?> getRestaurant() async {
    try {
      final response = await _apiService.get('/restaurant');
      if (response.data['success'] == true) {
        return response.data['data']['restaurant'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      AppLogger.error('Get restaurant error', e);
      return null;
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _apiService.get('/categories');
      if (response.data['success'] == true) {
        final categories =
            response.data['data']['categories'] as List<dynamic>? ?? [];
        return categories
            .whereType<Map<String, dynamic>>()
            .map(CategoryModel.fromJson)
            .toList();
      }
      return [];
    } catch (e) {
      AppLogger.error('Get categories error', e);
      return [];
    }
  }

  Future<CategoryModel?> getCategory(int id) async {
    try {
      final response = await _apiService.get('/categories/$id');
      if (response.data['success'] == true) {
        return CategoryModel.fromJson(
          response.data['data']['category'] as Map<String, dynamic>,
        );
      }
      return null;
    } catch (e) {
      AppLogger.error('Get category error', e);
      return null;
    }
  }

  // Generic method to parse dishes safely
  Future<List<DishModel>> _parseDishes(dynamic data) async {
    List<dynamic> dishesList = [];

    if (data is Map<String, dynamic>) {
      dishesList = data['dishes'] as List<dynamic>? ?? [];
    } else if (data is List<dynamic>) {
      dishesList = data;
    }

    final dishes = <DishModel>[];
    for (var d in dishesList) {
      try {
        if (d is Map<String, dynamic>) {
          dishes.add(DishModel.fromJson(d));
        }
      } catch (e) {
        AppLogger.error('Error parsing dish', e);
      }
    }
    return dishes;
  }

  Future<Map<String, dynamic>> getDishes({
    int? categoryId,
    bool? isFeatured,
    bool? isNew,
    bool? isVegetarian,
    bool? isSpecialty,
    String? search,
    String? sortBy,
    String? sortOrder,
    int page = 1,
    int perPage = AppConstants.defaultPageSize,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
        if (categoryId != null) 'category_id': categoryId,
        if (isFeatured != null) 'is_featured': isFeatured,
        if (isNew != null) 'is_new': isNew,
        if (isVegetarian != null) 'is_vegetarian': isVegetarian,
        if (isSpecialty != null) 'is_specialty': isSpecialty,
        if (search != null && search.isNotEmpty) 'search': search,
        if (sortBy != null) 'sort_by': sortBy,
        if (sortOrder != null) 'sort_order': sortOrder,
      };

      final response = await _apiService.get(
        '/dishes',
        queryParameters: queryParams,
      );
      if (response.data['success'] == true) {
        dynamic data = response.data['data'];
        final dishes = await _parseDishes(data);
        Map<String, dynamic>? pagination;

        if (data is Map<String, dynamic>) {
          pagination = data['pagination'] as Map<String, dynamic>?;
        }

        return {'dishes': dishes, 'pagination': pagination};
      }
      return {'dishes': [], 'pagination': null};
    } catch (e) {
      AppLogger.error('Get dishes error', e);
      return {'dishes': [], 'pagination': null};
    }
  }

  Future<List<DishModel>> getFeaturedDishes() async {
    try {
      final response = await _apiService.get('/dishes/featured');
      if (response.data['success'] == true) {
        return _parseDishes(response.data['data']);
      }
      return [];
    } catch (e) {
      AppLogger.error('Get featured dishes error', e);
      return [];
    }
  }

  Future<List<DishModel>> getPopularDishes() async {
    try {
      final response = await _apiService.get('/dishes/popular');
      if (response.data['success'] == true) {
        return _parseDishes(response.data['data']);
      }
      return [];
    } catch (e) {
      AppLogger.error('Get popular dishes error', e);
      return [];
    }
  }

  Future<DishModel?> getDish(int id) async {
    try {
      final response = await _apiService.get('/dishes/$id');
      if (response.data['success'] == true) {
        return DishModel.fromJson(
          response.data['data']['dish'] as Map<String, dynamic>,
        );
      }
      return null;
    } catch (e) {
      AppLogger.error('Get dish error', e);
      return null;
    }
  }

  Future<Map<String, dynamic>> getDishReviews(
    int dishId, {
    int page = 1,
  }) async {
    try {
      final response = await _apiService.get(
        '/dishes/$dishId/reviews',
        queryParameters: {'page': page},
      );
      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>? ?? {};
        return {
          'reviews': data['reviews'] as List<dynamic>? ?? [],
          'pagination': data['pagination'] as Map<String, dynamic>?,
        };
      }
      return {'reviews': [], 'pagination': null};
    } catch (e) {
      AppLogger.error('Get dish reviews error', e);
      return {'reviews': [], 'pagination': null};
    }
  }
}
