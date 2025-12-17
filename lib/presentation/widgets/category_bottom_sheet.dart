import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chelsy_restaurant/data/models/category_model.dart';
import 'package:chelsy_restaurant/core/routes/app_routes.dart';

class CategoryBottomSheet extends StatelessWidget {
  final List<CategoryModel> categories;

  const CategoryBottomSheet({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Toutes les catégories',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return GestureDetector(
                      onTap: () {
                        Get.back();
                        Get.toNamed(
                          AppRoutes.categoryDishes,
                          arguments: category,
                        );
                      },
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[200],
                                image: category.image != null
                                    ? DecorationImage(
                                        image: NetworkImage(category.image!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: category.image == null
                                  ? Icon(
                                      Icons.restaurant,
                                      size: 40,
                                      color: Colors.grey[400],
                                    )
                                  : null,
                            ),
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
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
