import 'package:flutter/material.dart';
import 'package:chelsy_restaurant/core/theme/app_colors.dart';
import 'package:chelsy_restaurant/presentation/pages/auth/login_form.dart';
import 'package:chelsy_restaurant/presentation/pages/auth/register_form.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLogin = true;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: height * 0.35,
              child: ClipPath(
                clipper: BottomWaveClipper(),
                child: Container(
                  color: AppColors.primary,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/chelsy_script_blanc.png',
                            height: 55,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bienvenue dans votre nouvelle safe place.',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.white.withValues(alpha: 0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: height * 0.65,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Toggle buttons
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildToggleButton(
                                "S'inscrire",
                                !_isLogin,
                                onTap: () => setState(() => _isLogin = false),
                              ),
                            ),
                            Expanded(
                              child: _buildToggleButton(
                                'Se connecter',
                                _isLogin,
                                onTap: () => setState(() => _isLogin = true),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _isLogin ? const LoginForm() : const RegisterForm(),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'or',
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: const BoxDecoration(
                              color: AppColors.facebookBlue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.facebook,
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: AppColors.greyLight,
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: Image.asset(
                                fit: BoxFit.contain,
                                'assets/icons/google.png',
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.g_mobiledata,
                                    size: 30,
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 4,
                        children: [
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              'Politique de confidentialité.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          Text(
                            '|',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              'Conditions d\'utilisation',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(
    String text,
    bool isActive, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isActive ? AppColors.white : AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// Custom clipper for bottom wave
class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Commence en haut à gauche
    path.moveTo(0, 0);

    // Descend sur la gauche pour commencer la vague
    path.lineTo(0, size.height * 0.8);

    // Premier pic de la vague
    path.quadraticBezierTo(
      size.width * 0.25, // X du point de contrôle
      size.height *
          0.95, // Y du point de contrôle, plus bas pour plus de profondeur
      size.width * 0.5, // X final du premier segment
      size.height * 0.8, // Y final du segment
    );

    // Deuxième pic de la vague
    path.quadraticBezierTo(
      size.width * 0.75, // X du point de contrôle
      size.height * 0.65, // Y plus haut pour créer un creux
      size.width, // X final
      size.height * 0.8, // Y final
    );

    // Ligne droite jusqu’en haut à droite
    path.lineTo(size.width, 0);

    // Ferme le path
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
