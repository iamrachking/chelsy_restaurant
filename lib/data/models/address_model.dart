class AddressModel {
  final int id;
  final int userId;
  final String label;
  final String street;
  final String city;
  final String? postalCode;
  final String country;
  final double latitude;
  final double longitude;
  final String? additionalInfo;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  AddressModel({
    required this.id,
    required this.userId,
    required this.label,
    required this.street,
    required this.city,
    this.postalCode,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.additionalInfo,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullAddress => '$street, $city, $country';

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      label: json['label'] as String,
      street: json['street'] as String,
      city: json['city'] as String,
      postalCode: json['postal_code'] as String?,
      country: json['country'] as String,
      latitude: json['latitude'] is String 
          ? double.parse(json['latitude'] as String)
          : (json['latitude'] as num).toDouble(),
      longitude: json['longitude'] is String
          ? double.parse(json['longitude'] as String)
          : (json['longitude'] as num).toDouble(),
      additionalInfo: json['additional_info'] as String?,
      isDefault: json['is_default'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'label': label,
      'street': street,
      'city': city,
      'postal_code': postalCode,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'additional_info': additionalInfo,
      'is_default': isDefault,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'label': label,
      'street': street,
      'city': city,
      'postal_code': postalCode,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'additional_info': additionalInfo,
      'is_default': isDefault,
    };
  }
}


