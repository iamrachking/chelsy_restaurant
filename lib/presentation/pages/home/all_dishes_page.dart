import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chelsy_restaurant/core/routes/app_routes.dart';
import 'package:chelsy_restaurant/presentation/controllers/dish_controller.dart';
import 'package:chelsy_restaurant/presentation/widgets/dish_card.dart';
import 'package:chelsy_restaurant/presentation/widgets/loading_widget.dart';
import 'package:chelsy_restaurant/presentation/widgets/empty_state_widget.dart';

class AllDishesPage extends StatelessWidget {
  const AllDishesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final DishController dishController = Get.find<DishController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Tous les plats')),
      body: Obx(() {
        if (dishController.isLoading.value && dishController.dishes.isEmpty) {
          return const LoadingWidget();
        }

        if (dishController.dishes.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.restaurant,
            title: 'Aucun plat disponible',
            message: 'Vérifiez votre connexion internet',
          );
        }

        return RefreshIndicator(
          onRefresh: () => dishController.loadDishes(refresh: true),
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 2,
              mainAxisSpacing: 8,
              childAspectRatio: 0.90,
            ),
            itemCount:
            dishController.dishes.length +
                (dishController.hasMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < dishController.dishes.length) {
                final dish = dishController.dishes[index];
                return DishCard(
                  dish: dish,
                  onTap: () {
                    Get.toNamed(AppRoutes.dishDetail, arguments: dish.id);
                  },
                );
              } else if (dishController.hasMore.value) {
                dishController.loadDishes();
                return const Center(child: CircularProgressIndicator());
              }
              return const SizedBox.shrink();
            },
          ),
        );
      }),
    );
  }
}