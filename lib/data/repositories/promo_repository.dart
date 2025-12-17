import 'package:get/get.dart';
import 'package:chelsy_restaurant/core/services/api_service.dart';
import 'package:chelsy_restaurant/core/utils/app_logger.dart';

class PromoRepository {
  final ApiService _apiService = Get.find<ApiService>();

  /// Valider un code promo
  Future<Map<String, dynamic>> validatePromoCode({
    required String code,
    required double orderAmount,
  }) async {
    try {
      AppLogger.debug(
        'PromoRepository.validatePromoCode - code: $code, amount: $orderAmount',
      );

      final response = await _apiService.post(
        '/promo-codes/validate',
        data: {'code': code, 'order_amount': orderAmount},
      );

      AppLogger.debug('Promo API response: ${response.data}');

      if (response.data == null) {
        return {'success': false, 'message': 'Erreur serveur: réponse vide'};
      }

      if (response.data['success'] == true) {
        // Vérifier que les données existent
        final data = response.data['data'];

        if (data == null || data is! Map<String, dynamic>) {
          AppLogger.error(
            'PromoRepository.validatePromoCode',
            'Invalid data format: $data',
          );
          return {'success': false, 'message': 'Format de réponse invalide'};
        }

        final promoCode = data['promo_code'] as Map<String, dynamic>?;
        final discountAmount = data['discount_amount'];

        if (promoCode == null) {
          AppLogger.error(
            'PromoRepository.validatePromoCode',
            'promo_code is null in response',
          );
          return {'success': false, 'message': 'Données promo invalides'};
        }

        AppLogger.debug(
          'Promo validated successfully: ${promoCode['code']}, discount: $discountAmount',
        );

        return {
          'success': true,
          'promo_code': promoCode,
          'discount_amount': discountAmount,
        };
      }

      // Gérer les erreurs du serveur
      final errorMessage = response.data['message'] ?? 'Code promo invalide';

      AppLogger.debug('Promo validation failed: $errorMessage');

      return {'success': false, 'message': errorMessage};
    } catch (e) {
      AppLogger.error('PromoRepository.validatePromoCode - Exception', e);
      return {'success': false, 'message': 'Erreur réseau: ${e.toString()}'};
    }
  }
}
