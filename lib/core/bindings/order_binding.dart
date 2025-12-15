import 'package:get/get.dart';
import 'package:chelsy_restaurant/presentation/controllers/order_controller.dart';
import 'package:chelsy_restaurant/presentation/controllers/address_controller.dart';

class OrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OrderController());
    Get.lazyPut(() => AddressController());
  }
}

