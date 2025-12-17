import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chelsy_restaurant/core/utils/validators.dart';
import 'package:chelsy_restaurant/presentation/controllers/profile_controller.dart';
import 'package:chelsy_restaurant/presentation/widgets/custom_button.dart';
import 'package:chelsy_restaurant/presentation/widgets/custom_text_field.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final ProfileController _profileController = Get.find<ProfileController>();
  String? _selectedGender;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final profile = _profileController.profile.value;
    if (profile != null) {
      _firstnameController.text = profile.firstname;
      _lastnameController.text = profile.lastname;
      _emailController.text = profile.email;
      _phoneController.text = profile.phone ?? '';
      _selectedGender = profile.gender;
      if (profile.birthDate != null) {
        _selectedDate = DateTime.parse(profile.birthDate!);
      }
    }
  }

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDate ??
          DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      final success = await _profileController.updateProfile(
        firstname: _firstnameController.text.trim(),
        lastname: _lastnameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        birthDate: _selectedDate != null
            ? '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}'
            : null,
        gender: _selectedGender,
      );

      if (success) {
        Get.snackbar(
          "Succès",
          "Profil mis à jour avec succès",
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
        await Future.delayed(const Duration(milliseconds: 500));
        Get.back();
      } else {
        Get.snackbar(
          "Erreur",
          "Impossible de mettre à jour le profil",
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modifier le profil')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextField(
                  controller: _firstnameController,
                  label: 'Prénom *',
                  hint: 'John',
                  prefixIcon: const Icon(Icons.person_outlined),
                  validator: (value) => Validators.required(value, 'Prénom'),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _lastnameController,
                  label: 'Nom *',
                  hint: 'Doe',
                  prefixIcon: const Icon(Icons.person_outlined),
                  validator: (value) => Validators.required(value, 'Nom'),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _emailController,
                  label: 'Email *',
                  hint: 'votre@email.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: Validators.email,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _phoneController,
                  label: 'Téléphone',
                  hint: '+229 12 34 56 78',
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                  validator: (value) =>
                      value?.isEmpty ?? true ? null : Validators.phone(value),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Date de naissance',
                      prefixIcon: const Icon(Icons.calendar_today_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _selectedDate != null
                          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                          : 'Sélectionner une date',
                      style: TextStyle(
                        color: _selectedDate != null
                            ? Colors.black
                            : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: InputDecoration(
                    labelText: 'Genre',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'male', child: Text('Homme')),
                    DropdownMenuItem(value: 'female', child: Text('Femme')),
                    DropdownMenuItem(value: 'other', child: Text('Autre')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                ),
                const SizedBox(height: 32),
                Obx(
                  () => CustomButton(
                    text: 'Enregistrer',
                    onPressed: _profileController.isLoading.value
                        ? null
                        : _handleSave,
                    isLoading: _profileController.isLoading.value,
                    icon: Icons.save,
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
