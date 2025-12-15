import 'package:get/get.dart';
import 'package:chelsy_restaurant/data/repositories/address_repository.dart';
import 'package:chelsy_restaurant/data/models/address_model.dart';
import 'package:chelsy_restaurant/core/utils/app_logger.dart';

class AddressController extends GetxController {
  final AddressRepository _addressRepository = Get.find<AddressRepository>();

  final RxList<AddressModel> addresses = <AddressModel>[].obs;
  final Rx<AddressModel?> selectedAddress = Rx<AddressModel?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAddresses();
  }

  // Load addresses
  Future<void> loadAddresses() async {
    try {
      isLoading.value = true;
      final addressesList = await _addressRepository.getAddresses();
      addresses.value = addressesList;

      // Set default address as selected
      final defaultAddress = addressesList.firstWhereOrNull((a) => a.isDefault);
      if (defaultAddress != null) {
        selectedAddress.value = defaultAddress;
      } else if (addressesList.isNotEmpty) {
        selectedAddress.value = addressesList.first;
      }
    } catch (e) {
      AppLogger.error('Load addresses error', e);
    } finally {
      isLoading.value = false;
    }
  }

  // Create address
  Future<bool> createAddress(AddressModel address) async {
    try {
      isLoading.value = true;

      final result = await _addressRepository.createAddress(address);
      if (result['success'] == true) {
        return true;
      } else {
        Get.snackbar(
          'Erreur',
          result['message'] ?? 'Erreur lors de la creation',
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }
    } catch (e) {
      AppLogger.error('Create address error', e);
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue',
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Update address
  Future<bool> updateAddress(int id, AddressModel address) async {
    try {
      isLoading.value = true;

      final result = await _addressRepository.updateAddress(id, address);

      if (result['success'] == true) {
        return true;
      } else {
        Get.snackbar(
          'Erreur',
          result['message'] ?? 'Erreur lors de la modification',
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }
    } catch (e) {
      AppLogger.error('Update address error', e);
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue',
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Delete address
  Future<bool> deleteAddress(int id) async {
    try {
      isLoading.value = true;
      final success = await _addressRepository.deleteAddress(id);
      if (success) {
        await loadAddresses();
        Get.snackbar(
          'Succès',
          'Adresse supprimée avec succès',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
        return true;
      } else {
        Get.snackbar(
          'Erreur',
          'Erreur lors de la suppression de l\'adresse',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
        return false;
      }
    } catch (e) {
      AppLogger.error('Delete address error', e);
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue lors de la suppression de l\'adresse',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Set default address
  Future<bool> setDefaultAddress(int id) async {
    try {
      isLoading.value = true;
      final result = await _addressRepository.setDefaultAddress(id);
      if (result['success'] == true) {
        // Recharger immédiatement la liste pour voir la mise à jour
        await loadAddresses();
        Get.snackbar(
          'Succès',
          'Adresse définie par défaut avec succès',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
        return true;
      } else {
        Get.snackbar(
          'Erreur',
          result['message'] ??
              'Erreur lors de la définition de l\'adresse par défaut',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
        return false;
      }
    } catch (e) {
      AppLogger.error('Set default address error', e);
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue lors de la définition de l\'adresse par défaut',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Select address
  void selectAddress(AddressModel address) {
    selectedAddress.value = address;
  }
}
