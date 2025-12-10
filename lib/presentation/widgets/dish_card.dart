import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chelsy_restaurant/data/models/dish_model.dart';
import 'package:chelsy_restaurant/core/utils/date_formatter.dart';
import 'package:chelsy_restaurant/core/theme/app_colors.dart';
import 'package:chelsy_restaurant/presentation/controllers/favorite_controller.dart';

class DishCard extends StatelessWidget {
  final DishModel dish;
  final VoidCallback? onTap;

  const DishCard({super.key, required this.dish, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: CachedNetworkImage(
                    imageUrl:
                    dish.image ??
                        (dish.images.isNotEmpty ? dish.images.first : ''),
                    width: double.infinity,
                    height: 120,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 120,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 150,
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.restaurant,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                // Badges
                Positioned(
                  top: 8,
                  left: 8,
                  child: Row(
                    children: [
                      if (dish.isNew)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Nouveau',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (dish.isFeatured) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '⭐',
                            style: TextStyle(fontSize: 10),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Favorite button
                Obx(() {
                  final favoriteController = Get.find<FavoriteController>();
                  final isFavorite = favoriteController.isFavorite(dish.id);
                  return Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => favoriteController.toggleFavorite(dish.id),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? AppColors.error : Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                // Discount badge
                if (dish.hasDiscount)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '-${((dish.price - dish.finalPrice) / dish.price * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Content
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    dish.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (dish.description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      dish.description!,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            if (dish.averageRating != null) ...[
                              const Icon(
                                Icons.star,
                                color: AppColors.warning,
                                size: 14,
                              ),
                              const SizedBox(width: 2),
                              Flexible(
                                child: Text(
                                  dish.averageRating!.toStringAsFixed(1),
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.copyWith(fontSize: 11),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                            ],
                            Icon(
                              Icons.access_time,
                              size: 12,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                '${dish.preparationTimeMinutes} min',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(fontSize: 11),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Prix toujours visible à droite
                      Text(
                        DateFormatter.formatCurrency(dish.finalPrice),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}