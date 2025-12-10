import 'dart:io';
import 'package:get/get.dart';
import 'package:chelsy_restaurant/core/utils/app_logger.dart';
import 'package:chelsy_restaurant/data/models/user_model.dart';
import 'package:chelsy_restaurant/data/repositories/profile_repository.dart';
import 'package:chelsy_restaurant/presentation/controllers/auth_controller.dart';

class ProfileController extends GetxController {
  final ProfileRepository _profileRepository = Get.find<ProfileRepository>();

  // STATE
  final Rx<UserModel?> profile = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  // ---------------------------------------------------------------------------
  // Load profile
  // ---------------------------------------------------------------------------
  Future<void> loadProfile() async {
    try {
      isLoading.value = true;
      final data = await _profileRepository.getProfile();
      profile.value = data;
    } catch (e) {
      AppLogger.error("Load profile error", e);
      Get.snackbar("Erreur", "Impossible de charger le profil");
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Update profile info
  // ---------------------------------------------------------------------------
  Future<bool> updateProfile({
    String? firstname,
    String? lastname,
    String? email,
    String? phone,
    String? birthDate,
    String? gender,
  }) async {
    try {
      isLoading.value = true;

      final result = await _profileRepository.updateProfile(
        firstname: firstname,
        lastname: lastname,
        email: email,
        phone: phone,
        birthDate: birthDate,
        gender: gender,
      );

      if (result['success'] == true) {
        final updatedUser = result['user'] as UserModel;

        profile.value = updatedUser;
        Get.find<AuthController>().currentUser.value = updatedUser;
        return true;
      } else {
        Get.snackbar(
          "Erreur",
          result['message'] ?? "Impossible de mettre à jour le profil",
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
        return false;
      }
    } catch (e) {
      AppLogger.error("Update profile error", e);

      Get.snackbar(
        "Erreur",
        "Une erreur est survenue lors de la mise à jour",
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Change password
  // ---------------------------------------------------------------------------
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      isLoading.value = true;
      final result = await _profileRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );

      if (result['success'] == true) {
        Get.snackbar(
          "Succès",
          "Mot de passe modifié avec succès",
          snackPosition: SnackPosition.TOP,
        );
        return true;
      } else {
        Get.snackbar(
          "Erreur",
          result['message'] ?? "Impossible de modifier le mot de passe",
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }
    } catch (e) {
      AppLogger.error("Change password error", e);
      Get.snackbar(
        "Erreur",
        "Une erreur est survenue",
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Update profile picture
  // ---------------------------------------------------------------------------
  Future<bool> updateProfilePicture(String imagePath) async {
    try {
      isLoading.value = true;

      // Check local file
      final file = File(imagePath);
      if (!await file.exists()) {
        Get.snackbar("Erreur", "Le fichier n'existe pas");
        return false;
      }

      if (await file.length() > 5 * 1024 * 1024) {
        Get.snackbar("Erreur", "Image trop lourde (max 5MB)");
        return false;
      }

      final result = await _profileRepository.updateProfilePicture(imagePath);

      if (result['success'] == true) {
        final updatedUser = result['user'] as UserModel;

        profile.value = updatedUser;
        Get.find<AuthController>().currentUser.value = updatedUser;

        Get.snackbar(
          "Succès",
          "Photo de profil mise à jour",
          snackPosition: SnackPosition.TOP,
        );

        return true;
      } else {
        Get.snackbar(
          "Erreur",
          result['message'] ?? "Erreur lors de l’upload",
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }
    } catch (e) {
      AppLogger.error("Update picture error", e);

      Get.snackbar(
        "Erreur",
        "Impossible de mettre à jour la photo",
        snackPosition: SnackPosition.TOP,
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
