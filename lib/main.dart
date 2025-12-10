import 'package:chelsy_restaurant/core/bindings/home_binding.dart';
import 'package:chelsy_restaurant/core/bindings/profile_binding.dart';
import 'package:chelsy_restaurant/core/services/api_service.dart';
import 'package:chelsy_restaurant/core/services/notification_service.dart';
import 'package:chelsy_restaurant/core/services/storage_service.dart';
import 'package:chelsy_restaurant/data/repositories/auth_repository.dart';
import 'package:chelsy_restaurant/data/repositories/profile_repository.dart';
import 'package:chelsy_restaurant/presentation/controllers/auth_controller.dart';
import 'package:chelsy_restaurant/presentation/pages/home/all_dishes_page.dart';
import 'package:chelsy_restaurant/presentation/pages/home/dish_detail_page.dart';
import 'package:chelsy_restaurant/presentation/pages/home/featured_dishes_page.dart';
import 'package:chelsy_restaurant/presentation/pages/home/home_page.dart';
import 'package:chelsy_restaurant/presentation/pages/home/popular_dishes_page.dart';
import 'package:chelsy_restaurant/presentation/pages/onboarding/onboarding_page.dart';
import 'package:chelsy_restaurant/presentation/pages/profile/change_password_page.dart';
import 'package:chelsy_restaurant/presentation/pages/profile/edit_profile_page.dart';
import 'package:chelsy_restaurant/presentation/pages/profile/profile_page.dart';
import 'package:chelsy_restaurant/presentation/pages/splash/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'presentation/pages/auth/auth_page.dart';
import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/auth/register_page.dart';
import 'presentation/pages/auth/forgot_password_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Get.putAsync(() => StorageService().init());
  Get.put(ApiService());
  Get.put(NotificationService());
  Get.put(AuthRepository());
  Get.put(AuthController());
  Get.put(AuthRepository());
  Get.put(ProfileRepository());

  runApp(const MyApp());
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
        GetPage(name: AppRoutes.splash, page: () => const SplashPage()),
        GetPage(name: AppRoutes.onboarding, page: () => const OnboardingPage()),
        GetPage(name: AppRoutes.auth, page: () => const AuthPage()),
        GetPage(name: AppRoutes.login, page: () => const LoginPage()),
        GetPage(name: AppRoutes.register, page: () => const RegisterPage()),
        GetPage(
          name: AppRoutes.forgotPassword,
          page: () => const ForgotPasswordPage(),
        ),
        GetPage(
          name: AppRoutes.home,
          page: () => const HomePage(),
          binding: HomeBinding(),
        ),
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
      ],
    );
  }
}
