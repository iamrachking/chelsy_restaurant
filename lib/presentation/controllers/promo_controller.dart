import 'package:get/get.dart';
import 'package:chelsy_restaurant/data/repositories/promo_repository.dart';
import 'package:chelsy_restaurant/core/utils/app_logger.dart';

class PromoController extends GetxController {
  final PromoRepository _promoRepository = Get.find<PromoRepository>();

  // Observable state
  final Rx<Map<String, dynamic>?> validatedPromo = Rx<Map<String, dynamic>?>(
    null,
  );
  final RxDouble discountAmountValue =
      0.0.obs; // ✅ NOUVEAU: Stocker la réduction
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    AppLogger.debug('PromoController initialized');
  }

  /// Valider un code promo
  Future<bool> validatePromoCode(String code, double orderAmount) async {
    try {
      isLoading.value = true;

      AppLogger.debug('Validating promo code: $code for amount: $orderAmount');

      final result = await _promoRepository.validatePromoCode(
        code: code,
        orderAmount: orderAmount,
      );

      AppLogger.debug('Promo validation result: $result');

      if (result['success'] == true) {
        // Extraire les données
        final promoCode = result['promo_code'] as Map<String, dynamic>?;
        final discountAmount = result['discount_amount'];

        if (promoCode == null) {
          AppLogger.error(
            'PromoController.validatePromoCode',
            'Promo code is null',
          );
          Get.snackbar('Erreur', 'Données promo invalides');
          return false;
        }

        // ✅ Stocker les données correctement
        validatedPromo.value = promoCode;
        final discount = _parseDouble(discountAmount);
        discountAmountValue.value = discount;

        AppLogger.debug(
          'Promo validated: name=${promoCode['name']}, discount=$discount',
        );

        Get.snackbar(
          'Succès',
          'Code promo valide - Réduction de ${discount.toStringAsFixed(0)} FCFA',
          duration: const Duration(seconds: 3),
        );
        return true;
      } else {
        // ✅ Réinitialiser en cas d'erreur
        validatedPromo.value = null;
        discountAmountValue.value = 0.0;

        final errorMsg = result['message'] ?? 'Code promo invalide';
        AppLogger.debug('Promo validation failed: $errorMsg');

        Get.snackbar('Erreur', errorMsg, duration: const Duration(seconds: 2));
        return false;
      }
    } catch (e) {
      AppLogger.error('PromoController.validatePromoCode', e);
      validatedPromo.value = null;
      discountAmountValue.value = 0.0;
      Get.snackbar('Erreur', 'Une erreur est survenue');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Effacer le code promo validé
  void clearPromo() {
    AppLogger.debug('Clearing promo code');
    validatedPromo.value = null;
    discountAmountValue.value = 0.0;
  }

  /// Obtenir le montant de réduction
  double get discountAmount {
    return discountAmountValue.value;
  }

  /// Helper pour parser les doubles
  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final trimmed = value.trim();
      final cleaned = trimmed.replaceAll(',', '.');
      return double.tryParse(cleaned) ?? 0.0;
    }
    return 0.0;
  }
}
