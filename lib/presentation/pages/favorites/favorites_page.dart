import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chelsy_restaurant/core/routes/app_routes.dart';
import 'package:chelsy_restaurant/presentation/controllers/favorite_controller.dart';
import 'package:chelsy_restaurant/presentation/widgets/dish_card.dart';
import 'package:chelsy_restaurant/presentation/widgets/loading_widget.dart';
import 'package:chelsy_restaurant/presentation/widgets/empty_state_widget.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FavoriteController favoriteController =
        Get.find<FavoriteController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Mes favoris')),
      body: Obx(() {
        if (favoriteController.isLoading.value &&
            favoriteController.favorites.isEmpty) {
          return const LoadingWidget();
        }

        if (favoriteController.favorites.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.favorite_outline,
            title: 'Aucun favori',
            message:
                'Ajoutez des plats à vos favoris pour les retrouver facilement',
            buttonText: 'Explorer le menu',
            onButtonTap: () {
              Get.offAllNamed(AppRoutes.home);
            },
          );
        }

        return RefreshIndicator(
          onRefresh: () => favoriteController.loadFavorites(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favoriteController.favorites.length,
            itemBuilder: (context, index) {
              final dish = favoriteController.favorites[index];
              return DishCard(
                dish: dish,
                onTap: () {
                  Get.toNamed(AppRoutes.dishDetail, arguments: dish.id);
                },
              );
            },
          ),
        );
      }),
    );
  }
}
