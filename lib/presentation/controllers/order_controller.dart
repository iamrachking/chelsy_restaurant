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

  ///  createOrder
  Future<Map<String, dynamic>> createOrder({
    required String type,
    int? addressId,
    required String paymentMethod,
    String? mobileMoneyProvider,
    String? mobileMoneyNumber,
    String? promoCode,
    String? scheduledAt,
    String? specialInstructions,
  }) async {
    try {
      isLoading.value = true;

      //  Log les paramètres reçus
      AppLogger.debug('=== CREATING ORDER ===');
      AppLogger.debug('Type: $type');
      AppLogger.debug('Payment Method: $paymentMethod');
      AppLogger.debug('Address ID: $addressId');
      AppLogger.debug('Promo Code: $promoCode');
      AppLogger.debug('Mobile Money Provider: $mobileMoneyProvider');
      AppLogger.debug('Mobile Money Number: $mobileMoneyNumber');

      //  Nettoyer le promo code
      final cleanPromoCode = promoCode != null && promoCode.trim().isNotEmpty
          ? promoCode.trim()
          : null;

      AppLogger.debug(
        'Cleaned Promo Code: $cleanPromoCode (was: "$promoCode")',
      );

      //  Appeler le repository
      AppLogger.debug('Calling OrderRepository.createOrder...');
      final result = await _orderRepository.createOrder(
        type: type,
        addressId: addressId,
        paymentMethod: paymentMethod,
        mobileMoneyProvider: mobileMoneyProvider,
        mobileMoneyNumber: mobileMoneyNumber,
        promoCode: cleanPromoCode,
        scheduledAt: scheduledAt,
        specialInstructions: specialInstructions,
      );

      //  Log la réponse complète
      AppLogger.debug('Order creation result received');
      AppLogger.debug('Success: ${result['success']}');
      AppLogger.debug('Message: ${result['message']}');

      if (result['success'] == true) {
        //  Extraire la commande
        final order = result['order'] as OrderModel?;

        if (order == null) {
          AppLogger.error(
            'OrderController.createOrder',
            'Order is null despite success=true',
          );
          AppLogger.debug('Result keys: ${result.keys.toList()}');
          AppLogger.debug('Full result: $result');

          Get.snackbar(
            'Erreur',
            'Erreur lors de la création de la commande (order null)',
            duration: const Duration(seconds: 3),
          );

          return {
            'success': false,
            'message': 'Commande null dans la réponse',
            'result': result,
          };
        }

        //  Log la commande créée
        AppLogger.debug('Order created successfully!');
        AppLogger.debug('Order ID: ${order.id}');
        AppLogger.debug('Order Number: ${order.orderNumber}');
        AppLogger.debug('Order Status: ${order.status}');
        AppLogger.debug('Order Total: ${order.total}');
        AppLogger.debug('Order Items Count: ${order.items.length}');

        //  Extraire le paiement
        final payment = result['payment'] as Map<String, dynamic>?;
        AppLogger.debug('Payment data: $payment');

        //  Stocker les données
        paymentData.value = payment ?? {};
        AppLogger.debug('Payment data stored in controller');

        //  Rafraîchir la liste
        AppLogger.debug('Refreshing orders list...');
        await loadOrders(refresh: true);

        AppLogger.debug('Order created successfully: ${order.orderNumber}');
        AppLogger.debug('=== ORDER CREATION COMPLETE ===');

        return {'success': true, 'order': order, 'payment': payment};
      } else {
        //  Gérer l'erreur du serveur
        AppLogger.error(
          'OrderController.createOrder',
          'Server returned success=false',
        );

        final message = result['message'] ?? 'Erreur inconnue';
        final errors = result['errors'] as Map<String, dynamic>?;
        final error = result['error'];

        AppLogger.debug('Error message: $message');
        AppLogger.debug('Errors object: $errors');
        AppLogger.debug('Error field: $error');
        AppLogger.debug('Full result: $result');

        //  Afficher l'erreur à l'utilisateur
        if (errors != null && errors.isNotEmpty) {
          // Construire un message avec les erreurs de validation
          final errorLines = <String>[];
          errors.forEach((key, value) {
            if (value is List) {
              errorLines.add('$key: ${value.join(", ")}');
            } else {
              errorLines.add('$key: $value');
            }
          });
          final errorMessage = errorLines.join('\n');

          AppLogger.debug('Showing validation errors: $errorMessage');

          Get.snackbar(
            'Erreur de validation',
            errorMessage,
            duration: const Duration(seconds: 4),
            maxWidth: 300,
          );
        } else {
          AppLogger.debug('Showing general error: $message');

          Get.snackbar('Erreur', message, duration: const Duration(seconds: 3));
        }

        AppLogger.debug('=== ORDER CREATION FAILED ===');

        return {
          'success': false,
          'message': message,
          'error': error,
          'errors': errors,
          'fullResult': result,
        };
      }
    } catch (e, stackTrace) {
      //  Gérer les exceptions
      AppLogger.error('OrderController.createOrder - EXCEPTION', e);
      AppLogger.debug('Exception message: ${e.toString()}');
      AppLogger.debug('Stack trace: $stackTrace');

      Get.snackbar(
        'Erreur critique',
        'Une erreur est survenue: ${e.toString()}',
        duration: const Duration(seconds: 4),
      );

      AppLogger.debug('=== ORDER CREATION CRASHED ===');

      return {
        'success': false,
        'message': e.toString(),
        'exception': e.toString(),
        'stackTrace': stackTrace.toString(),
      };
    } finally {
      isLoading.value = false;
      AppLogger.debug('isLoading set to false');
    }
  }

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
    int maxAttempts = 120,
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
            await getOrder(orderId);
            Get.snackbar('Succès', 'Paiement confirmé avec succès');
            return true;
          } else if (status == 'declined') {
            Get.snackbar('Erreur', 'Paiement refusé par le fournisseur');
            return false;
          } else if (status == 'canceled') {
            Get.snackbar('Annulé', 'Paiement annulé par l\'utilisateur');
            return false;
          }
        }

        attempts++;
        if (attempts < maxAttempts) {
          await Future.delayed(Duration(seconds: intervalSeconds));
        }
      }

      Get.snackbar('Délai dépassé', 'Vérifiez votre transaction Mobile Money');
      return false;
    } catch (e) {
      AppLogger.error('OrderController.pollMobileMoneyPaymentStatus', e);
      Get.snackbar('Erreur', 'Une erreur est survenue');
      return false;
    }
  }

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

  /// Télécharger la facture d'une commande
  Future<bool> downloadOrderInvoice(int orderId) async {
    try {
      isDownloadingInvoice.value = true;
      downloadProgress.value = 'Récupération de la facture...';

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
