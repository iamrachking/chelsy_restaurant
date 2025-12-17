import 'package:get/get.dart';
import 'package:chelsy_restaurant/core/services/api_service.dart';
import 'package:chelsy_restaurant/core/utils/app_logger.dart';
import 'package:chelsy_restaurant/data/models/cart_model.dart';

class CartRepository {
  final ApiService _apiService = Get.find<ApiService>();

  Future<CartModel?> getCart() async {
    try {
      final response = await _apiService.get('/cart');

      AppLogger.debug('Get cart response: ${response.data}');

      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'];

        if (data == null) {
          AppLogger.debug('Cart data is null, returning empty cart');
          return CartModel.empty();
        }

        // CORRECTION: L'API renvoie data: {cart: {...}}
        if (data is Map<String, dynamic>) {
          final cartData = data['cart'];

          if (cartData == null) {
            AppLogger.debug('Cart object is null, returning empty cart');
            return CartModel.empty();
          }

          if (cartData is Map<String, dynamic>) {
            return CartModel.fromJson(cartData);
          } else {
            AppLogger.error('Cart data is not a Map', cartData);
            return CartModel.empty();
          }
        } else {
          AppLogger.error('Data is not a Map', data);
          return CartModel.empty();
        }
      }

      AppLogger.debug('Cart response not successful, returning empty cart');
      return CartModel.empty();
    } catch (e, stackTrace) {
      AppLogger.error('Get cart error', e);
      AppLogger.debug('Stack trace: $stackTrace');
      return CartModel.empty();
    }
  }

  Future<Map<String, dynamic>> addToCart({
    required int dishId,
    required int quantity,
    Map<String, dynamic>? selectedOptions,
    String? specialInstructions,
  }) async {
    try {
      final requestData = {
        'dish_id': dishId,
        'quantity': quantity,
        'selected_options': selectedOptions ?? {},
      };

      if (specialInstructions != null &&
          specialInstructions.trim().isNotEmpty) {
        requestData['special_instructions'] = specialInstructions;
      }

      AppLogger.debug('Add to cart request: $requestData');

      final response = await _apiService.post('/cart/items', data: requestData);

      AppLogger.debug('Add to cart response: ${response.data}');

      if (response.data != null && response.data['success'] == true) {
        // Recharger le panier complet après ajout
        final cart = await getCart();

        if (cart != null) {
          return {
            'success': true,
            'cart': cart,
            'message': response.data['message'] ?? 'Article ajouté au panier',
          };
        } else {
          return {
            'success': false,
            'message': 'Erreur lors du rechargement du panier',
          };
        }
      }

      return {
        'success': false,
        'message':
            response.data?['message'] ?? 'Erreur lors de l\'ajout au panier',
      };
    } catch (e, stackTrace) {
      AppLogger.error('Add to cart error', e);
      AppLogger.debug('Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'Une erreur est survenue: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> updateCartItem({
    required int itemId,
    int? quantity,
    String? specialInstructions,
  }) async {
    try {
      final data = <String, dynamic>{};

      if (quantity != null) data['quantity'] = quantity;
      if (specialInstructions != null) {
        data['special_instructions'] = specialInstructions;
      }
      AppLogger.debug('Update cart item $itemId request: $data');

      final response = await _apiService.put('/cart/items/$itemId', data: data);

      AppLogger.debug('Update cart item response: ${response.data}');

      if (response.data != null && response.data['success'] == true) {
        final cart = await getCart();

        if (cart != null) {
          return {
            'success': true,
            'cart': cart,
            'message': response.data['message'] ?? 'Article mis à jour',
          };
        } else {
          return {
            'success': false,
            'message': 'Erreur lors du rechargement du panier',
          };
        }
      }

      return {
        'success': false,
        'message': response.data?['message'] ?? 'Erreur lors de la mise à jour',
      };
    } catch (e, stackTrace) {
      AppLogger.error('Update cart item error', e);
      AppLogger.debug('Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'Une erreur est survenue: ${e.toString()}',
      };
    }
  }

  Future<bool> removeCartItem(int itemId) async {
    try {
      AppLogger.debug('Remove cart item: $itemId');

      final response = await _apiService.delete('/cart/items/$itemId');

      AppLogger.debug('Remove cart item response: ${response.data}');

      if (response.data != null) {
        return response.data['success'] == true;
      }

      return false;
    } catch (e, stackTrace) {
      AppLogger.error('Remove cart item error', e);
      AppLogger.debug('Stack trace: $stackTrace');
      return false;
    }
  }

  Future<bool> clearCart() async {
    try {
      AppLogger.debug('Clear cart');

      final response = await _apiService.delete('/cart');

      AppLogger.debug('Clear cart response: ${response.data}');

      if (response.data != null) {
        return response.data['success'] == true;
      }

      return false;
    } catch (e, stackTrace) {
      AppLogger.error('Clear cart error', e);
      AppLogger.debug('Stack trace: $stackTrace');
      return false;
    }
  }
}
