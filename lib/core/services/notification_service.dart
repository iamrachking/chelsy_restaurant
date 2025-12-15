import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:chelsy_restaurant/core/utils/app_logger.dart';
import 'package:chelsy_restaurant/core/services/api_service.dart';
import 'package:chelsy_restaurant/core/services/storage_service.dart';
import 'package:chelsy_restaurant/presentation/controllers/notification_badge_controller.dart';

class NotificationService extends GetxService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();

  @override
  void onInit() {
    super.onInit();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    // Request permissions
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      AppLogger.info('User granted notification permission');
    } else {
      AppLogger.warning('User declined notification permission');
    }

    // Initialize local notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // Get initial message (when app opened from notification)
    RemoteMessage? initialMessage = await _firebaseMessaging
        .getInitialMessage();
    if (initialMessage != null) {
      _handleBackgroundMessage(initialMessage);
    }

    // Get FCM token
    await getFCMToken();
  }

  Future<void> getFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        AppLogger.info('FCM Token: $token');
        await _storageService.saveFcmToken(token);
        await _registerTokenToServer(token);
      }

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) async {
        AppLogger.info('FCM Token refreshed: $newToken');
        await _storageService.saveFcmToken(newToken);
        await _registerTokenToServer(newToken);
      });
    } catch (e) {
      AppLogger.error('Error getting FCM token', e);
    }
  }

  Future<void> _registerTokenToServer(String token) async {
    try {
      await _apiService.post('/fcm-token', data: {'token': token});
      AppLogger.info('FCM token registered to server');
    } catch (e) {
      AppLogger.error('Error registering FCM token to server', e);
    }
  }

  Future<void> unregisterToken() async {
    try {
      await _apiService.delete('/fcm-token');
      await _storageService.removeFcmToken();
      AppLogger.info('FCM token unregistered');
    } catch (e) {
      AppLogger.error('Error unregistering FCM token', e);
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    AppLogger.info('Foreground message received: ${message.messageId}');

    // Increment notification badge
    if (Get.isRegistered<NotificationBadgeController>()) {
      Get.find<NotificationBadgeController>().incrementUnread();
    }

    _showLocalNotification(message);
    _handleNotificationData(message.data);
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    AppLogger.info('Background message received: ${message.messageId}');
    _handleNotificationData(message.data);
  }

  void _handleNotificationData(Map<String, dynamic> data) {
    final type = data['type'] as String?;

    switch (type) {
      case 'order_status_update':
        final orderId = data['order_id'];
        final status = data['status'];
        AppLogger.info('Order status update: Order $orderId -> $status');
        // Navigate to order detail if needed
        // Get.toNamed(AppRoutes.orderDetail, arguments: orderId);
        break;

      case 'payment_confirmation':
        final orderId = data['order_id'];
        AppLogger.info('Payment confirmed for order: $orderId');
        break;

      case 'complaint_response':
        final complaintId = data['complaint_id'];
        AppLogger.info('Complaint response received: $complaintId');
        break;

      default:
        AppLogger.warning('Unknown notification type: $type');
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'chelsy_restaurant_channel',
          'CHELSY Restaurant Notifications',
          channelDescription:
              'Notifications pour les commandes et mises à jour',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      details,
      payload: message.data.toString(),
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      // Handle notification tap
      AppLogger.info('Notification tapped: ${response.payload}');
    }
  }
}
