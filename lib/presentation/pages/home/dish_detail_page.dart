import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chelsy_restaurant/core/routes/app_routes.dart';
import 'package:chelsy_restaurant/core/utils/date_formatter.dart';
import 'package:chelsy_restaurant/core/theme/app_colors.dart';
import 'package:chelsy_restaurant/presentation/controllers/dish_controller.dart';
import 'package:chelsy_restaurant/presentation/controllers/cart_controller.dart';
import 'package:chelsy_restaurant/presentation/widgets/custom_button.dart';
import 'package:chelsy_restaurant/presentation/widgets/loading_widget.dart';

class DishDetailPage extends StatefulWidget {
  const DishDetailPage({super.key});

  int get dishId => Get.arguments as int;

  @override
  State<DishDetailPage> createState() => _DishDetailPageState();
}

class _DishDetailPageState extends State<DishDetailPage> {
  final DishController _dishController = Get.find<DishController>();
  final CartController _cartController = Get.find<CartController>();
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _dishController.getDish(widget.dishId);
    });
  }

  void _addToCart() {
    final dish = _dishController.selectedDish.value;
    if (dish != null) {
      _cartController.addToCart(
        dishId: dish.id,
        quantity: _quantity,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () {
          if (_dishController.isLoading.value && _dishController.selectedDish.value == null) {
            return const LoadingWidget();
          }

          final dish = _dishController.selectedDish.value;
          if (dish == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Détails')),
              body: const Center(child: Text('Plat non trouvé')),
            );
          }

          return CustomScrollView(
            slivers: [
              // App bar with image
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: CachedNetworkImage(
                    imageUrl: dish.image ?? (dish.images.isNotEmpty ? dish.images.first : ''),
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.restaurant, size: 50),
                    ),
                  ),
                ),
              ),
              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              dish.name,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ),
                          Text(
                            DateFormatter.formatCurrency(dish.finalPrice),
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Rating and time
                      Row(
                        children: [
                          if (dish.averageRating != null) ...[
                            const Icon(Icons.star, color: AppColors.warning, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              '${dish.averageRating!.toStringAsFixed(1)} (${dish.reviewCount})',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(width: 16),
                          ],
                          const Icon(Icons.access_time, size: 18, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            '${dish.preparationTimeMinutes} min',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Description
                      if (dish.description != null) ...[
                        Text(
                          'Description',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dish.description!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                      ],
                      // Allergens
                      if (dish.allergens.isNotEmpty) ...[
                        Text(
                          'Allergènes',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: dish.allergens.map((allergen) {
                            return Chip(
                              label: Text(allergen),
                              backgroundColor: Colors.red[50],
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],
                      // Reviews section
                      Text(
                        'Avis (${dish.reviewCount})',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.rate_review),
                              label: const Text('Voir les avis'),
                              onPressed: () {
                                Get.toNamed(AppRoutes.dishReviews, arguments: dish.id);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.edit),
                            label: const Text('Laisser un avis'),
                            onPressed: () {
                              Get.toNamed(AppRoutes.createReview, arguments: {'dishId': dish.id});
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Quantity selector
                      Text(
                        'Quantité',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: _quantity > 1
                                ? () {
                                    setState(() {
                                      _quantity--;
                                    });
                                  }
                                : null,
                          ),
                          Text(
                            '$_quantity',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () {
                              setState(() {
                                _quantity++;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: CustomButton(
            text: 'Ajouter au panier',
            onPressed: _addToCart,
            icon: Icons.shopping_cart,
          ),
        ),
      ),
    );
  }
}

