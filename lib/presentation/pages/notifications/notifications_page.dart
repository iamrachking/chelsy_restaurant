import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chelsy_restaurant/core/theme/app_colors.dart';
import 'package:chelsy_restaurant/presentation/controllers/notification_badge_controller.dart';
import 'package:chelsy_restaurant/presentation/widgets/empty_state_widget.dart';
import 'package:chelsy_restaurant/core/utils/date_formatter.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationBadgeController notificationController =
        Get.find<NotificationBadgeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          Obx(
            () => notificationController.unreadCount.value > 0
                ? IconButton(
                    icon: const Icon(Icons.mark_email_read),
                    onPressed: () {
                      notificationController.resetUnread();
                      Get.snackbar('Succès', 'Toutes les notifications ont été marquées comme lues');
                    },
                    tooltip: 'Marquer tout comme lu',
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Obx(
        () {
          // Pour l'instant, on utilise les notifications locales
          // TODO: Récupérer les notifications depuis l'API
          final hasNotifications = notificationController.unreadCount.value > 0;

          if (!hasNotifications) {
            return EmptyStateWidget(
              icon: Icons.notifications_none_outlined,
              title: 'Aucune notification',
              message: 'Vous n\'avez pas de nouvelles notifications',
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Exemple de notification - À remplacer par les vraies notifications de l'API
              _buildNotificationTile(
                context,
                title: 'Nouvelle commande',
                message: 'Votre commande #1234 a été confirmée',
                time: DateTime.now().subtract(const Duration(minutes: 5)),
                isRead: false,
                onTap: () {
                  // Naviguer vers les détails de la commande
                },
              ),
              const Divider(),
              _buildNotificationTile(
                context,
                title: 'Statut de commande',
                message: 'Votre commande #1234 est en cours de préparation',
                time: DateTime.now().subtract(const Duration(hours: 2)),
                isRead: false,
                onTap: () {
                  // Naviguer vers les détails de la commande
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotificationTile(
    BuildContext context, {
    required String title,
    required String message,
    required DateTime time,
    required bool isRead,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: isRead ? Colors.grey[300] : AppColors.primary,
        child: Icon(
          Icons.notifications,
          color: isRead ? Colors.grey[600] : Colors.white,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
          color: isRead ? Colors.grey[600] : Colors.black87,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            message,
            style: TextStyle(
              color: isRead ? Colors.grey[500] : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormatter.formatRelativeTime(time),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
      trailing: isRead
          ? null
          : Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
      onTap: onTap,
    );
  }
}

