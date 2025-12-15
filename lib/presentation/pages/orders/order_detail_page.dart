import 'package:chelsy_restaurant/presentation/widgets/invoice_actions_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chelsy_restaurant/core/routes/app_routes.dart';
import 'package:chelsy_restaurant/core/utils/date_formatter.dart';
import 'package:chelsy_restaurant/core/theme/app_colors.dart';
import 'package:chelsy_restaurant/presentation/controllers/order_controller.dart';
import 'package:chelsy_restaurant/presentation/widgets/loading_widget.dart';
import 'package:chelsy_restaurant/presentation/widgets/custom_button.dart';

class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({super.key});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  late OrderController orderController;
  late int orderId;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    orderId = Get.arguments as int;
    orderController = Get.find<OrderController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrder();
    });
  }

  Future<void> _loadOrder() async {
    if (mounted && !_isInitialized) {
      _isInitialized = true;
      if (orderController.selectedOrder.value?.id != orderId) {
        await orderController.getOrder(orderId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détails de la commande')),
      body: Obx(() {
        if (orderController.isLoading.value &&
            orderController.selectedOrder.value == null) {
          return const LoadingWidget();
        }

        final order = orderController.selectedOrder.value;
        if (order == null) {
          return const Center(child: Text('Commande non trouvée'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              order.orderNumber,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                order.status,
                              ).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _getStatusText(order.status),
                              style: TextStyle(
                                color: _getStatusColor(order.status),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Date: ${DateFormatter.formatDateTime(order.createdAt)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Items section
              Text('Articles', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              ...order.items.map((item) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(item.dishName),
                    subtitle: Text('Quantité: ${item.quantity}'),
                    trailing: Text(
                      DateFormatter.formatCurrency(item.totalPrice),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sous-total',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Text(DateFormatter.formatCurrency(order.subtotal)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (order.type == 'delivery')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Frais de livraison',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Text(
                              DateFormatter.formatCurrency(order.deliveryFee),
                            ),
                          ],
                        ),
                      if (order.discountAmount > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Réduction',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Text(
                              '-${DateFormatter.formatCurrency(order.discountAmount)}',
                              style: TextStyle(color: AppColors.success),
                            ),
                          ],
                        ),
                      ],
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            DateFormatter.formatCurrency(order.total),
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Télécharger la facture',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => InvoiceActionsDialog(
                      orderId: order.id,
                      orderNumber: order.orderNumber,
                      orderController: orderController,
                    ),
                  );
                },
                icon: Icons.receipt_long,
                width: double.infinity,
              ),
              const SizedBox(height: 16),
              // Actions buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.rate_review),
                      label: const Text('Avis'),
                      onPressed: () {
                        Get.toNamed(
                          AppRoutes.createReview,
                          arguments: {'orderId': order.id},
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.report_problem),
                      label: const Text('Réclamation'),
                      onPressed: () {
                        Get.toNamed(
                          AppRoutes.createComplaint,
                          arguments: order.id,
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (order.status == 'out_for_delivery' || order.status == 'ready')
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: CustomButton(
                    text: 'Suivre la livraison',
                    onPressed: () {
                      Get.toNamed(AppRoutes.orderTracking, arguments: order.id);
                    },
                    icon: Icons.local_shipping,
                    width: double.infinity,
                  ),
                ),
              // Cancel order button
              if (order.canCancel)
                ElevatedButton(
                  onPressed: () {
                    Get.dialog(
                      AlertDialog(
                        title: const Text('Annuler la commande'),
                        content: const Text(
                          'Êtes-vous sûr de vouloir annuler cette commande ?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text('Non'),
                          ),
                          TextButton(
                            onPressed: () {
                              Get.back();
                              orderController.cancelOrder(order.id);
                            },
                            child: const Text('Oui'),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Annuler la commande'),
                ),
              const SizedBox(height: 16),
            ],
          ),
        );
      }),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.orderPending;
      case 'confirmed':
        return AppColors.orderConfirmed;
      case 'preparing':
        return AppColors.orderPreparing;
      case 'ready':
        return AppColors.orderReady;
      case 'delivered':
      case 'picked_up':
        return AppColors.orderDelivered;
      case 'cancelled':
        return AppColors.orderCancelled;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'confirmed':
        return 'Confirmée';
      case 'preparing':
        return 'En préparation';
      case 'ready':
        return 'Prête';
      case 'out_for_delivery':
        return 'En livraison';
      case 'delivered':
        return 'Livrée';
      case 'picked_up':
        return 'Récupérée';
      case 'cancelled':
        return 'Annulée';
      default:
        return status;
    }
  }
}
