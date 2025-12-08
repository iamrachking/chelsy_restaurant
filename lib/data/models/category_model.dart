class CategoryModel {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? image;
  final bool isActive;
  final int? order;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.image,
    required this.isActive,
    this.order,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      image: json['image'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      order: json['order'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'image': image,
      'is_active': isActive,
      'order': order,
    };
  }
}


