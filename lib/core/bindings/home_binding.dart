import 'package:chelsy_restaurant/core/services/api_service.dart';
import 'package:chelsy_restaurant/data/repositories/address_repository.dart';
import 'package:chelsy_restaurant/data/repositories/banner_repository.dart';
import 'package:chelsy_restaurant/data/repositories/cart_repository.dart';
import 'package:chelsy_restaurant/data/repositories/dish_repository.dart';
import 'package:chelsy_restaurant/data/repositories/favorite_repository.dart';
import 'package:chelsy_restaurant/data/repositories/order_repository.dart';
import 'package:chelsy_restaurant/data/repositories/promo_repository.dart';
import 'package:chelsy_restaurant/presentation/controllers/address_controller.dart';
import 'package:chelsy_restaurant/presentation/controllers/banner_controller.dart';
import 'package:chelsy_restaurant/presentation/controllers/favorite_controller.dart';
import 'package:chelsy_restaurant/presentation/controllers/order_controller.dart';
import 'package:chelsy_restaurant/presentation/controllers/promo_controller.dart';
import 'package:get/get.dart';
import 'package:chelsy_restaurant/presentation/controllers/dish_controller.dart';
import 'package:chelsy_restaurant/presentation/controllers/cart_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ApiService(), permanent: true);
    Get.put(DishRepository(), permanent: true);
    Get.put(CartRepository(), permanent: true);
    Get.put(BannerRepository(), permanent: true);
    Get.put(FavoriteRepository(), permanent: true);
    Get.put(OrderRepository(), permanent: true);
    Get.put(AddressRepository(), permanent: true);
    Get.put(PromoRepository(), permanent: true);
    Get.put(DishController(), permanent: true);
    Get.put(CartController(), permanent: true);
    Get.put(BannerController(), permanent: true);
    Get.put(FavoriteController(), permanent: true);
    Get.put(OrderController(), permanent: true);
    Get.put(AddressController(), permanent: true);
    Get.put(PromoController(), permanent: true);
  }
}
