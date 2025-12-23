import 'package:chelsy_restaurant/core/bindings/tracking_binding.dart';
import 'package:chelsy_restaurant/data/repositories/review_repository.dart';
import 'package:chelsy_restaurant/presentation/controllers/review_controller.dart';
// import 'package:chelsy_restaurant/core/services/location_service.dart';
import 'package:chelsy_restaurant/presentation/controllers/tracking_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';

import 'package:chelsy_restaurant/core/services/storage_service.dart';
import 'package:chelsy_restaurant/core/services/api_service.dart';
import 'package:chelsy_restaurant/core/services/notification_service.dart';

import 'package:chelsy_restaurant/data/repositories/auth_repository.dart';
import 'package:chelsy_restaurant/data/repositories/profile_repository.dart';

import 'package:chelsy_restaurant/presentation/controllers/auth_controller.dart';

import 'package:chelsy_restaurant/presentation/pages/splash/splash_page.dart';
import 'package:chelsy_restaurant/presentation/pages/initial/initial_page.dart';
import 'package:chelsy_restaurant/presentation/pages/reviews/create_review_page.dart';
import 'package:chelsy_restaurant/presentation/pages/reviews/dish_reviews_page.dart';
import 'package:chelsy_restaurant/presentation/pages/onboarding/onboarding_page.dart';
import 'package:chelsy_restaurant/presentation/pages/auth/auth_page.dart';
import 'package:chelsy_restaurant/presentation/pages/auth/login_page.dart';
import 'package:chelsy_restaurant/presentation/pages/auth/register_page.dart';
import 'package:chelsy_restaurant/presentation/pages/auth/forgot_password_page.dart';
import 'package:chelsy_restaurant/presentation/pages/main/main_page.dart';
import 'package:chelsy_restaurant/presentation/pages/home/home_page.dart';
import 'package:chelsy_restaurant/presentation/pages/home/dish_detail_page.dart';
import 'package:chelsy_restaurant/presentation/pages/home/all_dishes_page.dart';
import 'package:chelsy_restaurant/presentation/pages/home/featured_dishes_page.dart';
import 'package:chelsy_restaurant/presentation/pages/home/popular_dishes_page.dart';
import 'package:chelsy_restaurant/presentation/pages/profile/profile_page.dart';
import 'package:chelsy_restaurant/presentation/pages/profile/edit_profile_page.dart';
import 'package:chelsy_restaurant/presentation/pages/profile/change_password_page.dart';
import 'package:chelsy_restaurant/presentation/pages/favorites/favorites_page.dart';
import 'package:chelsy_restaurant/presentation/pages/notifications/notifications_page.dart';
import 'package:chelsy_restaurant/presentation/pages/addresses/add_address_page.dart';
import 'package:chelsy_restaurant/presentation/pages/addresses/addresses_page.dart';
import 'package:chelsy_restaurant/presentation/pages/checkout/checkout_page.dart';
import 'package:chelsy_restaurant/presentation/pages/checkout/mobile_money_payment_page.dart';
import 'package:chelsy_restaurant/presentation/pages/checkout/stripe_payment_page.dart';
import 'package:chelsy_restaurant/presentation/pages/orders/order_detail_page.dart';
import 'package:chelsy_restaurant/presentation/pages/orders/order_tracking_page.dart';
import 'package:chelsy_restaurant/presentation/pages/orders/orders_page.dart';

import 'package:chelsy_restaurant/core/bindings/home_binding.dart';
import 'package:chelsy_restaurant/core/bindings/profile_binding.dart';
import 'package:chelsy_restaurant/core/bindings/order_binding.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  _initializeStripe();

  // Services
  await Get.putAsync(() => StorageService().init());
  Get.put(ApiService());
  Get.put(NotificationService());
  // Get.put(LocationService());

  // Repositories
  Get.put(AuthRepository());
  Get.put(ProfileRepository());
  Get.put<ReviewRepository>(ReviewRepository());
  Get.put<ReviewController>(ReviewController());
  // Controllers
  Get.put(AuthController());
  Get.lazyPut<TrackingController>(() => TrackingController());

  runApp(const MyApp());
}

// initialisation de Stripe avec la clé publique
void _initializeStripe() {
  try {
    final stripePublishableKey =
        'pk_test_51SXxWCEIbGGIRVuQSHaYq7jTIp8jSikdpD1diwQ143vD9hl2BYgHN240XuyfuXHASsnjyEwniHlYQMpfHfra7zln00VSqzGaXp';
    Stripe.publishableKey = stripePublishableKey;

    Stripe.instance.applySettings();
  } catch (e) {
    print('Stripe initialization error: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'CHELSY Restaurant',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      getPages: [
        // SPLASH & ONBOARDING
        GetPage(name: AppRoutes.splash, page: () => const SplashPage()),
        GetPage(name: AppRoutes.initial, page: () => const InitialPage()),
        GetPage(name: AppRoutes.onboarding, page: () => const OnboardingPage()),

        // AUTHENTIFICATION
        GetPage(name: AppRoutes.auth, page: () => const AuthPage()),
        GetPage(name: AppRoutes.login, page: () => const LoginPage()),
        GetPage(name: AppRoutes.register, page: () => const RegisterPage()),
        GetPage(
          name: AppRoutes.forgotPassword,
          page: () => const ForgotPasswordPage(),
        ),

        // MAIN
        GetPage(
          name: AppRoutes.main,
          page: () => const MainPage(),
          bindings: [HomeBinding(), ProfileBinding()],
        ),

        // HOME
        GetPage(
          name: AppRoutes.home,
          page: () => const HomePage(),
          binding: HomeBinding(),
        ),
        GetPage(name: AppRoutes.dishDetail, page: () => const DishDetailPage()),
        GetPage(name: AppRoutes.allDishes, page: () => const AllDishesPage()),
        GetPage(
          name: AppRoutes.dishesFeatured,
          page: () => const FeaturedDishesPage(),
        ),
        GetPage(
          name: AppRoutes.dishesPopular,
          page: () => const PopularDishesPage(),
        ),

        // PROFILE
        GetPage(
          name: AppRoutes.profile,
          page: () => const ProfilePage(),
          binding: ProfileBinding(),
        ),
        GetPage(
          name: AppRoutes.editProfile,
          page: () => const EditProfilePage(),
          binding: ProfileBinding(),
        ),
        GetPage(
          name: AppRoutes.changePassword,
          page: () => const ChangePasswordPage(),
          binding: ProfileBinding(),
        ),
        GetPage(
          name: AppRoutes.favorites,
          page: () => const FavoritesPage(),
          binding: HomeBinding(),
        ),
        GetPage(
          name: AppRoutes.notifications,
          page: () => const NotificationsPage(),
        ),

        // CHECKOUT & ORDERS
        GetPage(
          name: AppRoutes.checkout,
          page: () => const CheckoutPage(),
          binding: OrderBinding(),
        ),
        GetPage(
          name: AppRoutes.orders,
          page: () => const OrdersPage(),
          binding: OrderBinding(),
        ),
        GetPage(
          name: AppRoutes.orderDetail,
          page: () => const OrderDetailPage(),
          binding: OrderBinding(),
        ),
        GetPage(
          name: AppRoutes.orderTracking,
          page: () {
            final orderId = Get.arguments as int;
            return OrderTrackingPage(orderId: orderId);
          },
          bindings: [OrderBinding(), TrackingBinding()],
        ),

        // ADDRESSES
        GetPage(
          name: AppRoutes.addresses,
          page: () => const AddressesPage(),
          binding: OrderBinding(),
        ),
        GetPage(
          name: AppRoutes.addAddress,
          page: () {
            final address = Get.arguments;
            return AddAddressPage(address: address);
          },
          binding: OrderBinding(),
        ),

        // PAYMENTS
        GetPage(
          name: AppRoutes.stripePayment,
          page: () => const StripePaymentPage(),
          binding: OrderBinding(),
        ),
        GetPage(
          name: AppRoutes.mobileMoneyPayment,
          page: () => const MobileMoneyPaymentPage(),
          binding: OrderBinding(),
        ),
        GetPage(
          name: AppRoutes.createReview,
          page: () {
            final args = Get.arguments as Map<String, dynamic>? ?? {};
            return CreateReviewPage(
              orderId: args['orderId'] as int?,
              dishId: args['dishId'] as int?,
            );
          },
        ),
        GetPage(
          name: AppRoutes.dishReviews,
          page: () {
            final dishId = Get.arguments as int;
            return DishReviewsPage(dishId: dishId);
          },
          binding: HomeBinding(),
        ),
      ],
    );
  }
}
