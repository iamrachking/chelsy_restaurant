import 'package:get/get.dart';
import 'package:chelsy_restaurant/data/repositories/banner_repository.dart';
import 'package:chelsy_restaurant/data/models/banner_model.dart';
import 'package:chelsy_restaurant/core/utils/app_logger.dart';

class BannerController extends GetxController {
  final BannerRepository _bannerRepository = Get.find<BannerRepository>();

  final RxList<BannerModel> banners = <BannerModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadBanners();
  }

  Future<void> loadBanners() async {
    try {
      isLoading.value = true;
      final bannersList = await _bannerRepository.getBanners();
      banners.value = bannersList;
    } catch (e) {
      AppLogger.error('Load banners error', e);
    } finally {
      isLoading.value = false;
    }
  }
}
