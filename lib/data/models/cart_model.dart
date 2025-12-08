import 'dish_model.dart';

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
    // Gestion des prix qui peuvent être des strings ou des num
    double parsePrice(dynamic value) {
      if (value is num) {
        return value.toDouble();
      } else if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }

    return CartItemModel(
      id: json['id'] as int? ?? 0,
      dishId: json['dish_id'] as int? ?? json['dish_id'] as int,
      quantity: json['quantity'] as int? ?? 1,
      unitPrice: parsePrice(json['unit_price']),
      totalPrice: parsePrice(json['total_price']),
      selectedOptions: json['selected_options'] is Map<String, dynamic>
          ? json['selected_options'] as Map<String, dynamic>
          : {},
      specialInstructions: json['special_instructions'] as String?,
      dish: json['dish'] != null && json['dish'] is Map<String, dynamic>
          ? DishModel.fromJson(json['dish'] as Map<String, dynamic>)
          : null,
    );
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

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final cartData = json['cart'] as Map<String, dynamic>? ?? json;

    // Gestion des prix qui peuvent être des strings ou des num
    double parsePrice(dynamic value) {
      if (value is num) {
        return value.toDouble();
      } else if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }

    // Calculer le subtotal depuis les items si non fourni
    final items =
        (cartData['items'] as List<dynamic>?)
            ?.where((item) => item is Map<String, dynamic>)
            .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];

    final calculatedSubtotal = items.fold<double>(
      0.0,
      (sum, item) => sum + item.totalPrice,
    );

    return CartModel(
      id: cartData['id'] as int? ?? 0,
      userId: cartData['user_id'] as int? ?? 0,
      items: items,
      subtotal: (json['subtotal'] != null || cartData['subtotal'] != null)
          ? parsePrice(json['subtotal'] ?? cartData['subtotal'])
          : calculatedSubtotal,
      totalItems:
          json['total_items'] as int? ??
          cartData['total_items'] as int? ??
          items.fold<int>(0, (sum, item) => sum + item.quantity),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cart': {
        'id': id,
        'user_id': userId,
        'items': items.map((item) => item.toJson()).toList(),
      },
      'subtotal': subtotal,
      'total_items': totalItems,
    };
  }
}
