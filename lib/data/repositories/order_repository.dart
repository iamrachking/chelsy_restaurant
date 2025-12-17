import 'package:get/get.dart';
import 'package:chelsy_restaurant/core/services/api_service.dart';
import 'package:chelsy_restaurant/core/utils/app_logger.dart';
import 'package:chelsy_restaurant/core/constants/app_constants.dart';
import 'package:chelsy_restaurant/data/models/order_model.dart';

class OrderRepository {
  final ApiService _apiService = Get.find<ApiService>();

  // creation de commande
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
      //  Construire les données avec vérification du promo code
      final data = <String, dynamic>{
        'type': type,
        'payment_method': paymentMethod,
        if (addressId != null) 'address_id': addressId,
        if (mobileMoneyProvider != null)
          'mobile_money_provider': mobileMoneyProvider,
        if (mobileMoneyNumber != null) 'mobile_money_number': mobileMoneyNumber,
        // Vérifier que promo_code n'est pas vide
        if (promoCode != null && promoCode.isNotEmpty) 'promo_code': promoCode,
        if (scheduledAt != null) 'scheduled_at': scheduledAt,
        if (specialInstructions != null)
          'special_instructions': specialInstructions,
      };

      //  Log avant l'envoi
      AppLogger.debug('Creating order with data: $data');
      AppLogger.debug(
        'Order type: $type, Payment: $paymentMethod, PromoCode: $promoCode',
      );

      //  Faire la requête
      final response = await _apiService.post('/orders', data: data);

      //  Vérifier que la réponse n'est pas null
      if (response.data == null) {
        AppLogger.error(
          'OrderRepository.createOrder',
          'Response.data is completely null',
        );
        throw Exception('Response data is null');
      }

      //  Log la réponse complète pour inspection
      AppLogger.debug('Order creation response status: ${response.statusCode}');
      AppLogger.debug('Order creation full response: ${response.data}');

      //  Vérifier success
      if (response.data['success'] == true) {
        AppLogger.debug('Server responded with success=true');

        //  Extraire les données
        final responseData = response.data['data'] as Map<String, dynamic>?;

        if (responseData == null) {
          AppLogger.error(
            'OrderRepository.createOrder',
            'Response data is null even though success=true. Full response: ${response.data}',
          );
          return {
            'success': false,
            'message': 'Données de réponse vides',
            'fullResponse': response.data,
          };
        }

        AppLogger.debug(
          'Response data structure: ${responseData.keys.toList()}',
        );

        //  Extraire la commande
        final orderJson = responseData['order'] as Map<String, dynamic>?;

        if (orderJson == null) {
          AppLogger.error(
            'OrderRepository.createOrder',
            'Order object is null in response. Response data keys: ${responseData.keys.toList()}, Full response data: $responseData',
          );
          return {
            'success': false,
            'message': 'Commande non trouvée dans la réponse',
            'responseData': responseData,
          };
        }

        AppLogger.debug('Order JSON keys: ${orderJson.keys.toList()}');
        AppLogger.debug('Order JSON: $orderJson');

        //  Parser la commande
        try {
          AppLogger.debug('Starting to parse order from JSON...');
          final order = OrderModel.fromJson(orderJson);

          AppLogger.debug(
            'Order parsed successfully: id=${order.id}, orderNumber=${order.orderNumber}, status=${order.status}',
          );

          // Extraire le paiement
          final paymentJson = responseData['payment'] as Map<String, dynamic>?;

          AppLogger.debug('Payment data: $paymentJson');

          //  Retourner le succès
          return {
            'success': true,
            'message': response.data['message'] ?? 'Commande créée avec succès',
            'order': order,
            'payment': paymentJson,
          };
        } catch (parseError) {
          AppLogger.error(
            'OrderRepository.createOrder - PARSING ERROR',
            parseError,
          );
          AppLogger.debug('Failed to parse order JSON: $orderJson');
          AppLogger.debug('Parsing error details: $parseError');

          return {
            'success': false,
            'message':
                'Erreur lors du parsing de la commande: ${parseError.toString()}',
            'rawOrder': orderJson,
            'parseError': parseError.toString(),
          };
        }
      } else {
        // Gestion des erreurs du serveur (success=false)
        AppLogger.error(
          'OrderRepository.createOrder',
          'Server returned success=false',
        );

        AppLogger.debug('Server error message: ${response.data['message']}');
        AppLogger.debug('Server error object: ${response.data['error']}');
        AppLogger.debug('Server validation errors: ${response.data['errors']}');

        return {
          'success': false,
          'message':
              response.data['message'] ??
              'Erreur lors de la création de la commande',
          'error': response.data['error'],
          'errors': response.data['errors'], // Les erreurs de validation
          'fullResponse': response.data,
        };
      }
    } catch (e, stackTrace) {
      //  Gestion des exceptions
      AppLogger.error('OrderRepository.createOrder - EXCEPTION', e);
      AppLogger.debug('Exception details: $e');
      AppLogger.debug('Stack trace: $stackTrace');

      return {
        'success': false,
        'message': 'Erreur: ${e.toString()}',
        'exception': e.toString(),
        'stackTrace': stackTrace.toString(),
      };
    }
  }

  // recuperation des commandes
  Future<Map<String, dynamic>> getOrders({
    int page = 1,
    int perPage = AppConstants.defaultPageSize,
  }) async {
    try {
      final response = await _apiService.get(
        '/orders',
        queryParameters: {'page': page, 'per_page': perPage},
      );

      if (response.data == null) {
        throw Exception('Response data is null');
      }

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>?;

        if (data == null) {
          return {
            'success': false,
            'message': 'Données vides',
            'orders': <OrderModel>[],
          };
        }

        final ordersList = data['orders'] as List<dynamic>? ?? [];
        final pagination = data['pagination'] as Map<String, dynamic>?;

        final orders = <OrderModel>[];
        for (final o in ordersList) {
          try {
            if (o is Map<String, dynamic>) {
              orders.add(OrderModel.fromJson(o));
            }
          } catch (e) {
            AppLogger.error('Failed to parse order', e);
          }
        }

        return {'success': true, 'orders': orders, 'pagination': pagination};
      }

      return {
        'success': false,
        'message':
            response.data['message'] ??
            'Erreur lors de la récupération des commandes',
        'orders': <OrderModel>[],
      };
    } catch (e) {
      AppLogger.error('OrderRepository.getOrders', e);
      return {
        'success': false,
        'message': e.toString(),
        'orders': <OrderModel>[],
      };
    }
  }

  Future<OrderModel?> getOrder(int id) async {
    try {
      final response = await _apiService.get('/orders/$id');

      if (response.data == null) return null;

      if (response.data['success'] == true) {
        final responseData = response.data['data'] as Map<String, dynamic>?;

        if (responseData == null) return null;

        final orderData = responseData['order'] as Map<String, dynamic>?;

        if (orderData == null) return null;

        return OrderModel.fromJson(orderData);
      }

      return null;
    } catch (e) {
      AppLogger.error('OrderRepository.getOrder', e);
      return null;
    }
  }

  Future<Map<String, dynamic>> cancelOrder(
    int id, {
    String reason = 'Annulation par le client',
  }) async {
    try {
      final response = await _apiService.post(
        '/orders/$id/cancel',
        data: {'reason': reason},
      );

      if (response.data == null) {
        return {'success': false, 'message': 'Erreur de réponse serveur'};
      }

      return {
        'success': response.data['success'] == true,
        'message': response.data['message'] ?? 'Erreur lors de l\'annulation',
      };
    } catch (e) {
      AppLogger.error('OrderRepository.cancelOrder', e);
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<bool> reorder(int orderId) async {
    try {
      final response = await _apiService.post('/orders/$orderId/reorder');

      if (response.data == null) return false;

      return response.data['success'] == true;
    } catch (e) {
      AppLogger.error('OrderRepository.reorder', e);
      return false;
    }
  }

  Future<Map<String, dynamic>?> getInvoice(int orderId) async {
    try {
      final response = await _apiService.get('/orders/$orderId/invoice');

      if (response.data == null) return null;

      if (response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>?;
      }

      return null;
    } catch (e) {
      AppLogger.error('OrderRepository.getInvoice', e);
      return null;
    }
  }

  Future<Map<String, dynamic>> confirmStripePayment({
    required int orderId,
    required String paymentIntentId,
  }) async {
    try {
      final response = await _apiService.post(
        '/payments/stripe/confirm',
        data: {'order_id': orderId, 'payment_intent_id': paymentIntentId},
      );

      if (response.data == null) {
        return {'success': false, 'message': 'Erreur de réponse serveur'};
      }

      if (response.data['success'] == true) {
        return {'success': true, 'message': response.data['message']};
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Erreur lors de la confirmation',
        'error': response.data['error'],
      };
    } catch (e) {
      AppLogger.error('OrderRepository.confirmStripePayment', e);
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> createMobileMoneyPayment({
    required int orderId,
    required String provider,
    required String phoneNumber,
  }) async {
    try {
      final response = await _apiService.post(
        '/payments/mobile-money/create',
        data: {
          'order_id': orderId,
          'provider': provider,
          'phone_number': phoneNumber,
        },
      );

      if (response.data == null) {
        return {'success': false, 'message': 'Erreur de réponse serveur'};
      }

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>?;

        if (data == null) {
          return {'success': false, 'message': 'Données de paiement vides'};
        }

        return {
          'success': true,
          'message': response.data['message'],
          'transaction_id': data['transaction_id'],
          'status': data['status'],
          'amount': data['amount'],
          'provider': data['provider'],
        };
      }

      return {
        'success': false,
        'message':
            response.data['message'] ??
            'Erreur lors de la création du paiement',
        'error': response.data['error'],
      };
    } catch (e) {
      AppLogger.error('OrderRepository.createMobileMoneyPayment', e);
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> checkMobileMoneyStatus(int orderId) async {
    try {
      final response = await _apiService.post(
        '/payments/mobile-money/status',
        data: {'order_id': orderId},
      );

      if (response.data == null) {
        return {'success': false, 'message': 'Erreur de réponse serveur'};
      }

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>?;

        if (data == null) {
          return {'success': false, 'message': 'Données de statut vides'};
        }

        return {
          'success': true,
          'status': data['status'],
          'payment_status': data['payment_status'],
          'order_status': data['order_status'],
          'amount': data['amount'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Erreur lors de la vérification',
        'error': response.data['error'],
      };
    } catch (e) {
      AppLogger.error('OrderRepository.checkMobileMoneyStatus', e);
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>?> downloadInvoice(int orderId) async {
    try {
      final response = await _apiService.get('/orders/$orderId/invoice');

      if (response.data == null) {
        return null;
      }

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>?;

        if (data != null) {
          return {
            'success': true,
            'invoice_base64': data['invoice_base64'] as String? ?? '',
            'filename': data['filename'] as String? ?? 'facture.pdf',
          };
        }
      }

      return {
        'success': false,
        'message': 'Erreur lors du téléchargement de la facture',
      };
    } catch (e) {
      AppLogger.error('OrderRepository.downloadInvoice', e);
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>?> getOrderTracking(int orderId) async {
    try {
      final response = await _apiService.get('/orders/$orderId/tracking');

      if (response.data == null) {
        return null;
      }

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>?;

        if (data == null) {
          return {'success': false, 'message': 'Données de suivi vides'};
        }

        return {
          'success': true,
          'data': {
            'position': data['position'] as Map<String, dynamic>?,
            'driver': data['driver'] as Map<String, dynamic>?,
            'eta_minutes': data['eta_minutes'] as int?,
            'distance_km': data['distance_km'] as double?,
            'message': data['message'] as String?,
          },
        };
      }

      return {
        'success': false,
        'message':
            response.data['message'] ?? 'Commande non en cours de livraison',
      };
    } catch (e) {
      AppLogger.error('OrderRepository.getOrderTracking', e);
      return {'success': false, 'message': e.toString()};
    }
  }
}
