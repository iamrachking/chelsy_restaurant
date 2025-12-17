import 'package:get/get.dart';
import 'package:chelsy_restaurant/data/repositories/favorite_repository.dart';
import 'package:chelsy_restaurant/data/models/dish_model.dart';
import 'package:chelsy_restaurant/core/utils/app_logger.dart';

class FavoriteController extends GetxController {
  final FavoriteRepository _favoriteRepository = Get.find<FavoriteRepository>();

  // Observable state
  final RxList<DishModel> favorites = <DishModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxSet<int> favoriteIds = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
  }

  // Load favorites
  Future<void> loadFavorites() async {
    try {
      isLoading.value = true;
      final favoritesList = await _favoriteRepository.getFavorites();
      favorites.value = favoritesList;
      favoriteIds.clear();
      favoriteIds.addAll(favoritesList.map((f) => f.id));
    } catch (e) {
      AppLogger.error('Load favorites error', e);
    } finally {
      isLoading.value = false;
    }
  }

  // Add favorite
  Future<bool> addFavorite(int dishId) async {
    try {
      isLoading.value = true;
      final success = await _favoriteRepository.addFavorite(dishId);
      if (success) {
        await loadFavorites();
        Get.snackbar('Succès', 'Ajouté aux favoris');
        return true;
      } else {
        Get.snackbar('Erreur', 'Erreur lors de l\'ajout');
        return false;
      }
    } catch (e) {
      AppLogger.error('Add favorite error', e);
      Get.snackbar('Erreur', 'Une erreur est survenue');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Remove favorite
  Future<bool> removeFavorite(int favoriteId) async {
    try {
      isLoading.value = true;
      final success = await _favoriteRepository.removeFavorite(favoriteId);
      if (success) {
        await loadFavorites();
        Get.snackbar('Succès', 'Retiré des favoris');
        return true;
      } else {
        Get.snackbar('Erreur', 'Erreur lors de la suppression');
        return false;
      }
    } catch (e) {
      AppLogger.error('Remove favorite error', e);
      Get.snackbar('Erreur', 'Une erreur est survenue');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Toggle favorite  qui utilise favoriteIds
  Future<void> toggleFavorite(int dishId) async {
    if (favoriteIds.contains(dishId)) {
      // Le plat est déjà en favoris, on le retire
      // On doit trouver le favorite ID depuis l'API
      final favoriteId = await _favoriteRepository.getFavoriteIdByDishId(
        dishId,
      );
      if (favoriteId != null) {
        await removeFavorite(favoriteId);
      } else {
        // Si on ne trouve pas l'ID, on recharge les favoris et on réessaye
        await loadFavorites();
        final favoriteId2 = await _favoriteRepository.getFavoriteIdByDishId(
          dishId,
        );
        if (favoriteId2 != null) {
          await removeFavorite(favoriteId2);
        }
      }
    } else {
      // Le plat n'est pas en favoris, on l'ajoute
      await addFavorite(dishId);
    }
  }

  // Check if dish is favorite
  bool isFavorite(int dishId) {
    return favoriteIds.contains(dishId);
  }
}
