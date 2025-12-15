import 'dart:async';
import 'package:get/get.dart';
import 'package:chelsy_restaurant/core/services/location_service.dart';
import 'package:chelsy_restaurant/core/constants/app_constants.dart';
import 'package:chelsy_restaurant/core/utils/app_logger.dart';

class TrackingController extends GetxController {
  final LocationService _locationService = Get.find<LocationService>();
  Timer? _trackingTimer;
  int? _currentOrderId;

  // Observable state
  final Rx<Map<String, dynamic>?> trackingData = Rx<Map<String, dynamic>?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isTracking = false.obs;

  @override
  void onClose() {
    stopTracking();
    super.onClose();
  }

  // Start tracking an order
  Future<void> startTracking(int orderId) async {
    if (isTracking.value && _currentOrderId == orderId) {
      AppLogger.warning('Already tracking this order');
      return;
    }

    _currentOrderId = orderId;
    isTracking.value = true;

    // Start location tracking
    await _locationService.startTracking(orderId: orderId);

    // Start periodic updates
    _trackingTimer = Timer.periodic(
      Duration(milliseconds: AppConstants.orderTrackingUpdateInterval),
      (_) => _updateTrackingData(orderId),
    );

    // Initial update
    await _updateTrackingData(orderId);
  }

  // Stop tracking
  void stopTracking() {
    _trackingTimer?.cancel();
    _trackingTimer = null;
    _locationService.stopTracking();
    isTracking.value = false;
    _currentOrderId = null;
    trackingData.value = null;
  }

  // Update tracking data
  Future<void> _updateTrackingData(int orderId) async {
    try {
      final data = await _locationService.getOrderTracking(orderId);
      if (data != null) {
        trackingData.value = data;
      }
    } catch (e) {
      AppLogger.error('Error updating tracking data', e);
    }
  }

  // Refresh tracking data manually
  Future<void> refreshTracking(int orderId) async {
    isLoading.value = true;
    await _updateTrackingData(orderId);
    isLoading.value = false;
  }

  // Get ETA in minutes
  int? get etaMinutes => trackingData.value?['eta_minutes'] as int?;

  // Get distance in km
  double? get distanceKm => trackingData.value?['distance_km'] as double?;

  // Get driver position
  Map<String, dynamic>? get driverPosition => trackingData.value?['position'] as Map<String, dynamic>?;

  // Get driver info
  Map<String, dynamic>? get driverInfo => trackingData.value?['driver'] as Map<String, dynamic>?;
}

