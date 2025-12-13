import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chelsy_restaurant/core/routes/app_routes.dart';
import 'package:chelsy_restaurant/core/utils/date_formatter.dart';
import 'package:chelsy_restaurant/core/theme/app_colors.dart';
import 'package:chelsy_restaurant/presentation/controllers/cart_controller.dart';
import 'package:chelsy_restaurant/presentation/widgets/custom_button.dart';
import 'package:chelsy_restaurant/presentation/widgets/loading_widget.dart';
import 'package:chelsy_restaurant/presentation/widgets/empty_state_widget.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find<CartController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panier'),
        actions: [
          Obx(() {
            if (cartController.cart.value.items.isNotEmpty) {
              return IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Vider le panier',
                onPressed: () {
                  _showClearCartDialog(context, cartController);
                },
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        if (cartController.isLoading.value &&
            cartController.cart.value.items.isEmpty) {
          return const LoadingWidget();
        }

        final cart = cartController.cart.value;

        if (cart.items.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.shopping_cart_outlined,
            title: 'Votre panier est vide',
            message: 'Ajoutez des plats pour commencer',
            buttonText: 'Explorer le menu',
            onButtonTap: () {
              Get.offAllNamed(AppRoutes.main);
            },
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: cart.items.length,
                itemBuilder: (context, index) {
                  final item = cart.items[index];
                  return _buildCartItem(context, item, cartController);
                },
              ),
            ),

            _buildCartSummary(context, cart, cartController),
          ],
        );
      }),
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    dynamic item,
    CartController cartController,
  ) {
    // CORRECTION: Calculer le prix total dynamiquement
    final itemTotalPrice = item.unitPrice * item.quantity;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildDishImage(item),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.dish?.name ?? 'Plat',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '${DateFormatter.formatCurrency(item.unitPrice)} / pièce',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      _buildQuantityButton(
                        icon: Icons.remove_circle_outline,
                        onPressed: item.quantity > 1
                            ? () {
                                cartController.updateCartItem(
                                  itemId: item.id,
                                  quantity: item.quantity - 1,
                                );
                              }
                            : null,
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '${item.quantity}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),

                      _buildQuantityButton(
                        icon: Icons.add_circle_outline,
                        onPressed: () {
                          cartController.updateCartItem(
                            itemId: item.id,
                            quantity: item.quantity + 1,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // CORRECTION: Utiliser le prix calculé dynamiquement
                Text(
                  DateFormatter.formatCurrency(itemTotalPrice),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(height: 8),

                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: AppColors.error,
                  onPressed: () {
                    _showRemoveItemDialog(context, item, cartController);
                  },
                  tooltip: 'Supprimer',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDishImage(dynamic item) {
    if (item.dish?.image != null) {
      return Image.network(
        item.dish!.image!,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildImagePlaceholder();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildImagePlaceholder();
        },
      );
    }

    return _buildImagePlaceholder();
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey[200],
      child: const Icon(Icons.restaurant, size: 40, color: Colors.grey),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(4),
        child: Icon(
          icon,
          size: 24,
          color: onPressed != null ? AppColors.primary : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildCartSummary(
    BuildContext context,
    dynamic cart,
    CartController cartController,
  ) {
    // CORRECTION: Recalculer le total dynamiquement
    final calculatedTotal = cart.items.fold<double>(
      0.0,
      (double sum, item) => sum + (item.unitPrice * item.quantity),
    );

    return Container(
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${cart.items.length} plat(s) différent(s)',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  '${cart.totalItems} au total',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),

            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // CORRECTION: Utiliser le total calculé
                Text(
                  DateFormatter.formatCurrency(calculatedTotal),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Obx(() {
              return CustomButton(
                text: 'Passer la commande',
                onPressed: cartController.isLoading.value
                    ? null
                    : () {
                        Get.toNamed(AppRoutes.checkout);
                      },
                width: double.infinity,
                icon: Icons.shopping_bag,
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showClearCartDialog(
    BuildContext context,
    CartController cartController,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Vider le panier'),
        content: const Text(
          'Êtes-vous sûr de vouloir vider votre panier ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              Get.back();
              cartController.clearCart();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Vider'),
          ),
        ],
      ),
    );
  }

  void _showRemoveItemDialog(
    BuildContext context,
    dynamic item,
    CartController cartController,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Retirer l\'article'),
        content: Text(
          'Voulez-vous retirer "${item.dish?.name ?? 'cet article'}" du panier ?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              Get.back();
              cartController.removeCartItem(item.id);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Retirer'),
          ),
        ],
      ),
    );
  }
}
