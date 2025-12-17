import 'package:chelsy_restaurant/data/models/address_model.dart';
import 'package:chelsy_restaurant/data/models/dish_model.dart';
import 'package:chelsy_restaurant/data/models/user_model.dart';

class OrderItemModel {
  final int id;
  final int dishId;
  final String dishName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? specialInstructions;
  final DishModel? dish;

  OrderItemModel({
    required this.id,
    required this.dishId,
    required this.dishName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.specialInstructions,
    this.dish,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    try {
      return OrderItemModel(
        id: _parseIntSafely(json['id']),
        dishId: _parseIntSafely(json['dish_id']),
        dishName: (json['dish_name'] as String?)?.trim() ?? 'Plat inconnu',
        quantity: _parseIntSafely(json['quantity']),
        unitPrice: _parseDoubleSafely(json['unit_price']),
        totalPrice: _parseDoubleSafely(json['total_price']),
        specialInstructions: (json['special_instructions'] as String?)?.trim(),
        dish: json['dish'] != null && json['dish'] is Map<String, dynamic>
            ? DishModel.fromJson(json['dish'] as Map<String, dynamic>)
            : null,
      );
    } catch (e) {
      return OrderItemModel(
        id: 0,
        dishId: 0,
        dishName: 'Erreur parsing',
        quantity: 1,
        unitPrice: 0.0,
        totalPrice: 0.0,
      );
    }
  }

  static int _parseIntSafely(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDoubleSafely(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final cleaned = (value).trim().replaceAll(',', '.');
      return double.tryParse(cleaned) ?? 0.0;
    }
    return 0.0;
  }
}

class PaymentModel {
  final int id;
  final int orderId;
  final String method;
  final String status;
  final double amount;
  final String? transactionId;
  final String? mobileMoneyProvider;
  final String? mobileMoneyNumber;
  final Map<String, dynamic>? paymentData;
  final String? failureReason;

  PaymentModel({
    required this.id,
    required this.orderId,
    required this.method,
    required this.status,
    required this.amount,
    this.transactionId,
    this.mobileMoneyProvider,
    this.mobileMoneyNumber,
    this.paymentData,
    this.failureReason,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    try {
      return PaymentModel(
        id: _parseIntSafely(json['id']),
        orderId: _parseIntSafely(json['order_id']),
        method: (json['method'] as String?)?.trim() ?? 'unknown',
        status: (json['status'] as String?)?.trim() ?? 'pending',
        amount: _parseDoubleSafely(json['amount']),
        transactionId: (json['transaction_id'] as String?)?.trim(),
        mobileMoneyProvider: (json['mobile_money_provider'] as String?)?.trim(),
        mobileMoneyNumber: (json['mobile_money_number'] as String?)?.trim(),
        paymentData: json['payment_data'] is Map<String, dynamic>
            ? json['payment_data'] as Map<String, dynamic>
            : null,
        failureReason: (json['failure_reason'] as String?)?.trim(),
      );
    } catch (e) {
      return PaymentModel(
        id: 0,
        orderId: 0,
        method: 'unknown',
        status: 'failed',
        amount: 0.0,
      );
    }
  }

  static int _parseIntSafely(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDoubleSafely(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final trimmed = value.trim();
      final cleaned = trimmed.replaceAll(',', '.');
      return double.tryParse(cleaned) ?? 0.0;
    }
    return 0.0;
  }
}

class OrderModel {
  final int id;
  final String orderNumber;
  final int userId;
  final int? driverId;
  final int restaurantId;
  final int? addressId;
  final String type;
  final String status;
  final double subtotal;
  final double deliveryFee;
  final double discountAmount;
  final double total;
  final String? promoCode;
  final DateTime? scheduledAt;
  final DateTime? deliveredAt;
  final String? cancellationReason;
  final String? specialInstructions;
  final List<OrderItemModel> items;
  final PaymentModel? payment;
  final AddressModel? address;
  final Map<String, dynamic>? restaurant;
  final UserModel? driver;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.userId,
    this.driverId,
    required this.restaurantId,
    this.addressId,
    required this.type,
    required this.status,
    required this.subtotal,
    required this.deliveryFee,
    required this.discountAmount,
    required this.total,
    this.promoCode,
    this.scheduledAt,
    this.deliveredAt,
    this.cancellationReason,
    this.specialInstructions,
    required this.items,
    this.payment,
    this.address,
    this.restaurant,
    this.driver,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    try {
      //  Parser les IDs
      final id = _parseIntSafely(json['id']);
      final userId = _parseIntSafely(json['user_id']);
      final driverId = _parseIntSafelyNullable(json['driver_id']);
      final restaurantId = _parseIntSafely(json['restaurant_id']);
      final addressId = _parseIntSafelyNullable(json['address_id']);

      //  Parser orderNumber
      final orderNumber = (json['order_number'] as String?)?.trim();
      if (orderNumber == null || orderNumber.isEmpty) {
        throw Exception('order_number is null or empty in JSON');
      }

      //  Parser les montants
      final subtotal = _parseDoubleSafely(json['subtotal']);
      final deliveryFee = _parseDoubleSafely(json['delivery_fee']);
      final discountAmount = _parseDoubleSafely(json['discount_amount']);
      final total = _parseDoubleSafely(json['total']);

      // Parser les items
      final items = <OrderItemModel>[];
      if (json['items'] is List) {
        for (final item in (json['items'] as List)) {
          try {
            if (item != null && item is Map<String, dynamic>) {
              items.add(OrderItemModel.fromJson(item));
            }
          } catch (e) {
            // Ignorer les items qui ne peuvent pas être parsés
          }
        }
      }

      //  Parser les dates
      final createdAt = _parseDateSafely(json['created_at']);
      final updatedAt = _parseDateSafely(json['updated_at']);
      final scheduledAt = json['scheduled_at'] != null
          ? _parseDateSafely(json['scheduled_at'])
          : null;
      final deliveredAt = json['delivered_at'] != null
          ? _parseDateSafely(json['delivered_at'])
          : null;

      //  Parser le promo_code (peut être un objet Map ou une string)
      String? promoCode;
      if (json['promo_code'] != null) {
        if (json['promo_code'] is String) {
          //  Si c'est une string,on m'utilise directement
          promoCode = (json['promo_code'] as String).trim();
        } else if (json['promo_code'] is Map<String, dynamic>) {
          //  Si c'est un Map, on extraire le code
          final promoMap = json['promo_code'] as Map<String, dynamic>;
          promoCode = (promoMap['code'] as String?)?.trim();
        }
      }

      //  Parser payment avec protection
      PaymentModel? paymentModel;
      try {
        if (json['payment'] != null &&
            json['payment'] is Map<String, dynamic>) {
          paymentModel = PaymentModel.fromJson(
            json['payment'] as Map<String, dynamic>,
          );
        }
      } catch (e) {
        // Ignorer les erreurs de parsing du payment
      }

      //  Parser address avec protection
      AddressModel? addressModel;
      try {
        if (json['address'] != null &&
            json['address'] is Map<String, dynamic>) {
          addressModel = AddressModel.fromJson(
            json['address'] as Map<String, dynamic>,
          );
        }
      } catch (e) {
        // Ignorer les erreurs de parsing de l'adresse
      }

      //  Parser driver avec protection
      UserModel? driverModel;
      try {
        if (json['driver'] != null && json['driver'] is Map<String, dynamic>) {
          driverModel = UserModel.fromJson(
            json['driver'] as Map<String, dynamic>,
          );
        }
      } catch (e) {
        // Ignorer les erreurs de parsing du driver
      }

      return OrderModel(
        id: id,
        orderNumber: orderNumber,
        userId: userId,
        driverId: driverId,
        restaurantId: restaurantId,
        addressId: addressId,
        type: (json['type'] as String?)?.trim() ?? 'delivery',
        status: (json['status'] as String?)?.trim() ?? 'pending',
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        discountAmount: discountAmount,
        total: total,
        promoCode: promoCode, // ✅ Utiliser le code parsé correctement
        scheduledAt: scheduledAt,
        deliveredAt: deliveredAt,
        cancellationReason: (json['cancellation_reason'] as String?)?.trim(),
        specialInstructions: (json['special_instructions'] as String?)?.trim(),
        items: items,
        payment: paymentModel,
        address: addressModel,
        restaurant: json['restaurant'] is Map<String, dynamic>
            ? json['restaurant'] as Map<String, dynamic>
            : null,
        driver: driverModel,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    } catch (e) {
      //  Lancer l'exception pour que le repository/controller la voie
      throw Exception('Failed to parse OrderModel from JSON. Error: $e');
    }
  }

  //  HELPERS
  static int _parseIntSafely(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static int? _parseIntSafelyNullable(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double _parseDoubleSafely(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final trimmed = value.trim();
      final cleaned = trimmed.replaceAll(',', '.');
      return double.tryParse(cleaned) ?? 0.0;
    }
    return 0.0;
  }

  static DateTime _parseDateSafely(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  bool get canCancel => status == 'pending' || status == 'confirmed';
  bool get isDelivered => status == 'delivered' || status == 'picked_up';
}
