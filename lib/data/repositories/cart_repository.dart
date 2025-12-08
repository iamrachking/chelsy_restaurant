import 'package:get/get.dart';
import 'package:chelsy_restaurant/core/services/api_service.dart';
import 'package:chelsy_restaurant/core/utils/app_logger.dart';
import 'package:chelsy_restaurant/data/models/cart_model.dart';

class CartRepository {
  final ApiService _apiService = Get.find<ApiService>();

  // Get cart
  Future<CartModel?> getCart() async {
    try {
      final response = await _apiService.get('/cart');
      if (response.data['success'] == true) {
        return CartModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      AppLogger.error('Get cart error', e);
      return null;
    }
  }

  // Add item to cart
  Future<Map<String, dynamic>> addToCart({
    required int dishId,
    required int quantity,
    Map<String, dynamic>? selectedOptions,
    String? specialInstructions,
  }) async {
    try {
      final response = await _apiService.post(
        '/cart/items',
        data: {
          'dish_id': dishId,
          'quantity': quantity,
          'selected_options': selectedOptions ?? {},
          if (specialInstructions != null) 'special_instructions': specialInstructions,
        },
      );

      if (response.data['success'] == true) {
        final cart = CartModel.fromJson(response.data['data'] as Map<String, dynamic>);
        return {'success': true, 'cart': cart};
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Erreur lors de l\'ajout au panier',
      };
    } catch (e) {
      AppLogger.error('Add to cart error', e);
      return {'success': false, 'message': e.toString()};
    }
  }

  // Update cart item
  Future<Map<String, dynamic>> updateCartItem({
    required int itemId,
    int? quantity,
    String? specialInstructions,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (quantity != null) data['quantity'] = quantity;
      if (specialInstructions != null) data['special_instructions'] = specialInstructions;

      final response = await _apiService.put(
        '/cart/items/$itemId',
        data: data,
      );

      if (response.data['success'] == true) {
        final cart = CartModel.fromJson(response.data['data'] as Map<String, dynamic>);
        return {'success': true, 'cart': cart};
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Erreur lors de la mise à jour',
      };
    } catch (e) {
      AppLogger.error('Update cart item error', e);
      return {'success': false, 'message': e.toString()};
    }
  }

  // Remove cart item
  Future<bool> removeCartItem(int itemId) async {
    try {
      final response = await _apiService.delete('/cart/items/$itemId');
      return response.data['success'] == true;
    } catch (e) {
      AppLogger.error('Remove cart item error', e);
      return false;
    }
  }

  // Clear cart
  Future<bool> clearCart() async {
    try {
      final response = await _apiService.delete('/cart');
      return response.data['success'] == true;
    } catch (e) {
      AppLogger.error('Clear cart error', e);
      return false;
    }
  }
}


