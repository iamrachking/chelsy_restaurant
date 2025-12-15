import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chelsy_restaurant/core/routes/app_routes.dart';
import 'package:chelsy_restaurant/core/utils/app_logger.dart';
import 'package:chelsy_restaurant/core/utils/date_formatter.dart';
import 'package:chelsy_restaurant/presentation/controllers/order_controller.dart';
import 'package:chelsy_restaurant/presentation/widgets/custom_button.dart';

class MobileMoneyPaymentPage extends StatefulWidget {
  const MobileMoneyPaymentPage({super.key});

  @override
  State<MobileMoneyPaymentPage> createState() => _MobileMoneyPaymentPageState();
}

class _MobileMoneyPaymentPageState extends State<MobileMoneyPaymentPage> {
  final OrderController _orderController = Get.find<OrderController>();
  bool _hasError = false;

  late int orderId;
  late String transactionId;
  late double amount;
  late String provider;
  late String message;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _startPolling();
  }

  void _initializeData() {
    final args = Get.arguments as Map<String, dynamic>?;

    if (args != null) {
      orderId = args['order_id'] as int? ?? 0;
      transactionId = args['transaction_id'] as String? ?? '';
      amount = args['amount'] as double? ?? 0.0;
      provider = args['provider'] as String? ?? 'MTN';
      message = args['message'] as String? ?? '';
    }

    AppLogger.debug(
      'Mobile Money Payment initialized: orderId=$orderId, provider=$provider',
    );
  }

  void _startPolling() {
    AppLogger.debug('Starting polling for order $orderId');

    _orderController
        .pollMobileMoneyPaymentStatus(
          orderId: orderId,
          maxAttempts: 120,
          intervalSeconds: 5,
        )
        .then((success) {
          if (mounted) {
            if (success) {
              Get.offNamedUntil(
                AppRoutes.orderDetail,
                (route) => route.settings.name == AppRoutes.home,
                arguments: orderId,
              );
            } else {
              setState(() => _hasError = true);
            }
          }
        })
        .catchError((e) {
          AppLogger.error('Mobile Money polling error', e);
          if (mounted) {
            setState(() => _hasError = true);
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement Mobile Money'),
        elevation: 0,
        automaticallyImplyLeading: !_hasError,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_hasError) ...[
              // ==================== ÉCRAN EN ATTENTE ====================
              const SizedBox(height: 40),

              Center(
                child: Column(
                  children: [
                    const CircularProgressIndicator(strokeWidth: 3),
                    const SizedBox(height: 24),
                    Text(
                      'En attente du paiement...',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Détails du paiement
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Montant'),
                          Text(
                            DateFormatter.formatCurrency(amount),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Fournisseur'),
                          Text(
                            provider,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('ID Transaction'),
                          Flexible(
                            child: SelectableText(
                              transactionId,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Message d'instruction
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.orange[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Instructions',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Colors.orange[700],
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(message, style: TextStyle(color: Colors.orange[700])),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Étapes à suivre
              _buildSteps(context),
            ] else ...[
              // ==================== ÉCRAN D'ERREUR ====================
              const SizedBox(height: 40),

              Center(
                child: Column(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[700], size: 64),
                    const SizedBox(height: 24),
                    Text(
                      'Erreur de paiement',
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: Colors.red[700]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Le paiement n\'a pas pu être traité',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              CustomButton(
                text: 'Réessayer',
                onPressed: () {
                  setState(() => _hasError = false);
                  _startPolling();
                },
                width: double.infinity,
              ),
              const SizedBox(height: 12),

              OutlinedButton(
                onPressed: () {
                  Get.offAllNamed(AppRoutes.home);
                },
                child: const Text('Retour à l\'accueil'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSteps(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Étapes à suivre:',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildStep(
          number: 1,
          title: 'Composer le code',
          description: 'Composez *384*1# depuis votre téléphone',
        ),
        const SizedBox(height: 12),
        _buildStep(
          number: 2,
          title: 'Entrer le montant',
          description: '${DateFormatter.formatCurrency(amount)} XOF',
        ),
        const SizedBox(height: 12),
        _buildStep(
          number: 3,
          title: 'Confirmer',
          description: 'Suivez les instructions sur votre téléphone',
        ),
        const SizedBox(height: 12),
        _buildStep(
          number: 4,
          title: 'Validation',
          description: 'Votre paiement sera vérifié automatiquement',
        ),
      ],
    );
  }

  Widget _buildStep({
    required int number,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(description, style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      ],
    );
  }
}
