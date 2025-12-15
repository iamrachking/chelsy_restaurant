import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chelsy_restaurant/core/utils/validators.dart';
import 'package:chelsy_restaurant/presentation/controllers/address_controller.dart';
import 'package:chelsy_restaurant/presentation/widgets/custom_button.dart';
import 'package:chelsy_restaurant/presentation/widgets/custom_text_field.dart';
import 'package:chelsy_restaurant/data/models/address_model.dart';

class AddAddressPage extends StatefulWidget {
  final AddressModel? address;

  const AddAddressPage({super.key, this.address});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final _formKey = GlobalKey<FormState>();

  final _labelController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController();
  final _additionalInfoController = TextEditingController();

  final AddressController _addressController = Get.find<AddressController>();

  bool _isDefault = false;
  double _latitude = 6.372477;
  double _longitude = 2.354006;

  @override
  void initState() {
    super.initState();

    final address = widget.address;
    if (address != null) {
      _labelController.text = address.label;
      _streetController.text = address.street;
      _cityController.text = address.city;
      _postalCodeController.text = address.postalCode ?? '';
      _countryController.text = address.country;
      _additionalInfoController.text = address.additionalInfo ?? '';
      _isDefault = address.isDefault;
      _latitude = address.latitude;
      _longitude = address.longitude;
    } else {
      _countryController.text = 'Bénin';
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final address = AddressModel(
      id: widget.address?.id ?? 0,
      userId: widget.address?.userId ?? 0,
      label: _labelController.text.trim(),
      street: _streetController.text.trim(),
      city: _cityController.text.trim(),
      postalCode: _postalCodeController.text.trim().isEmpty
          ? null
          : _postalCodeController.text.trim(),
      country: _countryController.text.trim(),
      latitude: _latitude,
      longitude: _longitude,
      additionalInfo: _additionalInfoController.text.trim().isEmpty
          ? null
          : _additionalInfoController.text.trim(),
      isDefault: _isDefault,
      createdAt: widget.address?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final bool success = widget.address == null
        ? await _addressController.createAddress(address)
        : await _addressController.updateAddress(widget.address!.id, address);

    if (success) {
      Get.back(result: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.address != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Modifier l\'adresse' : 'Ajouter une adresse'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextField(
                  controller: _labelController,
                  label: 'Libellé *',
                  hint: 'Ex: Maison, Bureau',
                  prefixIcon: const Icon(Icons.label_outlined),
                  validator: (value) => Validators.required(value, 'Libellé'),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _streetController,
                  label: 'Rue *',
                  hint: '123 Rue de la Paix',
                  prefixIcon: const Icon(Icons.home_outlined),
                  validator: (value) => Validators.required(value, 'Rue'),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _cityController,
                  label: 'Ville *',
                  hint: 'Cotonou',
                  prefixIcon: const Icon(Icons.location_city_outlined),
                  validator: (value) => Validators.required(value, 'Ville'),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _postalCodeController,
                  label: 'Code postal',
                  hint: '01BP1234',
                  prefixIcon: const Icon(Icons.markunread_mailbox_outlined),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _countryController,
                  label: 'Pays *',
                  hint: 'Bénin',
                  prefixIcon: const Icon(Icons.public_outlined),
                  validator: (value) => Validators.required(value, 'Pays'),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _additionalInfoController,
                  label: 'Informations complémentaires',
                  hint: 'Ex: Près du marché',
                  maxLines: 3,
                  prefixIcon: const Icon(Icons.info_outlined),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Adresse par défaut'),
                  value: _isDefault,
                  onChanged: (value) {
                    setState(() {
                      _isDefault = value ?? false;
                    });
                  },
                ),
                const SizedBox(height: 24),
                Obx(
                  () => CustomButton(
                    text: isEdit ? 'Modifier' : 'Ajouter',
                    icon: isEdit ? Icons.save : Icons.add,
                    isLoading: _addressController.isLoading.value,
                    onPressed: _addressController.isLoading.value
                        ? null
                        : _handleSave,
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
