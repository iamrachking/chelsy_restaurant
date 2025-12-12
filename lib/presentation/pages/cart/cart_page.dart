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
            if (cartController.cart.value != null &&
                cartController.cart.value!.items.isNotEmpty) {
              return IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  Get.dialog(
                    AlertDialog(
                      title: const Text('Vider le panier'),
                      content: const Text(
                        'Êtes-vous sûr de vouloir vider votre panier ?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('Annuler'),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.back();
                            cartController.clearCart();
                          },
                          child: const Text('Vider'),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        if (cartController.isLoading.value &&
            cartController.cart.value == null) {
          return const LoadingWidget();
        }

        final cart = cartController.cart.value;
        if (cart == null || cart.items.isEmpty) {
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
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: item.dish?.image != null
                            ? Image.network(
                                item.dish!.image!,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.restaurant, size: 40),
                              )
                            : const Icon(Icons.restaurant, size: 40),
                      ),
                      title: Text(item.dish?.name ?? 'Plat'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            DateFormatter.formatCurrency(item.unitPrice),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                  size: 20,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: item.quantity > 1
                                    ? () {
                                        cartController.updateCartItem(
                                          itemId: item.id,
                                          quantity: item.quantity - 1,
                                        );
                                      }
                                    : null,
                              ),
                              Text('${item.quantity}'),
                              IconButton(
                                icon: const Icon(
                                  Icons.add_circle_outline,
                                  size: 20,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
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
                      trailing: SizedBox(
                        width: 60, // largeur fixe pour éviter overflow
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormatter.formatCurrency(item.totalPrice),
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: AppColors.error,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                cartController.removeCartItem(item.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
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
                          'Total',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          DateFormatter.formatCurrency(cart.subtotal),
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Passer la commande',
                      onPressed: () {
                        Get.toNamed(AppRoutes.checkout);
                      },
                      width: double.infinity,
                      icon: Icons.shopping_bag,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
