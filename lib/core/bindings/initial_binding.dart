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

    // Controllers permanents
    Get.put(AuthController(), permanent: true);
  }
}
