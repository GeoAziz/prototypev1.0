import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poafix/core/theme/app_colors.dart';
import 'package:poafix/core/theme/app_text_styles.dart';
import 'package:poafix/core/utils/image_helper.dart';
import 'package:poafix/core/widgets/app_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () {
              context.push('/settings');
            },
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: user != null
            ? FirebaseFirestore.instance.collection('users').doc(user.uid).get()
            : null,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading profile'));
          }
          final data = snapshot.data?.data();
          final bio = data?['bio'] ?? '';
          final phone = data?['phone'] ?? '';
          final address = data?['address'] ?? '';
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.lightGrey,
                    child: ClipOval(
                      child:
                          user?.photoURL != null && user!.photoURL!.isNotEmpty
                          ? ImageHelper.loadNetworkImage(
                              imageUrl: user.photoURL!,
                              fit: BoxFit.cover,
                              width: 100,
                              height: 100,
                              errorWidget: const Icon(Icons.person, size: 50),
                            )
                          : const Icon(Icons.person, size: 50),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.displayName ?? 'No Name',
                    style: AppTextStyles.headline2,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'No Email',
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (bio.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(bio, style: AppTextStyles.body2),
                  ],
                  if (phone.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.phone,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(phone, style: AppTextStyles.body2),
                      ],
                    ),
                  ],
                  if (address.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(address, style: AppTextStyles.body2),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  AppButton(
                    text: 'Edit Profile',
                    onPressed: () {
                      context.push('/profile-setup');
                    },
                    isFullWidth: false,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    textColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildMenuItem(
                icon: Icons.location_on_outlined,
                title: 'Address Management',
                onTap: () {
                  context.push('/addresses');
                },
              ),
              _buildMenuItem(
                icon: Icons.payment_outlined,
                title: 'Payment Methods',
                onTap: () {
                  context.push('/payment-methods');
                },
              ),
              _buildMenuItem(
                icon: Icons.support_agent_outlined,
                title: 'Support',
                onTap: () {
                  context.push('/help-support');
                },
              ),
              _buildMenuItem(
                icon: Icons.info_outline,
                title: 'About Us',
                onTap: () {
                  context.push('/about');
                },
              ),
              const SizedBox(height: 16),
              AppOutlinedButton(
                text: 'Logout',
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Confirm Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await FirebaseAuth.instance.signOut();
                    context.go('/login');
                  }
                },
                borderColor: AppColors.error,
                textColor: AppColors.error,
                prefixIcon: Icons.logout,
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary),
      title: Text(title, style: AppTextStyles.body1),
      trailing: const Icon(Icons.chevron_right, color: AppColors.grey),
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
    );
  }
}
