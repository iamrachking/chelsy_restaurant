import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chelsy_restaurant/core/routes/app_routes.dart';
import 'package:chelsy_restaurant/presentation/controllers/auth_controller.dart';
import 'package:chelsy_restaurant/presentation/controllers/profile_controller.dart';
import 'package:chelsy_restaurant/presentation/widgets/loading_widget.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final ProfileController profileController = Get.find<ProfileController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Obx(() {
        final user =
            authController.currentUser.value ?? profileController.profile.value;
        if (user == null) {
          return const LoadingWidget();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            backgroundImage:
                                user.avatar != null && user.avatar!.isNotEmpty
                                ? CachedNetworkImageProvider(user.avatar!)
                                : null,
                            child: user.avatar == null || user.avatar!.isEmpty
                                ? Text(
                                    user.name.substring(0, 1).toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 40,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.camera_alt,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                onPressed: () => _pickImage(context),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Menu items
              _buildMenuItem(
                context,
                icon: Icons.person_outline,
                title: 'Informations personnelles',
                onTap: () {
                  Get.toNamed(AppRoutes.editProfile);
                },
              ),
              _buildMenuItem(
                context,
                icon: Icons.location_on_outlined,
                title: 'Mes adresses',
                onTap: () {
                  Get.toNamed(AppRoutes.addresses);
                },
              ),
              _buildMenuItem(
                context,
                icon: Icons.restaurant_outlined,
                title: 'À propos du restaurant',
                onTap: () {
                  Get.toNamed(AppRoutes.restaurantInfo);
                },
              ),
              _buildMenuItem(
                context,
                icon: Icons.shopping_bag_outlined,
                title: 'Mes commandes',
                onTap: () {
                  Get.toNamed(AppRoutes.orders);
                },
              ),
              _buildMenuItem(
                context,
                icon: Icons.favorite_outline,
                title: 'Mes favoris',
                onTap: () {
                  Get.toNamed(AppRoutes.favorites);
                },
              ),
              _buildMenuItem(
                context,
                icon: Icons.help_outline,
                title: 'FAQ',
                onTap: () {
                  Get.toNamed(AppRoutes.faq);
                },
              ),
              _buildMenuItem(
                context,
                icon: Icons.report_problem_outlined,
                title: 'Mes réclamations',
                onTap: () {
                  Get.toNamed(AppRoutes.complaints);
                },
              ),
              _buildMenuItem(
                context,
                icon: Icons.lock_outline,
                title: 'Changer le mot de passe',
                onTap: () {
                  Get.toNamed(AppRoutes.changePassword);
                },
              ),
              const Divider(),
              _buildMenuItem(
                context,
                icon: Icons.logout,
                title: 'Déconnexion',
                textColor: Colors.red,
                onTap: () {
                  Get.dialog(
                    AlertDialog(
                      title: const Text('Déconnexion'),
                      content: const Text(
                        'Êtes-vous sûr de vouloir vous déconnecter ?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('Annuler'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Get.back();
                            await authController.logout();
                            Get.offAllNamed(AppRoutes.login);
                          },
                          child: const Text('Déconnexion'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      }),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final ProfileController profileController = Get.find<ProfileController>();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Prendre une photo'),
              onTap: () async {
                Get.back();
                final XFile? image = await picker.pickImage(
                  source: ImageSource.camera,
                );
                if (image != null) {
                  await profileController.updateProfilePicture(image.path);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choisir depuis la galerie'),
              onTap: () async {
                Get.back();
                final XFile? image = await picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (image != null) {
                  await profileController.updateProfilePicture(image.path);
                }
              },
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: textColor),
        title: Text(title, style: TextStyle(color: textColor)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
