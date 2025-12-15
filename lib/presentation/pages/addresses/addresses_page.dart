import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chelsy_restaurant/core/routes/app_routes.dart';
import 'package:chelsy_restaurant/presentation/controllers/address_controller.dart';
import 'package:chelsy_restaurant/presentation/widgets/loading_widget.dart';
import 'package:chelsy_restaurant/presentation/widgets/empty_state_widget.dart';

class AddressesPage extends StatelessWidget {
  const AddressesPage({super.key});

  Future<void> _openAddAddress(
    AddressController controller, {
    Object? address,
  }) async {
    final result = await Get.toNamed(AppRoutes.addAddress, arguments: address);

    if (result == true) {
      await controller.loadAddresses();

      Get.snackbar(
        'Succès',
        address != null
            ? 'Adresse modifiée avec succès'
            : 'Adresse ajoutée avec succès',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AddressController addressController = Get.find<AddressController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Mes adresses')),
      body: Obx(() {
        if (addressController.isLoading.value &&
            addressController.addresses.isEmpty) {
          return const LoadingWidget();
        }

        if (addressController.addresses.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.location_on_outlined,
            title: 'Aucune adresse',
            message: 'Ajoutez une adresse pour recevoir vos commandes',
            buttonText: 'Ajouter une adresse',
            onButtonTap: () => _openAddAddress(addressController),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: addressController.addresses.length,
          itemBuilder: (context, index) {
            final address = addressController.addresses[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Icon(
                  Icons.location_on,
                  color: address.isDefault
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                title: Text(address.label),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(address.fullAddress),
                    if (address.isDefault) ...[
                      const SizedBox(height: 4),
                      Chip(
                        label: const Text('Adresse par défaut'),
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.2),
                        padding: EdgeInsets.zero,
                        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!address.isDefault)
                      IconButton(
                        icon: const Icon(Icons.star_border),
                        tooltip: 'Définir par défaut',
                        color: Theme.of(context).colorScheme.primary,
                        onPressed: () async {
                          await addressController.setDefaultAddress(address.id);
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: 'Modifier',
                      onPressed: () =>
                          _openAddAddress(addressController, address: address),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Supprimer',
                      color: Colors.red,
                      onPressed: () async {
                        final confirm = await Get.dialog<bool>(
                          AlertDialog(
                            title: const Text('Supprimer l\'adresse'),
                            content: const Text(
                              'Êtes-vous sûr de vouloir supprimer cette adresse ?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(result: false),
                                child: const Text('Annuler'),
                              ),
                              TextButton(
                                onPressed: () => Get.back(result: true),
                                child: const Text(
                                  'Supprimer',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await addressController.deleteAddress(address.id);
                        }
                      },
                    ),
                  ],
                ),
                onTap: () =>
                    _openAddAddress(addressController, address: address),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddAddress(addressController),
        child: const Icon(Icons.add),
      ),
    );
  }
}
