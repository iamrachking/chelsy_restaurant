class UserModel {
  final int id;
  final String firstname;
  final String lastname;
  final String email;
  final String? phone;
  final String? birthDate;
  final String? gender;
  final String? avatar;
  final bool emailVerified;
  final DateTime? lastLoginAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
    this.phone,
    this.birthDate,
    this.gender,
    this.avatar,
    required this.emailVerified,
    this.lastLoginAt,
    required this.createdAt,
    required this.updatedAt,
  });

  String get name => '$firstname $lastname';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    String? avatarUrl = json['avatar'] as String?;
    // Convertion des URLs relatives en URLs complètes
    if (avatarUrl != null &&
        avatarUrl.isNotEmpty &&
        !avatarUrl.startsWith('http')) {
      if (avatarUrl.startsWith('avatars/') ||
          avatarUrl.startsWith('/avatars/')) {
        avatarUrl =
            'https://chelsy-api.cabinet-xaviertermeau.com/storage/${avatarUrl.replaceFirst(RegExp(r'^/'), '')}';
      } else if (avatarUrl.startsWith('storage/')) {
        avatarUrl = 'https://chelsy-api.cabinet-xaviertermeau.com/$avatarUrl';
      }
    }

    return UserModel(
      id: json['id'] as int,
      firstname: json['firstname'] as String,
      lastname: json['lastname'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      birthDate: json['birth_date'] as String?,
      gender: json['gender'] as String?,
      avatar: avatarUrl,
      emailVerified: json['email_verified'] as bool? ?? false,
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'phone': phone,
      'birth_date': birthDate,
      'gender': gender,
      'avatar': avatar,
      'email_verified': emailVerified,
      'last_login_at': lastLoginAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
