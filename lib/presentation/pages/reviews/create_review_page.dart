import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chelsy_restaurant/presentation/controllers/review_controller.dart';
import 'package:chelsy_restaurant/core/theme/app_colors.dart';
import 'package:chelsy_restaurant/presentation/widgets/custom_button.dart';
import 'package:chelsy_restaurant/presentation/widgets/custom_text_field.dart';

class CreateReviewPage extends StatefulWidget {
  final int? orderId;
  final int? dishId;

  const CreateReviewPage({super.key, this.orderId, this.dishId});

  @override
  State<CreateReviewPage> createState() => _CreateReviewPageState();
}

class _CreateReviewPageState extends State<CreateReviewPage> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  final ReviewController _reviewController = Get.find<ReviewController>();

  int _rating = 5;
  int? _restaurantRating;
  int? _deliveryRating;
  List<String> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    _validateArguments();
  }

  void _validateArguments() {
    if (widget.orderId == null && widget.dishId == null) {
      Get.snackbar(
        'Erreur',
        'Impossible de créer un avis sans Order ID ou Dish ID',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.back();
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validation supplémentaire
    if (_rating < 1 || _rating > 5) {
      Get.snackbar(
        'Erreur',
        'Veuillez donner une note au plat',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (widget.orderId != null) {
      if (_restaurantRating == null || _restaurantRating! < 1) {
        Get.snackbar(
          'Erreur',
          'Veuillez noter le restaurant',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if (_deliveryRating == null || _deliveryRating! < 1) {
        Get.snackbar(
          'Erreur',
          'Veuillez noter la livraison',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }

    final success = await _reviewController.createReview(
      orderId: widget.orderId,
      dishId: widget.dishId,
      rating: _rating,
      restaurantRating: _restaurantRating,
      deliveryRating: _deliveryRating,
      comment: _commentController.text.trim().isEmpty
          ? null
          : _commentController.text.trim(),
      images: _selectedImages.isNotEmpty ? _selectedImages : null,
    );

    if (success && mounted) {
      Get.back();
      // Rafraîchir les avis si on crée un avis pour un plat
      if (widget.dishId != null) {
        _reviewController.loadDishReviews(widget.dishId!);
      }
    }
  }

  Widget _buildRatingSection(
    String title, {
    required int? rating,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(5, (index) {
            final starRating = index + 1;
            final isSelected = rating != null && index < rating;

            return InkWell(
              onTap: () => onChanged(starRating),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(
                  isSelected ? Icons.star : Icons.star_border,
                  color: AppColors.warning,
                  size: 40,
                ),
              ),
            );
          }),
        ),
        if (rating != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _getRatingLabel(rating),
              style: TextStyle(
                color: _getRatingColor(rating),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Color _getRatingColor(int rating) {
    if (rating >= 4) return Colors.green;
    if (rating == 3) return Colors.orange;
    return Colors.red;
  }

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 5:
        return 'Excellent';
      case 4:
        return 'Très bien';
      case 3:
        return 'Bien';
      case 2:
        return 'Acceptable';
      case 1:
        return 'Mauvais';
      default:
        return 'Non noté';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Laisser un avis')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dish rating section
                _buildRatingSection(
                  'Note du plat',
                  rating: _rating,
                  onChanged: (value) {
                    setState(() {
                      _rating = value;
                    });
                  },
                ),
                const SizedBox(height: 32),

                // Restaurant and Delivery ratings (if order)
                if (widget.orderId != null) ...[
                  _buildRatingSection(
                    'Note du restaurant',
                    rating: _restaurantRating,
                    onChanged: (value) {
                      setState(() {
                        _restaurantRating = value;
                      });
                    },
                  ),
                  const SizedBox(height: 32),
                  _buildRatingSection(
                    'Note de la livraison',
                    rating: _deliveryRating,
                    onChanged: (value) {
                      setState(() {
                        _deliveryRating = value;
                      });
                    },
                  ),
                  const SizedBox(height: 32),
                ],

                // Comment field
                CustomTextField(
                  controller: _commentController,
                  label: 'Commentaire (optionnel)',
                  hint: 'Partagez votre expérience...',
                  maxLines: 5,
                ),
                const SizedBox(height: 24),

                // Images section (placeholder for future implementation)
                Text(
                  'Ajouter des photos (en développement)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[50],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.image_outlined, color: Colors.grey[600]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Appuyez pour ajouter des photos',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Submit button
                Obx(
                  () => CustomButton(
                    text: 'Publier l\'avis',
                    onPressed: _reviewController.isLoading.value
                        ? null
                        : _submitReview,
                    isLoading: _reviewController.isLoading.value,
                    width: double.infinity,
                    icon: Icons.send,
                  ),
                ),
                const SizedBox(height: 16),

                // Error message display
                Obx(() {
                  if (_reviewController.errorMessage.value.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      border: Border.all(color: Colors.red[200]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red[600]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _reviewController.errorMessage.value,
                            style: TextStyle(color: Colors.red[600]),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
