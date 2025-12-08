import 'package:get/get.dart';
import 'package:chelsy_restaurant/data/repositories/cart_repository.dart';
import 'package:chelsy_restaurant/data/models/cart_model.dart';
import 'package:chelsy_restaurant/core/utils/app_logger.dart';

class CartController extends GetxController {
  final CartRepository _cartRepository = Get.find<CartRepository>();

  // Observable state
  final Rx<CartModel?> cart = Rx<CartModel?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCart();
  }

  // Load cart
  Future<void> loadCart() async {
    try {
      isLoading.value = true;
      final cartData = await _cartRepository.getCart();
      cart.value = cartData;
    } catch (e) {
      AppLogger.error('Load cart error', e);
    } finally {
      isLoading.value = false;
    }
  }

  // Add to cart
  Future<bool> addToCart({
    required int dishId,
    required int quantity,
    Map<String, dynamic>? selectedOptions,
    String? specialInstructions,
  }) async {
    try {
      isLoading.value = true;
      final result = await _cartRepository.addToCart(
        dishId: dishId,
        quantity: quantity,
        selectedOptions: selectedOptions,
        specialInstructions: specialInstructions,
      );

      if (result['success'] == true) {
        cart.value = result['cart'] as CartModel;
        Get.snackbar(
          'Succès',
          'Article ajouté au panier',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
        return true;
      } else {
        Get.snackbar(
          'Erreur',
          result['message'] ?? 'Erreur lors de l\'ajout',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
        return false;
      }
    } catch (e) {
      AppLogger.error('Add to cart error', e);
      Get.snackbar('Erreur', 'Une erreur est survenue');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Update cart item
  Future<bool> updateCartItem({
    required int itemId,
    int? quantity,
    String? specialInstructions,
  }) async {
    try {
      isLoading.value = true;
      final result = await _cartRepository.updateCartItem(
        itemId: itemId,
        quantity: quantity,
        specialInstructions: specialInstructions,
      );

      if (result['success'] == true) {
        cart.value = result['cart'] as CartModel;
        Get.snackbar(
          'Succès',
          'Article mis à jour dans le panier',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
        return true;
      } else {
        Get.snackbar(
          'Erreur',
          result['message'] ?? 'Erreur lors de la mise à jour',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
        return false;
      }
    } catch (e) {
      AppLogger.error('Update cart item error', e);
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Remove cart item
  Future<void> removeCartItem(int itemId) async {
    try {
      isLoading.value = true;
      final success = await _cartRepository.removeCartItem(itemId);
      if (success) {
        await loadCart();
        Get.snackbar(
          'Succès',
          'Article retiré du panier',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'Erreur',
          'Erreur lors de la suppression',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      AppLogger.error('Remove cart item error', e);
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Clear cart
  Future<void> clearCart() async {
    try {
      isLoading.value = true;
      final success = await _cartRepository.clearCart();
      if (success) {
        cart.value = null;
        Get.snackbar('Succès', 'Panier vidé');
      } else {
        Get.snackbar('Erreur', 'Erreur lors du vidage');
      }
    } catch (e) {
      AppLogger.error('Clear cart error', e);
      Get.snackbar('Erreur', 'Une erreur est survenue');
    } finally {
      isLoading.value = false;
    }
  }

  // Get cart item count
  int get itemCount => cart.value?.totalItems ?? 0;

  // Get cart total
  double get total => cart.value?.subtotal ?? 0.0;
}


