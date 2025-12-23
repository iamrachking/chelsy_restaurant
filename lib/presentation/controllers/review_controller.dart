import 'package:get/get.dart';
import 'package:chelsy_restaurant/data/repositories/review_repository.dart';
import 'package:chelsy_restaurant/core/utils/app_logger.dart';

class ReviewController extends GetxController {
  final ReviewRepository _reviewRepository = Get.find<ReviewRepository>();

  // Observable state
  final RxList<dynamic> reviews = <dynamic>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasMore = true.obs;
  final RxString errorMessage = ''.obs;

  // Create review
  Future<bool> createReview({
    int? orderId,
    int? dishId,
    required int rating,
    int? restaurantRating,
    int? deliveryRating,
    String? comment,
    List<String>? images,
  }) async {
    try {
      if (orderId == null && dishId == null) {
        errorMessage.value = 'Order ID ou Dish ID requis';
        return false;
      }

      isLoading.value = true;

      final result = await _reviewRepository.createReview(
        orderId: orderId,
        dishId: dishId,
        rating: rating,
        restaurantRating: restaurantRating,
        deliveryRating: deliveryRating,
        comment: comment,
        images: images,
      );

      if (result['success'] == true) {
        Get.snackbar(
          'Succès',
          result['message'] ?? 'Avis créé avec succès',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
        return true;
      } else {
        errorMessage.value = result['message'] ?? 'Erreur lors de la création';
        Get.snackbar(
          'Erreur',
          errorMessage.value,
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }
    } catch (e) {
      AppLogger.error('Create review error', e);
      errorMessage.value = 'Erreur : $e';
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue',
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Load dish reviews
  Future<void> loadDishReviews(int dishId, {bool refresh = true}) async {
    try {
      if (refresh) {
        currentPage.value = 1;
        reviews.clear();
        hasMore.value = true;
      }

      if (!hasMore.value) return;

      isLoading.value = true;

      final result = await _reviewRepository.getDishReviews(
        dishId,
        page: currentPage.value,
      );

      final reviewsList = result['reviews'] as List<dynamic>? ?? [];
      final pagination = result['pagination'] as Map<String, dynamic>?;

      if (refresh) {
        reviews.value = reviewsList;
      } else {
        reviews.addAll(reviewsList);
      }

      if (pagination != null) {
        final currentPageNum = pagination['current_page'] as int? ?? 1;
        final lastPage = pagination['last_page'] as int? ?? 1;
        hasMore.value = currentPageNum < lastPage;
        if (hasMore.value) {
          currentPage.value = currentPageNum + 1;
        }
      } else {
        hasMore.value = false;
      }
    } catch (e) {
      AppLogger.error('Load dish reviews error', e);
      errorMessage.value = 'Erreur lors du chargement des avis';
    } finally {
      isLoading.value = false;
    }
  }

  // Load more reviews (pagination)
  Future<void> loadMoreReviews(int dishId) async {
    await loadDishReviews(dishId, refresh: false);
  }

  // Clear reviews
  void clearReviews() {
    reviews.clear();
    currentPage.value = 1;
    hasMore.value = true;
    errorMessage.value = '';
  }
}
