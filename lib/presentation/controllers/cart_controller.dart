import 'package:get/get.dart';
import 'package:chelsy_restaurant/data/repositories/cart_repository.dart';
import 'package:chelsy_restaurant/data/models/cart_model.dart';
import 'package:chelsy_restaurant/core/utils/app_logger.dart';

class CartController extends GetxController {
  final CartRepository _cartRepository = Get.find<CartRepository>();

  // IMPORTANT: Utiliser Rx pour la réactivité
  final Rx<CartModel> cart = CartModel.empty().obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCart();
  }

  // Charger le panier
  Future<void> loadCart() async {
    try {
      isLoading.value = true;
      AppLogger.debug('Loading cart...');

      final cartData = await _cartRepository.getCart();

      if (cartData != null) {
        cart.value = cartData;
        AppLogger.debug(
          'Cart loaded: ${cartData.items.length} items, total: ${cartData.totalItems}',
        );
      } else {
        cart.value = CartModel.empty();
        AppLogger.debug('No cart data');
      }
    } catch (e, stackTrace) {
      cart.value = CartModel.empty();
      AppLogger.error('Load cart error', e);
      AppLogger.debug('Stack trace: $stackTrace');
    } finally {
      isLoading.value = false;
    }
  }

  // Ajouter au panier
  Future<bool> addToCart({
    required int dishId,
    required int quantity,
    Map<String, dynamic>? selectedOptions,
    String? specialInstructions,
  }) async {
    try {
      isLoading.value = true;
      AppLogger.debug('Adding to cart: dishId=$dishId, quantity=$quantity');

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
          result['message'] ?? 'Article ajouté au panier',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );

        AppLogger.debug(
          'Item added successfully. New cart total: ${cart.value.totalItems}',
        );
        return true;
      } else {
        Get.snackbar(
          'Erreur',
          result['message'] ?? 'Erreur lors de l\'ajout',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );

        AppLogger.error('Failed to add item', result['message']);
        return false;
      }
    } catch (e, stackTrace) {
      AppLogger.error('Add to cart error', e);
      AppLogger.debug('Stack trace: $stackTrace');

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

  // Mettre à jour un article
  Future<bool> updateCartItem({
    required int itemId,
    int? quantity,
    String? specialInstructions,
  }) async {
    try {
      isLoading.value = true;
      AppLogger.debug('Updating cart item $itemId: quantity=$quantity');

      final result = await _cartRepository.updateCartItem(
        itemId: itemId,
        quantity: quantity,
        specialInstructions: specialInstructions,
      );

      if (result['success'] == true) {
        cart.value = result['cart'] as CartModel;
        AppLogger.debug('Item updated successfully');
        return true;
      } else {
        Get.snackbar(
          'Erreur',
          result['message'] ?? 'Erreur lors de la mise à jour',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );

        AppLogger.error('Failed to update item', result['message']);
        return false;
      }
    } catch (e, stackTrace) {
      AppLogger.error('Update cart item error', e);
      AppLogger.debug('Stack trace: $stackTrace');

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

  // Retirer un article
  Future<void> removeCartItem(int itemId) async {
    try {
      isLoading.value = true;
      AppLogger.debug('Removing cart item: $itemId');

      final success = await _cartRepository.removeCartItem(itemId);

      if (success) {
        await loadCart();

        Get.snackbar(
          'Succès',
          'Article retiré du panier',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );

        AppLogger.debug('Item removed successfully');
      } else {
        Get.snackbar(
          'Erreur',
          'Erreur lors de la suppression',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );

        AppLogger.error('Failed to remove item', null);
      }
    } catch (e, stackTrace) {
      AppLogger.error('Remove cart item error', e);
      AppLogger.debug('Stack trace: $stackTrace');

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

  // Vider le panier
  Future<void> clearCart() async {
    try {
      isLoading.value = true;
      AppLogger.debug('Clearing cart...');

      final success = await _cartRepository.clearCart();

      if (success) {
        cart.value = CartModel.empty();

        Get.snackbar(
          'Succès',
          'Panier vidé',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );

        AppLogger.debug('Cart cleared successfully');
      } else {
        Get.snackbar(
          'Erreur',
          'Erreur lors du vidage du panier',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );

        AppLogger.error('Failed to clear cart', null);
      }
    } catch (e, stackTrace) {
      AppLogger.error('Clear cart error', e);
      AppLogger.debug('Stack trace: $stackTrace');

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

  // Getters réactifs
  int get itemCount => cart.value.totalItems;
  double get total => cart.value.subtotal;
  bool get isEmpty => cart.value.isEmpty;
  bool get isNotEmpty => cart.value.isNotEmpty;
  int get dishCount => cart.value.items.length;
}
