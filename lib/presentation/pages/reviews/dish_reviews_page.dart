import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chelsy_restaurant/presentation/controllers/review_controller.dart';
import 'package:chelsy_restaurant/core/utils/date_formatter.dart';
import 'package:chelsy_restaurant/core/theme/app_colors.dart';
import 'package:chelsy_restaurant/presentation/widgets/loading_widget.dart';
import 'package:chelsy_restaurant/presentation/widgets/empty_state_widget.dart';

class DishReviewsPage extends StatefulWidget {
  final int dishId;

  const DishReviewsPage({super.key, required this.dishId});

  @override
  State<DishReviewsPage> createState() => _DishReviewsPageState();
}

class _DishReviewsPageState extends State<DishReviewsPage> {
  late final ReviewController _reviewController = Get.find<ReviewController>();
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Charger les avis du plat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reviewController.loadDishReviews(widget.dishId, refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500) {
      if (_reviewController.hasMore.value &&
          !_reviewController.isLoading.value) {
        _reviewController.loadMoreReviews(widget.dishId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Avis'), elevation: 0),
      body: Obx(() {
        // Loading state
        if (_reviewController.isLoading.value &&
            _reviewController.reviews.isEmpty) {
          return const LoadingWidget();
        }

        // Empty state
        if (_reviewController.reviews.isEmpty &&
            !_reviewController.isLoading.value) {
          return EmptyStateWidget(
            icon: Icons.rate_review_outlined,
            title: 'Aucun avis',
            message: 'Soyez le premier à laisser un avis sur ce plat !',
            buttonText: 'Laisser un avis',
            onButtonTap: () => _leaveReview(),
          );
        }

        // Reviews list
        return RefreshIndicator(
          onRefresh: () =>
              _reviewController.loadDishReviews(widget.dishId, refresh: true),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount:
                _reviewController.reviews.length +
                (_reviewController.isLoading.value ? 1 : 0),
            itemBuilder: (context, index) {
              // Loading indicator at the end
              if (index == _reviewController.reviews.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final review = _reviewController.reviews[index];

              return _buildReviewCard(context, review);
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: _leaveReview,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, dynamic review) {
    final rating = review['rating'] as int? ?? 0;
    final comment = review['comment'] as String?;
    final userName = review['user']?['name'] ?? 'Utilisateur anonyme';
    final userEmail = review['user']?['email'] as String? ?? '';
    final createdAt = review['created_at'] as String?;
    final images = review['images'] as List<dynamic>?;

    DateTime? parsedDate;
    if (createdAt != null) {
      try {
        parsedDate = DateTime.parse(createdAt);
      } catch (_) {}
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Avatar, nom et date
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    userName[0].toUpperCase(),
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (userEmail.isNotEmpty)
                        Text(
                          userEmail,
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                if (parsedDate != null)
                  Text(
                    DateFormatter.formatRelativeTime(parsedDate),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Rating stars
            Row(
              children: List.generate(5, (starIndex) {
                return Icon(
                  starIndex < rating ? Icons.star : Icons.star_border,
                  color: AppColors.warning,
                  size: 18,
                );
              }),
            ),
            const SizedBox(height: 8),

            // Comment
            if (comment != null && comment.isNotEmpty) ...[
              Text(comment, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 12),
            ],

            // Images
            if (images != null && images.isNotEmpty) ...[
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (context, idx) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          images[idx] as String,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey[200],
                              child: const Icon(Icons.image_not_supported),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Rating badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getRatingColor(rating).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getRatingLabel(rating),
                style: TextStyle(
                  color: _getRatingColor(rating),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
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

  void _leaveReview() {
    Get.toNamed('/create-review', arguments: {'dishId': widget.dishId});
  }
}
