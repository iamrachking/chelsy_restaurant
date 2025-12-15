import 'package:get/get.dart';
import 'package:chelsy_restaurant/core/services/api_service.dart';
import 'package:chelsy_restaurant/core/utils/app_logger.dart';

class PromoRepository {
  final ApiService _apiService = Get.find<ApiService>();

  // Validate promo code
  Future<Map<String, dynamic>> validatePromoCode({
    required String code,
    required double orderAmount,
  }) async {
    try {
      final response = await _apiService.post(
        '/promo-codes/validate',
        data: {'code': code, 'order_amount': orderAmount},
      );

      AppLogger.debug('Promo API response: ${response.data}');

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final promoCode = data['promo_code'] as Map<String, dynamic>;
        final discountAmount = data['discount_amount'];

        return {
          'success': true,
          'promo_code': promoCode,
          'discount_amount':
              discountAmount, // CORRECTION: Inclure discount_amount
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Code promo invalide',
      };
    } catch (e) {
      AppLogger.error('Validate promo code error', e);
      return {'success': false, 'message': e.toString()};
    }
  }
}
