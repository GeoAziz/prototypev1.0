import 'package:flutter/material.dart';
import 'package:poafix/core/theme/app_colors.dart';
import 'package:poafix/core/theme/app_text_styles.dart';
import 'package:poafix/core/widgets/app_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  bool locationEnabled = true;
  ThemeMode themeMode = ThemeMode.system;
  String selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Account Settings'),
          _buildSettingItem(
            icon: Icons.person_outline,
            title: 'Personal Information',
            onTap: () {
              // Navigate to personal info screen
            },
          ),
          _buildSettingItem(
            icon: Icons.password_outlined,
            title: 'Change Password',
            onTap: () {
              // Navigate to change password screen
            },
          ),
          _buildSettingItem(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Settings',
            onTap: () {
              // Navigate to privacy settings screen
            },
          ),

          const SizedBox(height: 24),
          _buildSectionHeader('App Settings'),

          // Notifications toggle
          SwitchListTile(
            value: notificationsEnabled,
            onChanged: (value) {
              setState(() {
                notificationsEnabled = value;
              });
            },
            title: const Text('Push Notifications', style: AppTextStyles.body1),
            secondary: const Icon(
              Icons.notifications_outlined,
              color: AppColors.primary,
            ),
            contentPadding: EdgeInsets.zero,
          ),

          // Location services toggle
          SwitchListTile(
            value: locationEnabled,
            onChanged: (value) {
              setState(() {
                locationEnabled = value;
              });
            },
            title: const Text('Location Services', style: AppTextStyles.body1),
            secondary: const Icon(
              Icons.location_on_outlined,
              color: AppColors.primary,
            ),
            contentPadding: EdgeInsets.zero,
          ),

          // Theme selection
          ListTile(
            leading: const Icon(
              Icons.brightness_4_outlined,
              color: AppColors.primary,
            ),
            title: const Text('Theme Mode', style: AppTextStyles.body1),
            contentPadding: EdgeInsets.zero,
            trailing: DropdownButton<ThemeMode>(
              value: themeMode,
              underline: const SizedBox(),
              onChanged: (ThemeMode? newValue) {
                if (newValue != null) {
                  setState(() {
                    themeMode = newValue;
                  });
                }
              },
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('System Default'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text('Light Mode'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text('Dark Mode'),
                ),
              ],
            ),
          ),

          // Language selection
          ListTile(
            leading: const Icon(
              Icons.language_outlined,
              color: AppColors.primary,
            ),
            title: const Text('Language', style: AppTextStyles.body1),
            contentPadding: EdgeInsets.zero,
            trailing: DropdownButton<String>(
              value: selectedLanguage,
              underline: const SizedBox(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedLanguage = newValue;
                  });
                }
              },
              items: const [
                DropdownMenuItem(value: 'English', child: Text('English')),
                DropdownMenuItem(value: 'Persian', child: Text('Persian')),
                DropdownMenuItem(value: 'Arabic', child: Text('Arabic')),
              ],
            ),
          ),

          const SizedBox(height: 24),
          _buildSectionHeader('Other Settings'),

          _buildSettingItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {
              // Navigate to help screen
            },
          ),
          _buildSettingItem(
            icon: Icons.info_outline,
            title: 'About',
            onTap: () {
              // Navigate to about screen
            },
          ),
          _buildSettingItem(
            icon: Icons.star_outline,
            title: 'Rate the App',
            onTap: () {
              // Open rate dialog
            },
          ),

          const SizedBox(height: 32),
          AppButton(
            text: 'Clear App Cache',
            onPressed: () {
              // Show confirmation dialog for clearing cache
              _showClearCacheDialog();
            },
            backgroundColor: AppColors.lightGrey,
            textColor: AppColors.textPrimary,
          ),

          const SizedBox(height: 16),
          AppButton(
            text: 'Delete My Account',
            onPressed: () {
              // Show confirmation dialog for account deletion
              _showDeleteAccountDialog();
            },
            backgroundColor: AppColors.error.withOpacity(0.1),
            textColor: AppColors.error,
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: AppTextStyles.headline3.copyWith(color: AppColors.primary),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    String? subtitle,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.body1),
      subtitle: subtitle != null
          ? Text(subtitle, style: AppTextStyles.body2)
          : null,
      trailing: const Icon(Icons.chevron_right, color: AppColors.grey),
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Cache'),
          content: const Text(
            'Are you sure you want to clear the app cache? This will not affect your account data.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Clear cache logic here
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cache cleared successfully')),
                );
              },
              child: Text('Clear', style: TextStyle(color: AppColors.error)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Delete account logic here
                Navigator.of(context).pop();
                // Navigate to login screen after account deletion
              },
              child: Text('Delete', style: TextStyle(color: AppColors.error)),
            ),
          ],
        );
      },
    );
  }
}
