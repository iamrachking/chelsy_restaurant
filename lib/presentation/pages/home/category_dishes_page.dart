import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chelsy_restaurant/core/routes/app_routes.dart';
import 'package:chelsy_restaurant/presentation/controllers/dish_controller.dart';
import 'package:chelsy_restaurant/data/models/category_model.dart';
import 'package:chelsy_restaurant/presentation/widgets/dish_card.dart';
import 'package:chelsy_restaurant/presentation/widgets/loading_widget.dart';
import 'package:chelsy_restaurant/presentation/widgets/empty_state_widget.dart';

class CategoryDishesPage extends StatelessWidget {
  final CategoryModel category;

  const CategoryDishesPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final DishController dishController = Get.find<DishController>();

    // Load dishes for this category - utiliser WidgetsBinding pour éviter setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (dishController.dishes.isEmpty || 
          (dishController.dishes.isNotEmpty && dishController.dishes.first.categoryId != category.id)) {
        dishController.filterByCategory(category.id);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
      ),
      body: Obx(
        () {
          if (dishController.isLoading.value && dishController.dishes.isEmpty) {
            return const LoadingWidget();
          }

          if (dishController.dishes.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.restaurant,
              title: 'Aucun plat dans cette catégorie',
              message: 'Cette catégorie ne contient pas encore de plats',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              dishController.filterByCategory(category.id);
            },
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: dishController.dishes.length + (dishController.hasMore.value ? 1 : 0),
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
        },
      ),
    );
  }
}

