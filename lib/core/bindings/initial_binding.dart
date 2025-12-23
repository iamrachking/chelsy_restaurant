import 'package:chelsy_restaurant/data/repositories/address_repository.dart';
import 'package:chelsy_restaurant/data/repositories/favorite_repository.dart';
import 'package:chelsy_restaurant/data/repositories/order_repository.dart';
import 'package:chelsy_restaurant/data/repositories/promo_repository.dart';
import 'package:chelsy_restaurant/data/repositories/review_repository.dart';
import 'package:get/get.dart';
import 'package:chelsy_restaurant/data/repositories/banner_repository.dart';
import 'package:chelsy_restaurant/data/repositories/profile_repository.dart';
import 'package:chelsy_restaurant/presentation/controllers/auth_controller.dart';
import 'package:chelsy_restaurant/core/services/storage_service.dart';
import 'package:chelsy_restaurant/core/services/api_service.dart';
import 'package:chelsy_restaurant/data/repositories/auth_repository.dart';
import 'package:chelsy_restaurant/data/repositories/dish_repository.dart';
import 'package:chelsy_restaurant/data/repositories/cart_repository.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.put(StorageService(), permanent: true);
    Get.put(ApiService(), permanent: true);

    // Repositories
    Get.put(AuthRepository(), permanent: true);
    Get.put(DishRepository(), permanent: true);
    Get.put(CartRepository(), permanent: true);
    Get.put(BannerRepository(), permanent: true);
    Get.put(ProfileRepository(), permanent: true);
    Get.put(OrderRepository(), permanent: true);
    Get.put(PromoRepository(), permanent: true);
    Get.put(AddressRepository(), permanent: true);
    Get.put(FavoriteRepository(), permanent: true);
    Get.put(ReviewRepository(), permanent: true);
    // Controllers permanents
    Get.put(AuthController(), permanent: true);
  }
}
