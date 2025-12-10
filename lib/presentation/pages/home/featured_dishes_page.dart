import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chelsy_restaurant/core/routes/app_routes.dart';
import 'package:chelsy_restaurant/presentation/controllers/dish_controller.dart';
import 'package:chelsy_restaurant/presentation/widgets/dish_card.dart';
import 'package:chelsy_restaurant/presentation/widgets/loading_widget.dart';
import 'package:chelsy_restaurant/presentation/widgets/empty_state_widget.dart';

class FeaturedDishesPage extends StatelessWidget {
  const FeaturedDishesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final DishController dishController = Get.find<DishController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Plats mise en avant')),
      body: Obx(() {
        final dishes = dishController.featuredDishes;

        if (dishController.isLoading.value && dishes.isEmpty) {
          return const LoadingWidget();
        }

        if (dishes.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.restaurant,
            title: 'Aucun plat disponible',
            message: 'Vérifiez votre connexion internet',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await dishController.loadFeaturedDishes(refresh: true);
          },
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 2,
              mainAxisSpacing: 8,
              childAspectRatio: 0.90,
            ),
            itemCount: dishes.length,
            itemBuilder: (context, index) {
              final dish = dishes[index];
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
