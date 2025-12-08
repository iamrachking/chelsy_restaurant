class DishOptionValue {
  final int id;
  final String name;
  final double priceModifier;

  DishOptionValue({
    required this.id,
    required this.name,
    required this.priceModifier,
  });

  factory DishOptionValue.fromJson(Map<String, dynamic> json) {
    return DishOptionValue(
      id: json['id'] is int ? json['id'] : 0,
      name: json['name']?.toString() ?? '',
      priceModifier: (json['price_modifier'] is num)
          ? (json['price_modifier'] as num).toDouble()
          : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'price_modifier': priceModifier};
  }
}

class DishOption {
  final int id;
  final String name;
  final String type; // 'seule' ou 'multiple'
  final bool required;
  final int? order;
  final List<DishOptionValue> values;

  DishOption({
    required this.id,
    required this.name,
    required this.type,
    required this.required,
    this.order,
    required this.values,
  });

  factory DishOption.fromJson(Map<String, dynamic> json) {
    return DishOption(
      id: json['id'] is int ? json['id'] : 0,
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? 'single',
      required: json['required'] == true,
      order: json['order'] is int ? json['order'] : null,
      values: json['values'] is List
          ? (json['values'] as List)
                .whereType<Map<String, dynamic>>()
                .map(DishOptionValue.fromJson)
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'required': required,
      'order': order,
      'values': values.map((v) => v.toJson()).toList(),
    };
  }
}

class DishModel {
  final int id;
  final int categoryId;
  final String name;
  final String slug;
  final String? description;
  final double price;
  final double? discountPrice;
  final double finalPrice;
  final bool hasDiscount;
  final List<String> images;
  final String? image;
  final int preparationTimeMinutes;
  final List<String> allergens;
  final Map<String, dynamic>? nutritionalInfo;
  final bool isAvailable;
  final bool isFeatured;
  final bool isNew;
  final bool isVegetarian;
  final bool isSpecialty;
  final double? averageRating;
  final int reviewCount;
  final int orderCount;
  final List<DishOption> options;
  final DateTime createdAt;
  final DateTime updatedAt;

  DishModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.slug,
    this.description,
    required this.price,
    this.discountPrice,
    required this.finalPrice,
    required this.hasDiscount,
    required this.images,
    this.image,
    required this.preparationTimeMinutes,
    required this.allergens,
    this.nutritionalInfo,
    required this.isAvailable,
    required this.isFeatured,
    required this.isNew,
    required this.isVegetarian,
    required this.isSpecialty,
    this.averageRating,
    required this.reviewCount,
    required this.orderCount,
    required this.options,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DishModel.fromJson(Map<String, dynamic> json) {
    double parsePrice(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return DateTime.now();
      }
    }

    return DishModel(
      id: json['id'] is int ? json['id'] : 0,
      categoryId: json['category_id'] is int ? json['category_id'] : 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString(),
      price: parsePrice(json['price']),
      discountPrice: json['discount_price'] != null
          ? parsePrice(json['discount_price'])
          : null,
      finalPrice: parsePrice(json['final_price'] ?? json['price'] ?? 0),
      hasDiscount: json['has_discount'] == true,
      images: json['images'] is List
          ? List<String>.from(json['images'].map((e) => e.toString()))
          : [],
      image: json['image']?.toString(),
      preparationTimeMinutes: json['preparation_time_minutes'] is int
          ? json['preparation_time_minutes']
          : 0,
      allergens: json['allergens'] is List
          ? List<String>.from(json['allergens'].map((e) => e.toString()))
          : [],
      nutritionalInfo: json['nutritional_info'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['nutritional_info'])
          : null,
      isAvailable: json['is_available'] != false,
      isFeatured: json['is_featured'] == true,
      isNew: json['is_new'] == true,
      isVegetarian: json['is_vegetarian'] == true,
      isSpecialty: json['is_specialty'] == true,
      averageRating: json['average_rating'] != null
          ? parsePrice(json['average_rating'])
          : null,
      reviewCount: json['review_count'] is int ? json['review_count'] : 0,
      orderCount: json['order_count'] is int ? json['order_count'] : 0,
      options: json['options'] is List
          ? (json['options'] as List)
                .whereType<Map<String, dynamic>>()
                .map(DishOption.fromJson)
                .toList()
          : [],
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'slug': slug,
      'description': description,
      'price': price,
      'discount_price': discountPrice,
      'final_price': finalPrice,
      'has_discount': hasDiscount,
      'images': images,
      'image': image,
      'preparation_time_minutes': preparationTimeMinutes,
      'allergens': allergens,
      'nutritional_info': nutritionalInfo,
      'is_available': isAvailable,
      'is_featured': isFeatured,
      'is_new': isNew,
      'is_vegetarian': isVegetarian,
      'is_specialty': isSpecialty,
      'average_rating': averageRating,
      'review_count': reviewCount,
      'order_count': orderCount,
      'options': options.map((o) => o.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
