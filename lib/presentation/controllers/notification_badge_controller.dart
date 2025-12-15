import 'package:get/get.dart';

class NotificationBadgeController extends GetxController {
  // Observable state for unread notifications count
  final RxInt unreadCount = 0.obs;

  // Increment unread count
  void incrementUnread() {
    unreadCount.value++;
  }

  // Decrement unread count
  void decrementUnread() {
    if (unreadCount.value > 0) {
      unreadCount.value--;
    }
  }

  // Reset unread count
  void resetUnread() {
    unreadCount.value = 0;
  }

  // Set unread count
  void setUnreadCount(int count) {
    unreadCount.value = count;
  }

  // Check if there are unread notifications
  bool get hasUnread => unreadCount.value > 0;
}
