import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chelsy_restaurant/data/models/banner_model.dart';
import 'package:chelsy_restaurant/core/routes/app_routes.dart';
import 'package:chelsy_restaurant/data/models/category_model.dart';
import 'package:chelsy_restaurant/presentation/controllers/dish_controller.dart';

class BannerCarousel extends StatefulWidget {
  final List<BannerModel>? banners;
  final List<String>? images; // Pour compatibilité avec l'ancien code
  final double height;
  final Duration autoPlayInterval;

  const BannerCarousel({
    super.key,
    this.banners,
    this.images,
    this.height = 200,
    this.autoPlayInterval = const Duration(seconds: 20),
  });

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentIndex = 0;

  List<BannerModel> get _banners {
    if (widget.banners != null && widget.banners!.isNotEmpty) {
      return widget.banners!;
    }
    // Fallback pour compatibilité avec l'ancien code
    if (widget.images != null && widget.images!.isNotEmpty) {
      return widget.images!
          .map(
            (image) => BannerModel(
              id: widget.images!.indexOf(image),
              image: image,
              order: widget.images!.indexOf(image),
              isActive: true,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          )
          .toList();
    }
    return [];
  }

  @override
  void initState() {
    super.initState();
    if (_banners.length > 1) {
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(widget.autoPlayInterval, (timer) {
      if (_currentIndex < _banners.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _handleBannerTap(BannerModel banner) {
    if (banner.link == null || banner.link!.isEmpty) {
      return;
    }

    // Parser le lien pour déterminer la navigation
    final link = banner.link!;

    // Si c'est un lien de catégorie
    if (link.startsWith('/categories/')) {
      final categoryId = int.tryParse(link.split('/').last);
      if (categoryId != null) {
        // Charger la catégorie depuis le DishController
        final dishController = Get.find<DishController>();
        final category = dishController.categories.firstWhereOrNull(
          (cat) => cat.id == categoryId,
        );

        if (category != null) {
          Get.toNamed(AppRoutes.categoryDishes, arguments: category);
        } else {
          // Si la catégorie n'est pas trouvée, créer un modèle temporaire
          Get.toNamed(
            AppRoutes.categoryDishes,
            arguments: CategoryModel(
              id: categoryId,
              name: banner.title ?? 'Catégorie',
              slug: '',
              description: '',
              image: '',
              order: 0,
              isActive: true,
            ),
          );
        }
      }
    }
    // Autres types de liens peuvent être ajoutés ici (ex: liens vers des plats, pages spécifiques, etc.)
  }

  @override
  Widget build(BuildContext context) {
    if (_banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: _banners.length,
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: () => _handleBannerTap(banner),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: banner.image,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.error),
                          ),
                        ),
                        if (banner.title != null && banner.title!.isNotEmpty)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 20,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.3),
                                    Colors.black.withOpacity(0.8),
                                  ],
                                  stops: const [0.0, 0.5, 1.0],
                                ),
                              ),
                              child: Text(
                                banner.title!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(0, 1),
                                      blurRadius: 3,
                                      color: Colors.black54,
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          // Indicateurs de page
          if (_banners.length > 1)
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _banners.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
