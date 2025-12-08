import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:chelsy_restaurant/core/utils/app_logger.dart';

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Note: This function must be top-level and cannot use GetX services directly
  AppLogger.info('Background message: ${message.messageId}');

  // Handle notification data
  final data = message.data;
  final type = data['type'] as String?;

  switch (type) {
    case 'order_status_update':
      print('Order status update: ${data['order_id']} -> ${data['status']}');
      break;
    case 'payment_confirmation':
      print('Payment confirmed for order: ${data['order_id']}');
      break;
    case 'complaint_response':
      print('Complaint response: ${data['complaint_id']}');
      break;
    default:
      print('Unknown notification type: $type');
  }
}
