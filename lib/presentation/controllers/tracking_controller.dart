import 'dart:async';
import 'package:get/get.dart';
import 'package:chelsy_restaurant/data/repositories/order_repository.dart';
import 'package:chelsy_restaurant/core/utils/app_logger.dart';

class TrackingController extends GetxController {
  final OrderRepository _orderRepository = Get.find<OrderRepository>();
  Timer? _trackingTimer;
  int? _currentOrderId;

  // Observable state
  final Rx<Map<String, dynamic>?> trackingData = Rx<Map<String, dynamic>?>(
    null,
  );
  final RxBool isLoading = false.obs;
  final RxBool isTracking = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onClose() {
    stopTracking();
    super.onClose();
  }

  /// Démarrer le suivi d'une commande
  Future<void> startTracking(int orderId) async {
    try {
      // Si on suit déjà cette commande, ne pas recommencer
      if (isTracking.value && _currentOrderId == orderId) {
        AppLogger.warning('Already tracking this order');
        return;
      }

      // Arrêter le suivi précédent
      stopTracking();

      _currentOrderId = orderId;
      isTracking.value = true;
      errorMessage.value = '';

      // Récupérer les données initiales
      await _updateTrackingData(orderId);

      // Démarrer les mises à jour périodiques (toutes les 5 secondes)
      _trackingTimer = Timer.periodic(
        const Duration(seconds: 5),
        (_) => _updateTrackingData(orderId),
      );

      AppLogger.info('Tracking started for order: $orderId');
    } catch (e) {
      AppLogger.error('Error starting tracking', e);
      errorMessage.value = 'Erreur lors du démarrage du suivi';
      isTracking.value = false;
    }
  }

  /// Arrêter le suivi
  void stopTracking() {
    _trackingTimer?.cancel();
    _trackingTimer = null;
    isTracking.value = false;
    _currentOrderId = null;
    trackingData.value = null;
    errorMessage.value = '';
    AppLogger.info('Tracking stopped');
  }

  /// Mettre à jour les données de suivi
  Future<void> _updateTrackingData(int orderId) async {
    try {
      isLoading.value = true;

      // Appeler l'endpoint de suivi
      final response = await _orderRepository.getOrderTracking(orderId);

      if (response != null && response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        trackingData.value = data;
        errorMessage.value = '';

        AppLogger.debug('Tracking data updated: $data');
      } else {
        // Pas d'erreur critique, juste pas de données (commande pas en livraison)
        final message =
            response?['message'] ?? 'Aucune donnée de suivi disponible';
        AppLogger.warning('Tracking message: $message');
      }
    } catch (e) {
      AppLogger.error('Error updating tracking data', e);
      errorMessage.value = 'Erreur lors de la mise à jour du suivi';
      // Continuer le suivi même en cas d'erreur
    } finally {
      isLoading.value = false;
    }
  }

  /// Rafraîchir les données de suivi manuellement
  Future<void> refreshTracking(int orderId) async {
    if (!isTracking.value) {
      return;
    }
    await _updateTrackingData(orderId);
  }

  // Getters pour accéder aux données
  int? get etaMinutes => trackingData.value?['eta_minutes'] as int?;

  double? get distanceKm => trackingData.value?['distance_km'] as double?;

  Map<String, dynamic>? get driverPosition =>
      trackingData.value?['position'] as Map<String, dynamic>?;

  Map<String, dynamic>? get driverInfo =>
      trackingData.value?['driver'] as Map<String, dynamic>?;

  bool get hasTrackingData =>
      trackingData.value != null &&
      (driverPosition != null || driverInfo != null);
}
