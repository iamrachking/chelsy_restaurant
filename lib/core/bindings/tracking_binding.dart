import 'package:get/get.dart';
import 'package:chelsy_restaurant/presentation/controllers/tracking_controller.dart';
import 'package:chelsy_restaurant/core/services/location_service.dart';

class TrackingBinding extends Bindings {
  @override
  void dependencies() {
    Get.find<LocationService>();
    Get.lazyPut(() => TrackingController());
  }
}
