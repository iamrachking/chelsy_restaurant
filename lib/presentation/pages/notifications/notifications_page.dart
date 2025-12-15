import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chelsy_restaurant/core/theme/app_colors.dart';
import 'package:chelsy_restaurant/presentation/controllers/notification_badge_controller.dart';
import 'package:chelsy_restaurant/presentation/widgets/empty_state_widget.dart';
import 'package:chelsy_restaurant/core/utils/date_formatter.dart';
// import 'package:chelsy_restaurant/core/services/api_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // final ApiService _apiService = Get.find<ApiService>();
  final NotificationBadgeController _badgeController =
      Get.find<NotificationBadgeController>();

  List<Map<String, dynamic>> notifications = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    // Pour l'instant, on simule les notifications
    // TODO: Charger depuis l'API quand disponible
    setState(() {
      notifications = [
        {
          'id': 1,
          'title': '✅ Paiement confirmé',
          'body':
              'Votre paiement pour la commande #ORD-693F4EB258383 a été validé.',
          'type': 'payment_confirmed',
          'order_id': 26,
          'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
          'read': false,
        },
        {
          'id': 2,
          'title': '🎉 Commande créée',
          'body':
              'Votre commande #ORD-693F4EB258383 a été créée. Total: 9 500 FCFA',
          'type': 'order_created',
          'order_id': 26,
          'timestamp': DateTime.now().subtract(const Duration(minutes: 10)),
          'read': false,
        },
        {
          'id': 3,
          'title': '📦 Mise à jour de commande',
          'body': 'Votre commande #ORD-693F254B4262B est Confirmée',
          'type': 'order_status_update',
          'order_id': 25,
          'status': 'confirmed',
          'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
          'read': true,
        },
      ];
    });
  }

  void _markAsRead(int index) {
    if (!notifications[index]['read']) {
      setState(() {
        notifications[index]['read'] = true;
      });
      _badgeController.decrementUnread();
    }
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in notifications) {
        notification['read'] = true;
      }
    });
    _badgeController.resetUnread();
    Get.snackbar(
      'Succès',
      'Toutes les notifications marquées comme lues',
      colorText: Colors.white,
      backgroundColor: AppColors.success,
    );
  }

  void _openNotification(Map<String, dynamic> notification) {
    _markAsRead(notifications.indexOf(notification));

    // Naviguer selon le type
    final type = notification['type'];
    final orderId = notification['order_id'];

    if (type == 'payment_confirmed' ||
        type == 'order_created' ||
        type == 'order_status_update') {
      Get.toNamed('/order-detail', arguments: orderId);
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'payment_confirmed':
        return Icons.check_circle;
      case 'order_created':
        return Icons.shopping_bag;
      case 'order_status_update':
        return Icons.local_shipping;
      case 'complaint_response':
        return Icons.chat;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'payment_confirmed':
        return Colors.green;
      case 'order_created':
        return AppColors.primary;
      case 'order_status_update':
        return Colors.blue;
      case 'complaint_response':
        return Colors.orange;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notifications.any((n) => !n['read']))
            IconButton(
              icon: const Icon(Icons.mark_email_read),
              onPressed: _markAllAsRead,
              tooltip: 'Marquer tout comme lu',
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
          ? EmptyStateWidget(
              icon: Icons.notifications_none_outlined,
              title: 'Aucune notification',
              message: 'Vous n\'avez pas de notifications pour le moment',
            )
          : RefreshIndicator(
              onRefresh: _loadNotifications,
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: notifications.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  final isRead = notification['read'] ?? true;

                  return GestureDetector(
                    onTap: () => _openNotification(notification),
                    child: Container(
                      color: isRead
                          ? Colors.transparent
                          : AppColors.primary.withOpacity(0.05),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: _getColorForType(
                              notification['type'],
                            ).withOpacity(0.2),
                            child: Icon(
                              _getIconForType(notification['type']),
                              color: _getColorForType(notification['type']),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notification['title'] ?? '',
                                  style: TextStyle(
                                    fontWeight: isRead
                                        ? FontWeight.normal
                                        : FontWeight.bold,
                                    fontSize: 14,
                                    color: isRead
                                        ? Colors.grey[600]
                                        : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  notification['body'] ?? '',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isRead
                                        ? Colors.grey[500]
                                        : Colors.grey[700],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  DateFormatter.formatRelativeTime(
                                    notification['timestamp'],
                                  ),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isRead)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
