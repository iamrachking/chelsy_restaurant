import 'package:get/get.dart';
import 'package:chelsy_restaurant/core/services/api_service.dart';
import 'package:chelsy_restaurant/core/utils/app_logger.dart';
import 'package:chelsy_restaurant/data/models/banner_model.dart';

class BannerRepository {
  final ApiService _apiService = Get.find<ApiService>();

  // Get banners
  Future<List<BannerModel>> getBanners() async {
    try {
      final response = await _apiService.get('/banners');
      if (response.data['success'] == true) {
        final banners = response.data['data']['banners'] as List<dynamic>?;
        if (banners != null) {
          final bannerList = banners
              .map(
                (banner) =>
                    BannerModel.fromJson(banner as Map<String, dynamic>),
              )
              .where((banner) => banner.isActive)
              .toList();

          // Trier par order (croissant)
          bannerList.sort((a, b) => a.order.compareTo(b.order));

          return bannerList;
        }
      }
      return [];
    } catch (e) {
      AppLogger.error('Get banners error', e);
      return [];
    }
  }
}
