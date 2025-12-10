import 'package:get/get.dart';
import 'package:chelsy_restaurant/data/repositories/dish_repository.dart';
import 'package:chelsy_restaurant/data/models/dish_model.dart';
import 'package:chelsy_restaurant/data/models/category_model.dart';
import 'package:chelsy_restaurant/core/utils/app_logger.dart';

class DishController extends GetxController {
  final DishRepository _dishRepository = Get.find<DishRepository>();

  // Observable state
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<DishModel> dishes = <DishModel>[].obs;
  final RxList<DishModel> featuredDishes = <DishModel>[].obs;
  final RxList<DishModel> popularDishes = <DishModel>[].obs;
  final Rx<DishModel?> selectedDish = Rx<DishModel?>(null);
  final Rx<Map<String, dynamic>?> restaurant = Rx<Map<String, dynamic>?>(null);
  final RxBool isLoading = false.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasMore = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadRestaurant();
    loadCategories();
    loadFeaturedDishes(refresh: true);
    loadPopularDishes(refresh: true);
    loadDishes();
  }

  // Load restaurant info
  Future<void> loadRestaurant() async {
    try {
      final restaurantData = await _dishRepository.getRestaurant();
      restaurant.value = restaurantData;
    } catch (e) {
      AppLogger.error('Load restaurant error', e);
    }
  }

  // Load categories
  Future<void> loadCategories() async {
    try {
      isLoading.value = true;
      final categoriesList = await _dishRepository.getCategories();
      categories.value = categoriesList;
    } catch (e) {
      AppLogger.error('Load categories error', e);
    } finally {
      isLoading.value = false;
    }
  }

  // Load dishes génériques
  Future<void> loadDishes({
    int? categoryId,
    bool? isFeatured,
    bool? isNew,
    bool? isVegetarian,
    bool? isSpecialty,
    String? search,
    String? sortBy,
    String? sortOrder,
    bool refresh = false,
  }) async {
    try {
      if (refresh) {
        currentPage.value = 1;
        dishes.clear();
        hasMore.value = true;
      }

      if (!hasMore.value) return;

      isLoading.value = true;
      final result = await _dishRepository.getDishes(
        categoryId: categoryId,
        isFeatured: isFeatured,
        isNew: isNew,
        isVegetarian: isVegetarian,
        isSpecialty: isSpecialty,
        search: search,
        sortBy: sortBy,
        sortOrder: sortOrder,
        page: currentPage.value,
      );

      final dishesList = result['dishes'] as List<dynamic>? ?? [];
      final pagination = result['pagination'] as Map<String, dynamic>?;

      final newDishes = dishesList
          .map((d) {
            if (d is DishModel) return d;
            if (d is Map<String, dynamic>) return DishModel.fromJson(d);
            return null;
          })
          .whereType<DishModel>()
          .toList();

      if (refresh) {
        dishes.value = newDishes;
      } else {
        dishes.addAll(newDishes);
      }

      if (pagination != null) {
        final currentPageNum = pagination['current_page'] as int;
        final lastPage = pagination['last_page'] as int;
        hasMore.value = currentPageNum < lastPage;
        if (hasMore.value) currentPage.value = currentPageNum + 1;
      } else {
        hasMore.value = false;
      }
    } catch (e) {
      AppLogger.error('Load dishes error', e);
    } finally {
      isLoading.value = false;
    }
  }

  // Load featured dishes
  Future<void> loadFeaturedDishes({bool refresh = true}) async {
    try {
      if (refresh) featuredDishes.clear();
      isLoading.value = true;
      final dishesList = await _dishRepository.getFeaturedDishes();
      featuredDishes.value = dishesList;
    } catch (e) {
      AppLogger.error('Load featured dishes error', e);
    } finally {
      isLoading.value = false;
    }
  }

  // Load popular dishes
  Future<void> loadPopularDishes({bool refresh = true}) async {
    try {
      if (refresh) popularDishes.clear();
      isLoading.value = true;
      final dishesList = await _dishRepository.getPopularDishes();
      popularDishes.value = dishesList;
    } catch (e) {
      AppLogger.error('Load popular dishes error', e);
    } finally {
      isLoading.value = false;
    }
  }

  // Get dish by id
  Future<void> getDish(int id) async {
    try {
      isLoading.value = true;
      final dish = await _dishRepository.getDish(id);
      selectedDish.value = dish;
    } catch (e) {
      AppLogger.error('Get dish error', e);
    } finally {
      isLoading.value = false;
    }
  }

  // Search dishes
  void searchDishes(String query) {
    loadDishes(search: query, refresh: true);
  }

  // Filter by category
  void filterByCategory(int? categoryId) {
    loadDishes(categoryId: categoryId, refresh: true);
  }
}
