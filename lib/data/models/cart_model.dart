import 'package:chelsy_restaurant/data/models/dish_model.dart';

class CartItemModel {
  final int id;
  final int dishId;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final Map<String, dynamic> selectedOptions;
  final String? specialInstructions;
  final DishModel? dish;

  CartItemModel({
    required this.id,
    required this.dishId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.selectedOptions,
    this.specialInstructions,
    this.dish,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final parsedQuantity = json['quantity'] is int ? json['quantity'] : 1;
    final parsedUnitPrice = _parseDouble(json['unit_price']);

    // CORRECTION: Calculer le prix total si non fourni ou incorrect
    double parsedTotalPrice = _parseDouble(json['total_price']);

    // Si le total_price est 0 ou invalide, le recalculer
    if (parsedTotalPrice == 0.0 || parsedTotalPrice < parsedUnitPrice) {
      parsedTotalPrice = parsedUnitPrice * parsedQuantity;
    }

    return CartItemModel(
      id: json['id'] is int ? json['id'] : 0,
      dishId: json['dish_id'] is int ? json['dish_id'] : 0,
      quantity: parsedQuantity,
      unitPrice: parsedUnitPrice,
      totalPrice: parsedTotalPrice,
      selectedOptions: json['selected_options'] != null
          ? (json['selected_options'] is Map<String, dynamic>
                ? Map<String, dynamic>.from(json['selected_options'])
                : <String, dynamic>{})
          : <String, dynamic>{},
      specialInstructions: json['special_instructions']?.toString(),
      dish: json['dish'] != null
          ? DishModel.fromJson(json['dish'] as Map<String, dynamic>)
          : null,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dish_id': dishId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'selected_options': selectedOptions,
      'special_instructions': specialInstructions,
      'dish': dish?.toJson(),
    };
  }

  // Getter pour calculer le prix total en temps réel
  double get calculatedTotalPrice => unitPrice * quantity;
}

class CartModel {
  final int id;
  final int userId;
  final List<CartItemModel> items;
  final double subtotal;
  final int totalItems;

  CartModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.totalItems,
  });

  factory CartModel.empty() {
    return CartModel(id: 0, userId: 0, items: [], subtotal: 0.0, totalItems: 0);
  }

  factory CartModel.fromJson(Map<String, dynamic> json) {
    List<CartItemModel> items = [];

    if (json['items'] != null) {
      if (json['items'] is List) {
        items = (json['items'] as List)
            .where((item) => item != null && item is Map<String, dynamic>)
            .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    }

    // CORRECTION: TOUJOURS recalculer le subtotal et totalItems
    double calculatedSubtotal = items.fold<double>(
      0.0,
      (sum, item) => sum + (item.unitPrice * item.quantity),
    );

    int calculatedTotalItems = items.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );

    return CartModel(
      id: json['id'] is int ? json['id'] : 0,
      userId: json['user_id'] is int ? json['user_id'] : 0,
      items: items,
      subtotal: calculatedSubtotal, // Toujours recalculé
      totalItems: calculatedTotalItems, // Toujours recalculé
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'total_items': totalItems,
    };
  }

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  // Getter pour recalculer le subtotal en temps réel
  double get calculatedSubtotal => items.fold<double>(
    0.0,
    (sum, item) => sum + (item.unitPrice * item.quantity),
  );
}
