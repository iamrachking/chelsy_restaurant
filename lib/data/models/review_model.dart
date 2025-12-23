class ReviewModel {
  final int id;
  final int userId;
  final int? orderId;
  final int? dishId;
  final String type; // 'restaurant', 'dish', 'delivery'
  final int rating; // 1-5
  final String? comment;
  final List<String>? images;
  final String? restaurantResponse;
  final DateTime? restaurantResponseAt;
  final bool isApproved;
  final Map<String, dynamic>? user;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReviewModel({
    required this.id,
    required this.userId,
    this.orderId,
    this.dishId,
    required this.type,
    required this.rating,
    this.comment,
    this.images,
    this.restaurantResponse,
    this.restaurantResponseAt,
    required this.isApproved,
    this.user,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return DateTime.now();
      }
    }

    return ReviewModel(
      id: json['id'] is int ? json['id'] : 0,
      userId: json['user_id'] is int ? json['user_id'] : 0,
      orderId: json['order_id'] is int ? json['order_id'] : null,
      dishId: json['dish_id'] is int ? json['dish_id'] : null,
      type: json['type']?.toString() ?? 'dish',
      rating: json['rating'] is int ? json['rating'] : 0,
      comment: json['comment']?.toString(),
      images: json['images'] is List
          ? List<String>.from(json['images'].map((e) => e.toString()))
          : null,
      restaurantResponse: json['restaurant_response']?.toString(),
      restaurantResponseAt: json['restaurant_response_at'] != null
          ? parseDate(json['restaurant_response_at'])
          : null,
      isApproved: json['is_approved'] == true,
      user: json['user'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['user'])
          : null,
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'order_id': orderId,
      'dish_id': dishId,
      'type': type,
      'rating': rating,
      'comment': comment,
      'images': images,
      'restaurant_response': restaurantResponse,
      'restaurant_response_at': restaurantResponseAt?.toIso8601String(),
      'is_approved': isApproved,
      'user': user,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
