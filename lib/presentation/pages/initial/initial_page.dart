import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chelsy_restaurant/core/routes/app_routes.dart';
import 'package:chelsy_restaurant/core/services/storage_service.dart';
import 'package:chelsy_restaurant/presentation/controllers/auth_controller.dart';

/// Page de chargement initial après le splash screen natif
/// Cette page vérifie l'état de l'authentification et redirige vers la bonne page
class InitialPage extends StatefulWidget {
  const InitialPage({super.key});

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  final AuthController _authController = Get.find<AuthController>();
  final StorageService _storageService = Get.find<StorageService>();

  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Petit délai pour laisser le splash natif s'afficher
    await Future.delayed(const Duration(milliseconds: 200));

    // Vérifier si l'onboarding a été vu
    final hasSeenOnboarding = _storageService.hasSeenOnboarding();

    // Vérifier le statut d'authentification
    await _authController.checkAuthStatus();

    if (!mounted) return;

    // Navigation selon l'état
    if (!hasSeenOnboarding) {
      // Afficher l'onboarding pour les nouveaux utilisateurs
      Get.offAllNamed(AppRoutes.onboarding);
    } else if (_authController.isLoggedIn.value) {
      // Utilisateur connecté rediriger vers page principale
      Get.offAllNamed(AppRoutes.main);
    } else {
      // Utilisateur non connecté rediriger vers page d'authentification
      Get.offAllNamed(AppRoutes.auth);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Page de chargement si les donner ne sont pas encore diso
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
