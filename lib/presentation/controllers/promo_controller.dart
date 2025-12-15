import 'package:get/get.dart';
import 'package:chelsy_restaurant/data/repositories/promo_repository.dart';
import 'package:chelsy_restaurant/core/utils/app_logger.dart';

class PromoController extends GetxController {
  final PromoRepository _promoRepository = Get.find<PromoRepository>();

  // Observable state
  final Rx<Map<String, dynamic>?> validatedPromo = Rx<Map<String, dynamic>?>(
    null,
  );
  final RxBool isLoading = false.obs;

  // Validate promo code
  Future<bool> validatePromoCode(String code, double orderAmount) async {
    try {
      isLoading.value = true;
      final result = await _promoRepository.validatePromoCode(
        code: code,
        orderAmount: orderAmount,
      );

      AppLogger.debug('Promo validation result: $result');

      if (result['success'] == true) {
        validatedPromo.value = result['promo_code'] as Map<String, dynamic>;

        // CORRECTION: Récupérer discount_amount directement du result
        final discount = _parseDouble(result['discount_amount']);

        Get.snackbar(
          'Succès',
          'Code promo valide - Réduction de ${discount.toStringAsFixed(0)} FCFA',
        );
        return true;
      } else {
        validatedPromo.value = null;
        Get.snackbar('Erreur', result['message'] ?? 'Code promo invalide');
        return false;
      }
    } catch (e) {
      AppLogger.error('Validate promo code error', e);
      Get.snackbar('Erreur', 'Une erreur est survenue');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Clear validated promo
  void clearPromo() {
    validatedPromo.value = null;
  }

  // CORRECTION: Get discount amount avec parsing robuste
  double get discountAmount {
    if (validatedPromo.value != null) {
      // Essayer d'abord discount_amount dans validatedPromo
      if (validatedPromo.value!.containsKey('discount_amount')) {
        return _parseDouble(validatedPromo.value!['discount_amount']);
      }
    }
    return 0.0;
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
