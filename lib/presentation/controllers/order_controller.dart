import 'dart:io';
import 'package:chelsy_restaurant/core/services/invoice_service.dart';
import 'package:chelsy_restaurant/data/repositories/order_repository.dart';
import 'package:get/get.dart';
import 'package:chelsy_restaurant/data/models/order_model.dart';
import 'package:chelsy_restaurant/core/utils/app_logger.dart';

class OrderController extends GetxController {
  final OrderRepository _orderRepository = Get.find<OrderRepository>();

  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final Rx<OrderModel?> selectedOrder = Rx<OrderModel?>(null);
  final RxBool isLoading = false.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasMore = true.obs;
  final RxString downloadProgress = ''.obs;
  final RxBool isDownloadingInvoice = false.obs;

  // Paiements
  final RxMap<String, dynamic> paymentData = RxMap<String, dynamic>();
  final RxBool isPaymentProcessing = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  /// ==================== GESTION DES COMMANDES ====================

  /// Charger la liste des commandes
  Future<void> loadOrders({bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage.value = 1;
        orders.clear();
        hasMore.value = true;
      }

      if (!hasMore.value) return;

      isLoading.value = true;
      final result = await _orderRepository.getOrders(page: currentPage.value);

      if (result['success'] == true) {
        final newOrders = (result['orders'] ?? []) as List<OrderModel>;

        if (refresh) {
          orders.value = newOrders;
        } else {
          orders.addAll(newOrders);
        }

        final pagination = result['pagination'] as Map<String, dynamic>?;
        if (pagination != null) {
          final currentPageNum = pagination['current_page'] as int;
          final lastPage = pagination['last_page'] as int;
          hasMore.value = currentPageNum < lastPage;
          if (hasMore.value) {
            currentPage.value = currentPageNum + 1;
          }
        } else {
          hasMore.value = false;
        }
      }
    } catch (e) {
      AppLogger.error('OrderController.loadOrders', e);
      Get.snackbar('Erreur', 'Impossible de charger les commandes');
    } finally {
      isLoading.value = false;
    }
  }

  /// Charger une commande spécifique
  Future<void> getOrder(int id) async {
    try {
      isLoading.value = true;
      final order = await _orderRepository.getOrder(id);
      selectedOrder.value = order;
    } catch (e) {
      AppLogger.error('OrderController.getOrder', e);
      Get.snackbar('Erreur', 'Impossible de charger la commande');
    } finally {
      isLoading.value = false;
    }
  }

  /// ==================== CRÉATION DE COMMANDE ====================

  /// Créer une commande avec paiement
  Future<Map<String, dynamic>> createOrder({
    required String type, // 'delivery' ou 'pickup'
    int? addressId,
    required String paymentMethod, // 'card', 'cash', 'mobile_money'
    String? mobileMoneyProvider, // 'MTN' ou 'Moov'
    String? mobileMoneyNumber,
    String? promoCode,
    String? scheduledAt,
    String? specialInstructions,
  }) async {
    try {
      isLoading.value = true;

      AppLogger.debug(
        'Creating order: type=$type, payment=$paymentMethod, addressId=$addressId',
      );

      final result = await _orderRepository.createOrder(
        type: type,
        addressId: addressId,
        paymentMethod: paymentMethod,
        mobileMoneyProvider: mobileMoneyProvider,
        mobileMoneyNumber: mobileMoneyNumber,
        promoCode: promoCode,
        scheduledAt: scheduledAt,
        specialInstructions: specialInstructions,
      );

      if (result['success'] == true) {
        final order = result['order'] as OrderModel;
        final payment = result['payment'] as Map<String, dynamic>?;

        paymentData.value = payment ?? {};

        // Rafraîchir la liste des commandes
        await loadOrders(refresh: true);

        AppLogger.debug('Order created successfully: ${order.orderNumber}');

        return {'success': true, 'order': order, 'payment': payment};
      } else {
        Get.snackbar(
          'Erreur',
          result['message'] ?? 'Erreur lors de la création',
        );

        return {
          'success': false,
          'message': result['message'],
          'error': result['error'],
        };
      }
    } catch (e, stack) {
      AppLogger.error('OrderController.createOrder', e);
      AppLogger.debug('Stack: $stack');

      Get.snackbar('Erreur', 'Une erreur est survenue');

      return {'success': false, 'message': e.toString()};
    } finally {
      isLoading.value = false;
    }
  }

  /// Annuler une commande
  Future<bool> cancelOrder(int id, {String? reason}) async {
    try {
      isLoading.value = true;

      final result = await _orderRepository.cancelOrder(
        id,
        reason: reason ?? 'Annulation par le client',
      );

      if (result['success'] == true) {
        await loadOrders(refresh: true);
        Get.snackbar('Succès', 'Commande annulée');
        return true;
      } else {
        Get.snackbar(
          'Erreur',
          result['message'] ?? 'Erreur lors de l\'annulation',
        );
        return false;
      }
    } catch (e) {
      AppLogger.error('OrderController.cancelOrder', e);
      Get.snackbar('Erreur', 'Une erreur est survenue');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Recommander une commande
  Future<void> reorder(int orderId) async {
    try {
      isLoading.value = true;

      final success = await _orderRepository.reorder(orderId);

      if (success) {
        Get.snackbar('Succès', 'Articles ajoutés au panier');
      } else {
        Get.snackbar('Erreur', 'Erreur lors de la recommande');
      }
    } catch (e) {
      AppLogger.error('OrderController.reorder', e);
      Get.snackbar('Erreur', 'Une erreur est survenue');
    } finally {
      isLoading.value = false;
    }
  }

  /// ==================== PAIEMENTS STRIPE ====================

  /// Confirmer un paiement Stripe
  Future<bool> confirmStripePayment({
    required int orderId,
    required String paymentIntentId,
  }) async {
    try {
      isPaymentProcessing.value = true;

      AppLogger.debug(
        'Confirming Stripe payment: orderId=$orderId, intentId=$paymentIntentId',
      );

      final result = await _orderRepository.confirmStripePayment(
        orderId: orderId,
        paymentIntentId: paymentIntentId,
      );

      if (result['success'] == true) {
        // Rafraîchir la commande
        await getOrder(orderId);

        Get.snackbar('Succès', 'Paiement confirmé avec succès');
        return true;
      } else {
        Get.snackbar(
          'Erreur',
          result['message'] ?? 'Erreur lors de la confirmation',
        );
        return false;
      }
    } catch (e) {
      AppLogger.error('OrderController.confirmStripePayment', e);
      Get.snackbar('Erreur', 'Une erreur est survenue');
      return false;
    } finally {
      isPaymentProcessing.value = false;
    }
  }

  /// ==================== PAIEMENTS MOBILE MONEY ====================

  /// Créer un paiement Mobile Money
  Future<Map<String, dynamic>> createMobileMoneyPayment({
    required int orderId,
    required String provider,
    required String phoneNumber,
  }) async {
    try {
      isPaymentProcessing.value = true;

      AppLogger.debug(
        'Creating Mobile Money payment: orderId=$orderId, provider=$provider',
      );

      final result = await _orderRepository.createMobileMoneyPayment(
        orderId: orderId,
        provider: provider,
        phoneNumber: phoneNumber,
      );

      if (result['success'] == true) {
        paymentData.value = result;
        return result;
      } else {
        Get.snackbar(
          'Erreur',
          result['message'] ?? 'Erreur lors de la création du paiement',
        );
        return result;
      }
    } catch (e) {
      AppLogger.error('OrderController.createMobileMoneyPayment', e);
      Get.snackbar('Erreur', 'Une erreur est survenue');
      return {'success': false, 'message': e.toString()};
    } finally {
      isPaymentProcessing.value = false;
    }
  }

  /// Vérifier le statut d'un paiement Mobile Money
  Future<Map<String, dynamic>> checkMobileMoneyStatus(int orderId) async {
    try {
      final result = await _orderRepository.checkMobileMoneyStatus(orderId);

      if (result['success'] == true) {
        return result;
      } else {
        return result;
      }
    } catch (e) {
      AppLogger.error('OrderController.checkMobileMoneyStatus', e);
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Poll le statut Mobile Money jusqu'à confirmation
  Future<bool> pollMobileMoneyPaymentStatus({
    required int orderId,
    int maxAttempts = 120, // 10 minutes max
    int intervalSeconds = 5,
  }) async {
    try {
      int attempts = 0;

      while (attempts < maxAttempts) {
        final result = await checkMobileMoneyStatus(orderId);

        if (result['success'] == true) {
          final status = result['status'] as String;

          AppLogger.debug(
            'Mobile Money status check (attempt $attempts): $status',
          );

          if (status == 'approved') {
            // Paiement réussi
            await getOrder(orderId);
            Get.snackbar('Succès', 'Paiement confirmé avec succès');
            return true;
          } else if (status == 'declined') {
            // Paiement refusé
            Get.snackbar('Erreur', 'Paiement refusé par le fournisseur');
            return false;
          } else if (status == 'canceled') {
            // Paiement annulé
            Get.snackbar('Annulé', 'Paiement annulé par l\'utilisateur');
            return false;
          }
        }

        // Attendre avant la prochaine vérification pour eviter des conflit ouais
        attempts++;
        if (attempts < maxAttempts) {
          await Future.delayed(Duration(seconds: intervalSeconds));
        }
      }

      // Timeout
      Get.snackbar('Délai dépassé', 'Vérifiez votre transaction Mobile Money');
      return false;
    } catch (e) {
      AppLogger.error('OrderController.pollMobileMoneyPaymentStatus', e);
      Get.snackbar('Erreur', 'Une erreur est survenue');
      return false;
    }
  }

  /// ==================== FACTURES ====================

  /// Obtenir la facture en base64
  Future<Map<String, dynamic>?> getInvoice(int orderId) async {
    try {
      return await _orderRepository.getInvoice(orderId);
    } catch (e) {
      AppLogger.error('OrderController.getInvoice', e);
      Get.snackbar('Erreur', 'Impossible de charger la facture');
      return null;
    }
  }
  // Ajouter ces propriétés dans OrderController (dans la classe)

  // ==================== TÉLÉCHARGEMENT DE FACTURES ====================

  /// Télécharger la facture d'une commande
  Future<bool> downloadOrderInvoice(int orderId) async {
    try {
      isDownloadingInvoice.value = true;
      downloadProgress.value = 'Récupération de la facture...';

      // Récupérer la facture depuis le backend
      final invoiceData = await _orderRepository.downloadInvoice(orderId);

      if (invoiceData == null) {
        Get.snackbar('Erreur', 'Impossible de récupérer la facture');
        return false;
      }

      if (invoiceData['success'] != true) {
        Get.snackbar(
          'Erreur',
          invoiceData['message'] ?? 'Erreur lors du téléchargement',
        );
        return false;
      }

      downloadProgress.value = 'Sauvegarde du fichier...';

      final base64String = invoiceData['invoice_base64'] as String?;
      final filename = invoiceData['filename'] as String?;

      if (base64String == null || base64String.isEmpty) {
        Get.snackbar('Erreur', 'Données de facture invalides');
        return false;
      }

      if (filename == null || filename.isEmpty) {
        Get.snackbar('Erreur', 'Nom de fichier invalide');
        return false;
      }

      // Télécharger et sauvegarder le fichier
      final filePath = await InvoiceService.downloadInvoice(
        invoiceBase64: base64String,
        filename: filename,
      );

      if (filePath == null) {
        Get.snackbar('Erreur', 'Erreur lors de la sauvegarde du fichier');
        return false;
      }

      downloadProgress.value = '';
      Get.snackbar(
        'Succès',
        'Facture téléchargée avec succès',
        duration: const Duration(seconds: 2),
      );

      AppLogger.debug('Invoice downloaded to: $filePath');
      return true;
    } catch (e) {
      AppLogger.error('OrderController.downloadOrderInvoice', e);
      Get.snackbar('Erreur', 'Une erreur est survenue: ${e.toString()}');
      return false;
    } finally {
      isDownloadingInvoice.value = false;
      downloadProgress.value = '';
    }
  }

  /// Ouvrir la facture dans le lecteur PDF
  Future<void> openOrderInvoice(int orderId) async {
    try {
      isDownloadingInvoice.value = true;
      downloadProgress.value = 'Préparation du fichier...';

      // D'abord, télécharger la facture
      final invoiceData = await _orderRepository.downloadInvoice(orderId);

      if (invoiceData == null || invoiceData['success'] != true) {
        Get.snackbar(
          'Erreur',
          invoiceData?['message'] ?? 'Impossible de récupérer la facture',
        );
        return;
      }

      final base64String = invoiceData['invoice_base64'] as String?;
      final filename = invoiceData['filename'] as String?;

      if (base64String == null || filename == null) {
        Get.snackbar('Erreur', 'Données de facture invalides');
        return;
      }

      final filePath = await InvoiceService.downloadInvoice(
        invoiceBase64: base64String,
        filename: filename,
      );

      if (filePath == null) {
        Get.snackbar('Erreur', 'Impossible de sauvegarder la facture');
        return;
      }

      downloadProgress.value = 'Ouverture du fichier...';

      // Ouvrir le fichier
      final opened = await InvoiceService.openInvoice(filePath);

      if (!opened) {
        Get.snackbar('Erreur', 'Impossible d\'ouvrir la facture');
      }
    } catch (e) {
      AppLogger.error('OrderController.openOrderInvoice', e);
      Get.snackbar('Erreur', 'Une erreur est survenue: ${e.toString()}');
    } finally {
      isDownloadingInvoice.value = false;
      downloadProgress.value = '';
    }
  }

  /// Partager la facture
  Future<void> shareOrderInvoice(int orderId) async {
    try {
      isDownloadingInvoice.value = true;
      downloadProgress.value = 'Préparation du partage...';

      // D'abord, télécharger la facture
      final invoiceData = await _orderRepository.downloadInvoice(orderId);

      if (invoiceData == null || invoiceData['success'] != true) {
        Get.snackbar(
          'Erreur',
          invoiceData?['message'] ?? 'Impossible de récupérer la facture',
        );
        return;
      }

      final base64String = invoiceData['invoice_base64'] as String?;
      final filename = invoiceData['filename'] as String?;

      if (base64String == null || filename == null) {
        Get.snackbar('Erreur', 'Données de facture invalides');
        return;
      }

      final filePath = await InvoiceService.downloadInvoice(
        invoiceBase64: base64String,
        filename: filename,
      );

      if (filePath == null) {
        Get.snackbar('Erreur', 'Impossible de sauvegarder la facture');
        return;
      }

      downloadProgress.value = 'Partage en cours...';

      // Partager le fichier
      final shared = await InvoiceService.shareInvoice(filePath);

      if (!shared) {
        AppLogger.debug('Share was dismissed by user');
      }
    } catch (e) {
      AppLogger.error('OrderController.shareOrderInvoice', e);
      Get.snackbar('Erreur', 'Une erreur est survenue: ${e.toString()}');
    } finally {
      isDownloadingInvoice.value = false;
      downloadProgress.value = '';
    }
  }

  /// Lister les factures téléchargées
  Future<List<File>> getDownloadedInvoices() async {
    try {
      return await InvoiceService.getDownloadedInvoices();
    } catch (e) {
      AppLogger.error('OrderController.getDownloadedInvoices', e);
      return [];
    }
  }
}
