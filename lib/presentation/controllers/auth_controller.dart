import 'package:chelsy_restaurant/core/services/notification_service.dart';
import 'package:get/get.dart';
import 'package:chelsy_restaurant/data/repositories/auth_repository.dart';
import 'package:chelsy_restaurant/data/models/user_model.dart';
import 'package:chelsy_restaurant/core/services/storage_service.dart';
import 'package:chelsy_restaurant/core/utils/app_logger.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final StorageService _storageService = Get.find<StorageService>();

  // Observable state
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  // Check if user is logged in
  Future<void> checkAuthStatus() async {
    isLoggedIn.value = _storageService.isLoggedIn();
    if (isLoggedIn.value) {
      final userData = _storageService.getUser();
      if (userData != null) {
        currentUser.value = UserModel.fromJson(userData);
      }
      // Refresh user data from API
      await getCurrentUser();
    }
  }

  // Register
  Future<bool> register({
    required String firstname,
    required String lastname,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
  }) async {
    try {
      isLoading.value = true;
      final result = await _authRepository.register(
        firstname: firstname,
        lastname: lastname,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        phone: phone,
      );

      if (result['success'] == true) {
        currentUser.value = result['user'] as UserModel;
        isLoggedIn.value = true;
        // Register FCM token
        final notificationService = Get.find<NotificationService>();
        await notificationService.getFCMToken();
        AppLogger.info('Registration successful');
        return true;
      } else {
        Get.snackbar(
          'Erreur',
          result['message'] ?? 'Erreur lors de l\'inscription',
        );
        return false;
      }
    } catch (e) {
      AppLogger.error('Register error', e);
      Get.snackbar('Erreur', 'Une erreur est survenue');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Login
  Future<bool> login({required String email, required String password}) async {
    try {
      isLoading.value = true;
      final result = await _authRepository.login(
        email: email,
        password: password,
      );

      if (result['success'] == true) {
        currentUser.value = result['user'] as UserModel;
        isLoggedIn.value = true;
        // Register FCM token
        final notificationService = Get.find<NotificationService>();
        await notificationService.getFCMToken();
        AppLogger.info('Login successful');
        return true;
      } else {
        Get.snackbar(
          'Erreur',
          result['message'] ?? 'Email ou mot de passe incorrect',
        );
        return false;
      }
    } catch (e) {
      AppLogger.error('Login error', e);
      Get.snackbar('Erreur', 'Une erreur est survenue');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      isLoading.value = true;
      // Unregister FCM token
      final notificationService = Get.find<NotificationService>();
      await notificationService.unregisterToken();
      await _authRepository.logout();
      currentUser.value = null;
      isLoggedIn.value = false;
      AppLogger.info('Logout successful');
    } catch (e) {
      AppLogger.error('Logout error', e);
    } finally {
      isLoading.value = false;
    }
  }

  // Get current user
  Future<void> getCurrentUser() async {
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        currentUser.value = user;
      }
    } catch (e) {
      AppLogger.error('Get current user error', e);
    }
  }

  // Forgot password
  Future<bool> forgotPassword(String email) async {
    try {
      isLoading.value = true;
      final result = await _authRepository.forgotPassword(email);
      if (result['success'] == true) {
        Get.snackbar('Succès', result['message'] ?? 'Email envoyé');
        return true;
      } else {
        Get.snackbar('Erreur', result['message'] ?? 'Erreur lors de l\'envoi');
        return false;
      }
    } catch (e) {
      AppLogger.error('Forgot password error', e);
      Get.snackbar('Erreur', 'Une erreur est survenue');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Reset password
  Future<bool> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      isLoading.value = true;
      final result = await _authRepository.resetPassword(
        email: email,
        token: token,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      if (result['success'] == true) {
        Get.snackbar(
          'Succès',
          result['message'] ?? 'Mot de passe réinitialisé',
        );
        return true;
      } else {
        Get.snackbar(
          'Erreur',
          result['message'] ?? 'Erreur lors de la réinitialisation',
        );
        return false;
      }
    } catch (e) {
      AppLogger.error('Reset password error', e);
      Get.snackbar('Erreur', 'Une erreur est survenue');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
