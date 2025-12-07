class AppConstants {
  // API Configuration
  static const String baseUrl =
      'https://chelsy-api.cabinet-xaviertermeau.com/api/v1';
  static const String apiVersion = 'v1';
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // cle pour le storage
  static const String keyToken = 'auth_token';
  static const String keyUser = 'user_data';
  static const String keyFcmToken = 'fcm_token';
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyLanguage = 'language';
  static const String keyTheme = 'theme';
  static const String keyHasSeenOnboarding = 'has_seen_onboarding';

  // Pagination
  static const int defaultPageSize = 15;
  static const int maxPageSize = 50;

  // devises
  static const String currency = 'FCFA';
  static const String currencySymbol = 'FCFA';

  //  Formats des dates
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String displayDateFormat = 'dd/MM/yyyy';
  static const String displayDateTimeFormat = 'dd/MM/yyyy HH:mm';

  //  Status de commande
  static const String orderStatusPending = 'pending';
  static const String orderStatusConfirmed = 'confirmed';
  static const String orderStatusPreparing = 'preparing';
  static const String orderStatusReady = 'ready';
  static const String orderStatusOutForDelivery = 'out_for_delivery';
  static const String orderStatusDelivered = 'delivered';
  static const String orderStatusPickedUp = 'picked_up';
  static const String orderStatusCancelled = 'cancelled';

  //  Methodes de payement
  static const String paymentMethodCard = 'card';
  static const String paymentMethodCash = 'cash';
  static const String paymentMethodMobileMoney = 'mobile_money';

  // Mobile Money Providers
  static const String mobileMoneyMtn = 'MTN';
  static const String mobileMoneyMoov = 'Moov';

  // Types de commande
  static const String orderTypeDelivery = 'delivery';
  static const String orderTypePickup = 'pickup';

  // Delivery Position Update Interval (milliseconds)
  static const int deliveryPositionUpdateInterval = 30000;

  // Order Tracking Update Interval (milliseconds)
  static const int orderTrackingUpdateInterval = 5000;
}
