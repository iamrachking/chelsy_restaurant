import 'package:chelsy_restaurant/core/services/api_service.dart';
import 'package:chelsy_restaurant/data/repositories/banner_repository.dart';
import 'package:chelsy_restaurant/data/repositories/cart_repository.dart';
import 'package:chelsy_restaurant/data/repositories/dish_repository.dart';
import 'package:chelsy_restaurant/data/repositories/favorite_repository.dart';
import 'package:chelsy_restaurant/presentation/controllers/banner_controller.dart';
import 'package:chelsy_restaurant/presentation/controllers/favorite_controller.dart';
import 'package:get/get.dart';
import 'package:chelsy_restaurant/presentation/controllers/dish_controller.dart';
import 'package:chelsy_restaurant/presentation/controllers/cart_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ApiService());
    Get.lazyPut(() => DishRepository());
    Get.lazyPut(() => DishController());
    Get.lazyPut(() => CartRepository());
    Get.lazyPut(() => CartController());
    Get.lazyPut(() => BannerRepository());
    Get.lazyPut(() => BannerController());
    Get.lazyPut(() => FavoriteRepository());
    Get.lazyPut(() => FavoriteController());
  }
}
