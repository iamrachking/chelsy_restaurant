import 'package:flutter/material.dart' hide Card;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:chelsy_restaurant/core/routes/app_routes.dart';
import 'package:chelsy_restaurant/core/utils/app_logger.dart';
import 'package:chelsy_restaurant/core/utils/date_formatter.dart';
import 'package:chelsy_restaurant/presentation/controllers/order_controller.dart';
import 'package:chelsy_restaurant/presentation/widgets/custom_button.dart';

class StripePaymentPage extends StatefulWidget {
  const StripePaymentPage({super.key});

  @override
  State<StripePaymentPage> createState() => _StripePaymentPageState();
}

class _StripePaymentPageState extends State<StripePaymentPage> {
  final OrderController _orderController = Get.find<OrderController>();
  bool _isProcessing = false;

  late int orderId;
  late String clientSecret;
  late String paymentIntentId;
  late String publishableKey;
  late double amount;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _initializeStripe();
  }

  //  Helper pour parser les doubles
  static double _parseAmount(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final cleaned = value.trim().replaceAll(',', '.');
      return double.tryParse(cleaned) ?? 0.0;
    }
    return 0.0;
  }

  //  Dans _initializeData(), convertir le montant du centimes à unité
  void _initializeData() {
    try {
      final args = Get.arguments as Map<String, dynamic>?;

      if (args != null) {
        orderId = args['order_id'] as int? ?? 0;
        clientSecret = args['client_secret'] as String? ?? '';
        paymentIntentId = args['payment_intent_id'] as String? ?? '';
        publishableKey = args['publishable_key'] as String? ?? '';

        //  FIX: Le montant vient du backend en unités (9500)
        // Stripe l'affiche en centimes (950000 dans l'API)
        // Mais nous on veut afficher 9500 à l'utilisateur
        dynamic amountValue = args['amount'];

        // Si c'est un string, parser sans diviser (déjà en centimes du backend)
        // Si c'est un double, vérifier si c'est en centimes ou en unités
        if (amountValue is String) {
          final parsed = double.tryParse(amountValue) ?? 0.0;
          // Si > 1000, c'est probablement en centimes, diviser par 100
          // amount = parsed > 1000 ? (parsed / 100) : parsed;
          amount = parsed;
        } else if (amountValue is double) {
          // Si > 1000, c'est probablement en centimes
          // amount = amountValue > 1000 ? (amountValue / 100) : amountValue;
          amount = amountValue;
        } else if (amountValue is int) {
          // amount = amountValue > 1000
          //     ? (amountValue / 100.0)
          //     : (amountValue.toDouble());
          amount = (amountValue.toDouble());
        } else {
          amount = _parseAmount(amountValue);
        }
      } else {
        orderId = 0;
        clientSecret = '';
        paymentIntentId = '';
        publishableKey = '';
        amount = 0.0;
      }

      AppLogger.debug(
        'Stripe Payment initialized: orderId=$orderId, amount=$amount',
      );
    } catch (e) {
      AppLogger.error('Error initializing Stripe Payment', e);
      orderId = 0;
      clientSecret = '';
      paymentIntentId = '';
      publishableKey = '';
      amount = 0.0;
    }
  }

  //  Initialiser Stripe avec la clé publique
  Future<void> _initializeStripe() async {
    try {
      if (publishableKey.isEmpty) {
        AppLogger.error('Stripe Error', 'Publishable key is empty');
        if (mounted) {
          Get.snackbar('Erreur', 'Configuration Stripe manquante');
        }
        return;
      }

      Stripe.publishableKey = publishableKey;
      await Stripe.instance.applySettings();

      AppLogger.debug('Stripe initialized successfully');
    } catch (e) {
      AppLogger.error('Stripe initialization error', e);
      if (mounted) {
        Get.snackbar('Erreur', 'Erreur lors de l\'initialisation Stripe');
      }
    }
  }

  //  Traiter le paiement avec Stripe
  Future<void> _processStripePayment() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      AppLogger.debug('Processing Stripe payment with clientSecret');

      //  Initialiser le paiement avec le clientSecret
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Chelsy Restaurant',
          style: ThemeMode.system,
        ),
      );

      AppLogger.debug('Payment sheet initialized successfully');

      //  Afficher le formulaire de paiement Stripe
      await Stripe.instance.presentPaymentSheet();

      AppLogger.debug('Payment completed successfully by user');

      //  Si on arrive ici, le paiement Stripe est réussi
      if (mounted) {
        await _confirmPaymentOnServer();
      }
    } on StripeException catch (e) {
      AppLogger.error(
        'Stripe Exception',
        '${e.error.code}: ${e.error.message}',
      );

      if (mounted) {
        //  Vérifier si l'utilisateur a annulé
        if (e.error.code == FailureCode.Canceled) {
          Get.snackbar(
            'Annulé',
            'Paiement annulé par l\'utilisateur',
            duration: const Duration(seconds: 3),
          );
        } else {
          Get.snackbar(
            'Erreur de paiement',
            e.error.message ?? 'Erreur lors du traitement du paiement',
            duration: const Duration(seconds: 4),
          );
        }
      }

      setState(() => _isProcessing = false);
    } catch (e) {
      AppLogger.error('Payment processing error', e);

      if (mounted) {
        Get.snackbar(
          'Erreur',
          'Erreur lors du traitement du paiement: ${e.toString()}',
          duration: const Duration(seconds: 4),
        );
        setState(() => _isProcessing = false);
      }
    }
  }

  //  Confirmer le paiement auprès du serveur
  Future<void> _confirmPaymentOnServer() async {
    try {
      AppLogger.debug('Confirming payment on server for order $orderId');

      final success = await _orderController.confirmStripePayment(
        orderId: orderId,
        paymentIntentId: paymentIntentId,
      );

      if (success && mounted) {
        Get.snackbar(
          'Succès',
          'Paiement confirmé avec succès',
          duration: const Duration(seconds: 2),
          snackPosition: SnackPosition.TOP,
        );

        //  Rediriger vers les détails de la commande
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          Get.offNamedUntil(
            AppRoutes.orderDetail,
            (route) => route.settings.name == AppRoutes.home,
            arguments: orderId,
          );
        }
      } else if (mounted) {
        Get.snackbar(
          'Erreur',
          'Impossible de confirmer le paiement auprès du serveur',
          duration: const Duration(seconds: 3),
        );
        setState(() => _isProcessing = false);
      }
    } catch (e) {
      AppLogger.error('Error confirming payment', e);
      if (mounted) {
        Get.snackbar(
          'Erreur',
          'Erreur lors de la confirmation: ${e.toString()}',
          duration: const Duration(seconds: 3),
        );
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paiement par Carte'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //  Montant à payer
            Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Montant à payer',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      DateFormatter.formatCurrency(amount),
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            //  Infos de sécurité
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Paiement sécurisé par Stripe',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Vos données bancaires sont traitées de manière sécurisée',
                          style: TextStyle(
                            color: Colors.blue[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            //  Info sur la commande
            Material(
              elevation: 1,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Détails du paiement',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Numéro de commande:'),
                        Text(
                          '$orderId',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Montant:'),
                        Text(
                          DateFormatter.formatCurrency(amount),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            //  Bouton de paiement principal
            CustomButton(
              text: _isProcessing
                  ? 'Traitement en cours...'
                  : 'Procéder au paiement',
              onPressed: _isProcessing ? null : _processStripePayment,
              isLoading: _isProcessing,
              width: double.infinity,
              icon: Icons.payment,
            ),
            const SizedBox(height: 16),

            //  Bouton annuler
            OutlinedButton(
              onPressed: _isProcessing ? null : () => Get.back(),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Annuler'),
            ),
            const SizedBox(height: 16),

            //  Info de sécurité en bas
            Center(
              child: Text(
                'Votre paiement est sécurisé et crypté par Stripe',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
