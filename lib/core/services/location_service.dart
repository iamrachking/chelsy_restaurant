// import 'dart:async';
// import 'package:geolocator/geolocator.dart';
// import 'package:get/get.dart';
// import 'package:chelsy_restaurant/core/utils/app_logger.dart';
// import 'package:chelsy_restaurant/core/services/api_service.dart';

// class LocationService extends GetxService {
//   final ApiService _apiService = Get.find<ApiService>();
//   Position? _currentPosition;
//   StreamSubscription<Position>? _positionStream;
//   bool _isTracking = false;

//   // Observable position
//   final Rx<Position?> currentPosition = Rx<Position?>(null);
//   final RxBool isLocationEnabled = false.obs;
//   final RxString locationError = ''.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     _checkLocationPermission();
//   }

//   @override
//   void onClose() {
//     stopTracking();
//     super.onClose();
//   }

//   Future<bool> _checkLocationPermission() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       locationError.value = 'Les services de localisation sont désactivés';
//       isLocationEnabled.value = false;
//       return false;
//     }

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         locationError.value = 'Permission de localisation refusée';
//         isLocationEnabled.value = false;
//         return false;
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       locationError.value = 'Permission de localisation refusée définitivement';
//       isLocationEnabled.value = false;
//       return false;
//     }

//     isLocationEnabled.value = true;
//     locationError.value = '';
//     return true;
//   }

//   Future<Position?> getCurrentPosition() async {
//     try {
//       if (!await _checkLocationPermission()) {
//         return null;
//       }

//       _currentPosition = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );

//       currentPosition.value = _currentPosition;
//       AppLogger.info('Current position: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}');
//       return _currentPosition;
//     } catch (e) {
//       AppLogger.error('Error getting current position', e);
//       locationError.value = 'Erreur lors de la récupération de la position';
//       return null;
//     }
//   }

//   Future<void> startTracking({int? orderId}) async {
//     if (_isTracking) {
//       AppLogger.warning('Location tracking already started');
//       return;
//     }

//     if (!await _checkLocationPermission()) {
//       return;
//     }

//     _isTracking = true;

//     const LocationSettings locationSettings = LocationSettings(
//       accuracy: LocationAccuracy.high,
//       distanceFilter: 10, // Update every 10 meters
//     );

//     _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
//       (Position position) {
//         currentPosition.value = position;
//         _currentPosition = position;
//         _updatePositionToServer(position, orderId);
//       },
//       onError: (error) {
//         AppLogger.error('Error in position stream', error);
//         locationError.value = 'Erreur lors du suivi de position';
//       },
//     );

//     AppLogger.info('Location tracking started');
//   }

//   void stopTracking() {
//     _positionStream?.cancel();
//     _positionStream = null;
//     _isTracking = false;
//     AppLogger.info('Location tracking stopped');
//   }

//   Future<void> _updatePositionToServer(Position position, int? orderId) async {
//     try {
//       final data = <String, dynamic>{
//         'latitude': position.latitude,
//         'longitude': position.longitude,
//         if (position.accuracy > 0) 'accuracy': position.accuracy,
//         if (position.speed >= 0) 'speed': position.speed * 3.6, // Convert to km/h
//         if (position.heading >= 0) 'heading': position.heading,
//         if (orderId != null) 'order_id': orderId,
//       };

//       await _apiService.post('/delivery/position', data: data);
//       AppLogger.debug('Position updated to server');
//     } catch (e) {
//       AppLogger.error('Error updating position to server', e);
//     }
//   }

//   Future<Map<String, dynamic>?> getOrderTracking(int orderId) async {
//     try {
//       final response = await _apiService.get('/orders/$orderId/tracking');
//       if (response.data['success'] == true) {
//         return response.data['data'] as Map<String, dynamic>;
//       }
//       return null;
//     } catch (e) {
//       AppLogger.error('Error getting order tracking', e);
//       return null;
//     }
//   }

//   double? calculateDistance(
//     double startLatitude,
//     double startLongitude,
//     double endLatitude,
//     double endLongitude,
//   ) {
//     try {
//       return Geolocator.distanceBetween(
//         startLatitude,
//         startLongitude,
//         endLatitude,
//         endLongitude,
//       ) / 1000; // Convert to kilometers
//     } catch (e) {
//       AppLogger.error('Error calculating distance', e);
//       return null;
//     }
//   }
// }
