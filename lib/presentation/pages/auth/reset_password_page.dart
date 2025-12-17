import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chelsy_restaurant/core/routes/app_routes.dart';
import 'package:chelsy_restaurant/core/utils/validators.dart';
import 'package:chelsy_restaurant/presentation/controllers/auth_controller.dart';
import 'package:chelsy_restaurant/presentation/widgets/custom_button.dart';
import 'package:chelsy_restaurant/presentation/widgets/custom_text_field.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();

  bool _obscurePassword = true;
  bool _obscurePasswordConfirmation = true;

  @override
  void initState() {
    super.initState();
    // Pre-remplir l'email si passé en argument
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['email'] != null) {
      _emailController.text = args['email'];
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _tokenController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await _authController.resetPassword(
      email: _emailController.text.trim(),
      token: _tokenController.text.trim(),
      password: _passwordController.text,
      passwordConfirmation: _passwordConfirmationController.text,
    );

    if (success) {
      // Attendre que le snackbar soit visible avant de naviguer
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Get.offAllNamed(AppRoutes.auth);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Réinitialiser le mot de passe')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Icon(
                  Icons.lock_reset,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Nouveau mot de passe',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Entrez le token reçu par email et votre nouveau mot de passe',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'votre@email.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: Validators.email,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _tokenController,
                  label: 'Token',
                  hint: 'Token reçu par email',
                  prefixIcon: const Icon(Icons.vpn_key_outlined),
                  validator: (value) => Validators.required(value, 'Token'),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  label: 'Nouveau mot de passe',
                  hint: '••••••••',
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  validator: Validators.password,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordConfirmationController,
                  label: 'Confirmer le mot de passe',
                  hint: '••••••••',
                  obscureText: _obscurePasswordConfirmation,
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePasswordConfirmation
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(
                        () => _obscurePasswordConfirmation =
                            !_obscurePasswordConfirmation,
                      );
                    },
                  ),
                  validator: (value) => Validators.confirmPassword(
                    value,
                    _passwordController.text,
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _handleResetPassword(),
                ),
                const SizedBox(height: 24),
                Obx(
                  () => CustomButton(
                    text: 'Réinitialiser',
                    onPressed: _authController.isLoading.value
                        ? null
                        : _handleResetPassword,
                    isLoading: _authController.isLoading.value,
                    icon: Icons.check_circle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
