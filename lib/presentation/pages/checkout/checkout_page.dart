import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chelsy_restaurant/core/routes/app_routes.dart';
import 'package:chelsy_restaurant/core/utils/date_formatter.dart';
import 'package:chelsy_restaurant/core/constants/app_constants.dart';
import 'package:chelsy_restaurant/core/theme/app_colors.dart';
import 'package:chelsy_restaurant/core/utils/app_logger.dart';
import 'package:chelsy_restaurant/presentation/controllers/cart_controller.dart';
import 'package:chelsy_restaurant/presentation/controllers/order_controller.dart';
import 'package:chelsy_restaurant/presentation/controllers/address_controller.dart';
import 'package:chelsy_restaurant/presentation/controllers/promo_controller.dart';
import 'package:chelsy_restaurant/presentation/widgets/custom_button.dart';
import 'package:chelsy_restaurant/presentation/widgets/custom_text_field.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final CartController _cartController = Get.find<CartController>();
  final OrderController _orderController = Get.find<OrderController>();
  final AddressController _addressController = Get.find<AddressController>();
  final PromoController _promoController = Get.find<PromoController>();

  String _orderType = AppConstants.orderTypeDelivery;
  String _paymentMethod = AppConstants.paymentMethodCash;
  int? _selectedAddressId;
  String? _mobileMoneyProvider;
  final _mobileMoneyPhoneController = TextEditingController();
  final _specialInstructionsController = TextEditingController();
  final _promoCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _addressController.loadAddresses();
  }

  @override
  void dispose() {
    _mobileMoneyPhoneController.dispose();
    _specialInstructionsController.dispose();
    _promoCodeController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    if (_orderType == AppConstants.orderTypeDelivery &&
        _selectedAddressId == null) {
      Get.snackbar('Erreur', 'Veuillez sélectionner une adresse de livraison');
      return false;
    }

    if (_paymentMethod == AppConstants.paymentMethodMobileMoney) {
      if (_mobileMoneyProvider == null || _mobileMoneyProvider!.isEmpty) {
        Get.snackbar(
          'Erreur',
          'Veuillez sélectionner un fournisseur Mobile Money',
        );
        return false;
      }

      if (_mobileMoneyPhoneController.text.trim().isEmpty) {
        Get.snackbar('Erreur', 'Veuillez entrer votre numéro Mobile Money');
        return false;
      }
    }

    return true;
  }

  Future<void> _createOrder() async {
    if (!_validateForm()) return;

    try {
      AppLogger.debug(
        'Creating order with promo: ${_promoCodeController.text}',
      );

      final result = await _orderController.createOrder(
        type: _orderType,
        addressId: _selectedAddressId,
        paymentMethod: _paymentMethod,
        mobileMoneyProvider: _mobileMoneyProvider,
        mobileMoneyNumber: _mobileMoneyPhoneController.text.trim(),
        promoCode: _promoController.validatedPromo.value != null
            ? _promoCodeController.text.trim()
            : null,
        specialInstructions: _specialInstructionsController.text.trim().isEmpty
            ? null
            : _specialInstructionsController.text.trim(),
      );

      if (result['success'] == true) {
        final order = result['order'];
        final payment = result['payment'] as Map<String, dynamic>?;

        AppLogger.debug('Order created: ${order.orderNumber}');

        await _cartController.clearCart();
        _promoController.clearPromo();

        // Traitement du paiement selon la méthode
        if (_paymentMethod == AppConstants.paymentMethodCard) {
          _handleStripePayment(order.id, payment);
        } else if (_paymentMethod == AppConstants.paymentMethodMobileMoney) {
          _handleMobileMoneyPayment(order.id, payment);
        } else {
          Get.toNamed(
            AppRoutes.orderDetail,
            arguments: order.id,
            parameters: {'fromCheckout': 'true'},
          );
        }
      } else {
        AppLogger.error('CheckoutPage._createOrder', 'Order creation failed');
        Get.snackbar(
          'Erreur',
          result['message'] ?? 'Erreur lors de la création',
        );
      }
    } catch (e) {
      AppLogger.error('CheckoutPage._createOrder', e);
      Get.snackbar('Erreur', 'Une erreur est survenue');
    }
  }

  void _handleStripePayment(int orderId, Map<String, dynamic>? paymentInfo) {
    if (paymentInfo == null) {
      Get.snackbar('Erreur', 'Information de paiement manquante');
      return;
    }

    Get.toNamed(
      AppRoutes.stripePayment,
      arguments: {
        'order_id': orderId,
        'client_secret': paymentInfo['client_secret'] ?? '',
        'payment_intent_id': paymentInfo['payment_intent_id'] ?? '',
        'publishable_key': paymentInfo['publishable_key'] ?? '',
        'amount': paymentInfo['amount'] ?? 0.0,
      },
    );
  }

  void _handleMobileMoneyPayment(
    int orderId,
    Map<String, dynamic>? paymentInfo,
  ) {
    if (paymentInfo == null) {
      Get.snackbar('Erreur', 'Information de paiement manquante');
      return;
    }

    Get.toNamed(
      AppRoutes.mobileMoneyPayment,
      arguments: {
        'order_id': orderId,
        'transaction_id': paymentInfo['transaction_id'] ?? '',
        'amount': paymentInfo['amount'] ?? 0.0,
        'provider': paymentInfo['provider'] ?? 'MTN',
        'message': paymentInfo['message'] ?? '',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout'), elevation: 0),
      body: Obx(() {
        final cart = _cartController.cart.value;

        if (cart.items.isEmpty) {
          return const Center(child: Text('Panier vide'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type de commande
              _buildSectionTitle(context, 'Type de commande'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Livraison'),
                      selected: _orderType == AppConstants.orderTypeDelivery,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _orderType = AppConstants.orderTypeDelivery;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('À emporter'),
                      selected: _orderType == AppConstants.orderTypePickup,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _orderType = AppConstants.orderTypePickup;
                            _selectedAddressId = null;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Sélection d'adresse si livraison
              if (_orderType == AppConstants.orderTypeDelivery) ...[
                _buildSectionTitle(context, 'Adresse de livraison'),
                const SizedBox(height: 12),
                Obx(() {
                  if (_addressController.addresses.isEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Aucune adresse enregistrée'),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Ajouter une adresse'),
                          onPressed: () async {
                            await Get.toNamed(AppRoutes.addresses);
                            _addressController.loadAddresses();
                          },
                        ),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      ..._addressController.addresses.map((address) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: RadioListTile<int>(
                            title: Text(address.label),
                            subtitle: Text(address.fullAddress),
                            value: address.id,
                            groupValue: _selectedAddressId,
                            onChanged: (value) {
                              setState(() {
                                _selectedAddressId = value;
                              });
                            },
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Ajouter une adresse'),
                        onPressed: () async {
                          await Get.toNamed(AppRoutes.addresses);
                          _addressController.loadAddresses();
                        },
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 24),
              ],

              // Méthode de paiement
              _buildSectionTitle(context, 'Méthode de paiement'),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text('Espèces'),
                      subtitle: const Text('À payer à la livraison'),
                      value: AppConstants.paymentMethodCash,
                      groupValue: _paymentMethod,
                      onChanged: (value) {
                        setState(() {
                          _paymentMethod = value!;
                        });
                      },
                    ),
                    const Divider(height: 0.5),
                    RadioListTile<String>(
                      title: const Text('Carte bancaire'),
                      subtitle: const Text('Stripe - Sécurisé'),
                      value: AppConstants.paymentMethodCard,
                      groupValue: _paymentMethod,
                      onChanged: (value) {
                        setState(() {
                          _paymentMethod = value!;
                        });
                      },
                    ),
                    const Divider(height: 0),
                    RadioListTile<String>(
                      title: const Text('Mobile Money'),
                      subtitle: const Text('MTN ou Moov'),
                      value: AppConstants.paymentMethodMobileMoney,
                      groupValue: _paymentMethod,
                      onChanged: (value) {
                        setState(() {
                          _paymentMethod = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Mobile Money
              if (_paymentMethod == AppConstants.paymentMethodMobileMoney) ...[
                _buildSectionTitle(context, 'Informations Mobile Money'),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _mobileMoneyProvider,
                  decoration: const InputDecoration(
                    labelText: 'Fournisseur',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'MTN', child: Text('MTN')),
                    DropdownMenuItem(value: 'Moov', child: Text('Moov')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _mobileMoneyProvider = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _mobileMoneyPhoneController,
                  label: 'Numéro de téléphone',
                  hint: '+229 01 12 34 56 78',
                  prefixIcon: const Icon(Icons.phone),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24),
              ],

              // Code promo
              _buildSectionTitle(context, 'Code promo'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _promoCodeController,
                      label: 'Code promo (optionnel)',
                      hint: 'PROMO10',
                      prefixIcon: const Icon(Icons.local_offer_outlined),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Obx(
                    () => ElevatedButton(
                      onPressed: _promoController.isLoading.value
                          ? null
                          : () {
                              if (_promoCodeController.text.trim().isNotEmpty) {
                                _promoController.validatePromoCode(
                                  _promoCodeController.text.trim(),
                                  _cartController.cart.value.subtotal,
                                );
                              } else {
                                Get.snackbar('Erreur', 'Entrez un code promo');
                              }
                            },
                      child: const Text('Valider'),
                    ),
                  ),
                ],
              ),
              //  AFFICHAGE DU CODE PROMO VALIDÉ
              Obx(() {
                if (_promoController.validatedPromo.value != null) {
                  final promo = _promoController.validatedPromo.value!;
                  final discount = _promoController.discountAmount;

                  return Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                promo['name'] ?? 'Code promo validé',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                              Text(
                                '-${DateFormatter.formatCurrency(discount)}',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _promoController.clearPromo();
                            _promoCodeController.clear();
                          },
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
              const SizedBox(height: 24),

              // Instructions spéciales
              _buildSectionTitle(context, 'Instructions spéciales'),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _specialInstructionsController,
                label: 'Instructions (optionnel)',
                hint: 'Ex: Sonner 2 fois, pas de sauce...',
                maxLines: 3,
                prefixIcon: const Icon(Icons.note),
              ),
              const SizedBox(height: 24),

              //  RÉSUMÉ DE COMMANDE AVEC RÉDUCTION
              _buildOrderSummary(context),
              const SizedBox(height: 24),

              // Bouton confirmer
              Obx(
                () => CustomButton(
                  text: 'Confirmer la commande',
                  onPressed: _orderController.isLoading.value
                      ? null
                      : _createOrder,
                  isLoading: _orderController.isLoading.value,
                  width: double.infinity,
                  icon: Icons.check_circle,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  //  RÉSUMÉ DE COMMANDE AMÉLIORÉ AVEC RÉDUCTION VISIBLE
  Widget _buildOrderSummary(BuildContext context) {
    return Obx(() {
      final cart = _cartController.cart.value;
      final discount = _promoController.discountAmount;
      final deliveryFee = _orderType == AppConstants.orderTypeDelivery
          ? cart.deliveryFee
          : 0.0;
      final subtotal = cart.calculatedSubtotal;
      final total = subtotal + deliveryFee - discount;

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Résumé de la commande',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              // Articles
              ...cart.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${item.dish?.name ?? 'Plat'} x${item.quantity}',
                        ),
                      ),
                      Text(
                        DateFormatter.formatCurrency(
                          item.unitPrice * item.quantity,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const Divider(),

              // Sous-total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Sous-total'),
                  Text(DateFormatter.formatCurrency(subtotal)),
                ],
              ),

              // Livraison
              if (deliveryFee > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Livraison'),
                      Text(DateFormatter.formatCurrency(deliveryFee)),
                    ],
                  ),
                ),

              //  RÉDUCTION (BIEN VISIBLE)
              if (discount > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Réduction',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '-${DateFormatter.formatCurrency(discount)}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

              const Divider(),

              //  TOTAL À PAYER (BIEN VISIBLE)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total à payer',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    DateFormatter.formatCurrency(total),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
