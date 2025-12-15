import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chelsy_restaurant/core/theme/app_colors.dart';
import 'package:chelsy_restaurant/presentation/controllers/order_controller.dart';

class InvoiceActionsDialog extends StatelessWidget {
  final int orderId;
  final String orderNumber;
  final OrderController orderController;

  const InvoiceActionsDialog({
    super.key,
    required this.orderId,
    required this.orderNumber,
    required this.orderController,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                Icons.receipt_long,
                color: AppColors.primary,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Facture',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              orderNumber,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Obx(() {
              final isDownloading = orderController.isDownloadingInvoice.value;
              final progress = orderController.downloadProgress.value;

              if (isDownloading) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      progress.isNotEmpty ? progress : 'Chargement en cours...',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _InvoiceActionButton(
                    icon: Icons.download,
                    label: 'Télécharger',
                    color: AppColors.primary,
                    onPressed: () async {
                      final success = await orderController
                          .downloadOrderInvoice(orderId);
                      if (success && Get.isDialogOpen == true) {
                        Get.back();
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  _InvoiceActionButton(
                    icon: Icons.open_in_new,
                    label: 'Ouvrir',
                    color: Colors.blue,
                    onPressed: () async {
                      await orderController.openOrderInvoice(orderId);
                      if (Get.isDialogOpen == true) {
                        Get.back();
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  _InvoiceActionButton(
                    icon: Icons.share,
                    label: 'Partager',
                    color: Colors.green,
                    onPressed: () async {
                      await orderController.shareOrderInvoice(orderId);
                      if (Get.isDialogOpen == true) {
                        Get.back();
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        'Fermer',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _InvoiceActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _InvoiceActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.1),
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
