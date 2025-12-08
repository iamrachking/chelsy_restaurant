import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chelsy_restaurant/core/routes/app_routes.dart';
import 'package:chelsy_restaurant/core/theme/app_colors.dart';
import 'package:chelsy_restaurant/presentation/controllers/auth_controller.dart';
import 'package:chelsy_restaurant/presentation/controllers/dish_controller.dart';
import 'package:chelsy_restaurant/presentation/controllers/cart_controller.dart';
import 'package:chelsy_restaurant/presentation/controllers/notification_badge_controller.dart';
import 'package:chelsy_restaurant/presentation/widgets/dish_card.dart';
import 'package:chelsy_restaurant/presentation/widgets/search_field.dart';
import 'package:chelsy_restaurant/presentation/widgets/banner_carousel.dart';
import 'package:chelsy_restaurant/presentation/widgets/category_bottom_sheet.dart';
import 'package:chelsy_restaurant/presentation/widgets/loading_widget.dart';
import 'package:chelsy_restaurant/presentation/controllers/banner_controller.dart';
import 'package:chelsy_restaurant/data/models/category_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DishController dishController = Get.find<DishController>();
  final CartController cartController = Get.find<CartController>();
  final AuthController authController = Get.find<AuthController>();
  final NotificationBadgeController notificationController = Get.put(
    NotificationBadgeController(),
  );
  final BannerController bannerController = Get.find<BannerController>();
  final TextEditingController _searchController = TextEditingController();
  final int _maxDishesToShow = 6; // Limite de plats à afficher

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      dishController.loadDishes(refresh: true);
    } else {
      dishController.searchDishes(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bannerHeight = screenHeight * 0.25; // 25% de la hauteur de l'écran

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Custom AppBar
            SliverAppBar(
              floating: true,
              pinned: true,
              backgroundColor: AppColors.white,
              elevation: 0,
              leading: Obx(() {
                final user = authController.currentUser.value;
                return GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.profile),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: user?.avatar != null
                        ? ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: user!.avatar!,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.person),
                            ),
                          )
                        : const Icon(Icons.person, color: AppColors.primary),
                  ),
                );
              }),
              title: Obx(() {
                final restaurant = dishController.restaurant.value;
                return Text(
                  restaurant?['name'] ?? 'CHELSY Restaurant',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }),
              centerTitle: true,
              actions: [
                Obx(
                  () => Stack(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.black87,
                        ),
                        onPressed: () {
                          Get.toNamed(AppRoutes.notifications);
                        },
                      ),
                      if (notificationController.hasUnread)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              notificationController.unreadCount.value > 99
                                  ? '99+'
                                  : '${notificationController.unreadCount.value}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            // Search field
            SliverToBoxAdapter(
              child: SearchField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                hint: 'Rechercher un plat...',
              ),
            ),
            // Banner carousel
            SliverToBoxAdapter(
              child: Obx(() {
                final banners = bannerController.banners;
                if (banners.isEmpty) {
                  // Fallback sur les images du restaurant si pas de bannières
                  final restaurant = dishController.restaurant.value;
                  final images = restaurant?['images'] as List<dynamic>? ?? [];
                  if (images.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return BannerCarousel(
                    images: images.map((img) => img.toString()).toList(),
                    height: bannerHeight,
                    autoPlayInterval: const Duration(seconds: 20),
                  );
                }
                return BannerCarousel(
                  banners: banners,
                  height: bannerHeight,
                  autoPlayInterval: const Duration(seconds: 20),
                );
              }),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            // Navigation menu
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMenuButton(
                      context,
                      icon: Icons.restaurant_menu,
                      label: 'Menu',
                      onTap: () {
                        Get.toNamed(AppRoutes.allDishes);
                      },
                    ),
                    _buildMenuButton(
                      context,
                      icon: Icons.star,
                      label: 'Plats mise en avant',
                      onTap: () {
                        dishController.loadDishes(
                          isFeatured: true,
                          refresh: true,
                        );
                        Get.toNamed(AppRoutes.allDishes);
                      },
                    ),
                    _buildMenuButton(
                      context,
                      icon: Icons.new_releases,
                      label: 'Nouveautés',
                      onTap: () {
                        dishController.loadDishes(isNew: true, refresh: true);
                        Get.toNamed(AppRoutes.allDishes);
                      },
                    ),
                    _buildMenuButton(
                      context,
                      icon: Icons.local_dining,
                      label: 'Spécialités',
                      onTap: () {
                        dishController.loadDishes(
                          isSpecialty: true,
                          refresh: true,
                        );
                        Get.toNamed(AppRoutes.allDishes);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            // Categories section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Catégories',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    TextButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => CategoryBottomSheet(
                            categories: dishController.categories,
                          ),
                        );
                      },
                      child: Text(
                        'Voir tout',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            // Categories grid
            SliverToBoxAdapter(
              child: Obx(() {
                if (dishController.categories.isEmpty) {
                  return const SizedBox.shrink();
                }
                return SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: dishController.categories.length,
                    itemBuilder: (context, index) {
                      final category = dishController.categories[index];
                      return _buildCategoryItem(context, category);
                    },
                  ),
                );
              }),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            // Dishes section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Nos plats',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    TextButton(
                      onPressed: () {
                        Get.toNamed(AppRoutes.allDishes);
                      },
                      child: Text(
                        'Voir tout',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            // Dishes grid (limited)
            Obx(() {
              if (dishController.isLoading.value &&
                  dishController.dishes.isEmpty) {
                return const SliverFillRemaining(child: LoadingWidget());
              }

              if (dishController.dishes.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'Aucun plat disponible',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                );
              }

              final dishesToShow = dishController.dishes
                  .take(_maxDishesToShow)
                  .toList();

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 5,
                    childAspectRatio: 0.88,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    if (index < dishesToShow.length) {
                      final dish = dishesToShow[index];
                      return DishCard(
                        dish: dish,
                        onTap: () {
                          Get.toNamed(AppRoutes.dishDetail, arguments: dish.id);
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  }, childCount: dishesToShow.length),
                ),
              );
            }),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, CategoryModel category) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(AppRoutes.categoryDishes, arguments: category);
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.1),
                image: category.image != null
                    ? DecorationImage(
                        image: NetworkImage(category.image!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: category.image == null
                  ? Icon(Icons.restaurant, size: 35, color: AppColors.primary)
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
