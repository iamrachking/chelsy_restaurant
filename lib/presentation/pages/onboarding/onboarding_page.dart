import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chelsy_restaurant/core/routes/app_routes.dart';
import 'package:chelsy_restaurant/core/services/storage_service.dart';
import 'package:chelsy_restaurant/core/theme/app_colors.dart';
import 'package:chelsy_restaurant/presentation/widgets/custom_button.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final StorageService _storageService = Get.find<StorageService>();

  final List<OnboardingItem> _pages = [
    OnboardingItem(
      title: 'Savoureux',
      subtitle: '& Rapide',
      description:
          'Explore nos plats délicieux, faits maison avec des ingrédients frais.',
      icon: Icons.restaurant_menu,
      imagePath: 'assets/images/onboarding_img1.png',
    ),
    OnboardingItem(
      title: 'Livraison',
      subtitle: 'éclair',
      description: 'Un service rapide, fiable et toujours avec le sourire.',
      icon: Icons.delivery_dining,
      imagePath: 'assets/images/onboarding_img2.png',
    ),
    OnboardingItem(
      title: 'Simple.',
      subtitle: 'Rapide. Sécurisé.',
      description:
          'Règle ta commande en toute simplicité et en toute confiance.',
      icon: Icons.payment,
      imagePath: 'assets/images/onboarding_img3.png',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  void _completeOnboarding() {
    _storageService.setOnboardingSeen(true);
    Get.offAllNamed(AppRoutes.auth);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            // Bottom section
            Container(
              decoration: BoxDecoration(color: AppColors.backgroundBeige),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => _buildIndicator(index == _currentPage),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: _skipOnboarding,
                        child: Text(
                          'SKIP',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      CustomButton(
                        text: _currentPage == _pages.length - 1
                            ? 'START'
                            : 'NEXT',
                        onPressed: _nextPage,
                        backgroundColor: AppColors.primary,
                        textColor: AppColors.white,
                        width: 120,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingItem item) {
    return Container(
      decoration: BoxDecoration(
        // borderRadius: const BorderRadius.only(
        //   topLeft: Radius.circular(0),
        //   topRight: Radius.circular(10),
        //   bottomLeft: Radius.circular(20),
        //   bottomRight: Radius.circular(50),
        // ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary, AppColors.backgroundBeige],
          // stops: const [0.3, 0.3],
        ),
      ),
      child: Column(
        children: [
          // Image section
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Image.asset(
                  item.imagePath,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback icon if image not found
                    return Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(item.icon, size: 100, color: AppColors.white),
                    );
                  },
                ),
              ),
            ),
          ),
          // Text section
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              decoration: const BoxDecoration(color: AppColors.backgroundBeige),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Icon(item.icon, size: 40, color: AppColors.amber),
                  const SizedBox(height: 16),
                  // Title
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                      children: [
                        TextSpan(text: item.title),
                        if (item.subtitle.isNotEmpty) ...[
                          const TextSpan(text: '\n'),
                          TextSpan(
                            text: item.subtitle,
                            style: const TextStyle(fontSize: 36),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Description
                  Text(
                    item.description,
                    style: TextStyle(fontSize: 16, color: AppColors.primary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.greyLight,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final String imagePath;

  OnboardingItem({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.imagePath,
  });
}

class TopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path.lineTo(0, size.height * 0.65);

    path.quadraticBezierTo(
      size.width * 0.5,
      size.height,
      size.width,
      size.height * 0.65,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
