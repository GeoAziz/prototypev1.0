import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:poafix/core/services/location_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:poafix/core/models/location.dart' as app_location;
import 'package:geolocator/geolocator.dart';

class SettingsScreen extends StatelessWidget {
  Future<void> _showLocationSettings(
    BuildContext context,
    Map<String, dynamic> data,
    DocumentReference settingsDoc,
  ) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              secondary: const Icon(Icons.location_searching),
              title: const Text('Background Location Updates'),
              subtitle: const Text(
                'Automatically update location while the app is running',
              ),
              value: data['backgroundLocationEnabled'] ?? false,
              onChanged: (bool value) async {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) return;

                try {
                  final locationService = LocationService();
                  if (value) {
                    final success = await locationService
                        .startBackgroundLocationUpdates(user.uid);
                    if (success) {
                      await settingsDoc.update({
                        'backgroundLocationEnabled': true,
                      });
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Background location updates enabled',
                            ),
                          ),
                        );
                      }
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Failed to enable background location updates',
                            ),
                          ),
                        );
                      }
                    }
                  } else {
                    locationService.stopBackgroundLocationUpdates(user.uid);
                    await settingsDoc.update({
                      'backgroundLocationEnabled': false,
                    });
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Background location updates disabled'),
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.my_location),
              title: const Text('Update My Location'),
              subtitle: const Text(
                'Refresh your current location in the system.',
              ),
              onTap: () => _updateCurrentLocation(context),
            ),
            ListTile(
              leading: const Icon(Icons.edit_location_alt),
              title: const Text('Set Location by Address'),
              subtitle: const Text('Enter your address to update location.'),
              onTap: () => _showAddressUpdateDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddressUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final addressController = TextEditingController();
        return AlertDialog(
          title: const Text('Enter Address'),
          content: TextField(
            controller: addressController,
            decoration: const InputDecoration(hintText: 'e.g. Nairobi, Kenya'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final address = addressController.text.trim();
                if (address.isEmpty) return;
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) return;

                try {
                  final List<Location> locations = await locationFromAddress(
                    address,
                  );
                  if (locations.isEmpty) {
                    throw Exception('No location found for this address');
                  }

                  final location = locations.first;
                  final locationService = LocationService();
                  await locationService.updateProviderLocation(
                    user.uid,
                    app_location.Location(
                      latitude: location.latitude,
                      longitude: location.longitude,
                    ),
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Location updated for address!'),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update location: $e')),
                    );
                  }
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<DocumentReference> _getSettingsDoc() async {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    if (uid == null) throw Exception('Not logged in');
    final doc = FirebaseFirestore.instance
        .collection('provider_settings')
        .doc(uid);
    // Create doc if not exists
    final snapshot = await doc.get();
    if (!snapshot.exists) {
      await doc.set({
        'pushNotifications': true,
        'emailNotifications': false,
        'smsNotifications': false,
        'language': 'English',
        'privacyEnabled': true,
        'backgroundLocationEnabled': false,
      });
    }
    return doc;
  }

  const SettingsScreen({super.key});

  Future<LocationPermission> _showLocationPermissionDialog(
    BuildContext context,
  ) async {
    final bool shouldRequest =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Location Permission Required'),
            content: const Text(
              'We need your location permission to update your position in the system. '
              'This helps customers find service providers near them. '
              'Your location will only be used when you are active as a service provider.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Deny'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Allow'),
              ),
            ],
          ),
        ) ??
        false;

    if (shouldRequest) {
      return await Geolocator.requestPermission();
    }
    return LocationPermission.denied;
  }

  Future<void> _updateCurrentLocation(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to update your location'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Show loading dialog
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Updating location...'),
                ],
              ),
            ),
          ),
        ),
      );
    }

    try {
      final locationService = LocationService();

      // First check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (context.mounted) {
          Navigator.pop(context); // Dismiss loading
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Location Services Disabled'),
              content: const Text(
                'Location services are disabled. Please enable location services in your device settings to update your location.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await Geolocator.openLocationSettings();
                  },
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          );
        }
        return;
      }

      // Check and request permission if needed
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        if (context.mounted) {
          Navigator.pop(context); // Dismiss loading
          permission = await _showLocationPermissionDialog(context);
          if (permission == LocationPermission.denied) {
            return;
          }
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (context.mounted) {
          Navigator.pop(context); // Dismiss loading
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Location Permission Required'),
              content: const Text(
                'Location permission is permanently denied. Please enable it in your device settings.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await Geolocator.openAppSettings();
                  },
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          );
        }
        return;
      }

      // Get and update location
      final position = await locationService.getCurrentLocation();
      await locationService.updateProviderLocation(
        user.uid,
        app_location.Location(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );

      if (context.mounted) {
        Navigator.pop(context); // Dismiss loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                const Text('Location updated successfully!'),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                  child: const Text(
                    'DISMISS',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Dismiss loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Failed to update location: ${e.toString()}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 6),
            action: SnackBarAction(
              label: 'RETRY',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                // Retry the operation
                _updateCurrentLocation(context);
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: FutureBuilder<DocumentReference>(
        future: _getSettingsDoc(),
        builder: (context, settingsSnapshot) {
          if (settingsSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (settingsSnapshot.hasError) {
            return Center(
              child: Text('Error loading settings: ${settingsSnapshot.error}'),
            );
          }
          final settingsDoc = settingsSnapshot.data!;
          return StreamBuilder<DocumentSnapshot>(
            stream: settingsDoc.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error loading settings: ${snapshot.error}'),
                );
              }
              final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: ListView(
                  key: const ValueKey('settings-list'),
                  children: [
                    _AnimatedSettingsTile(
                      icon: Icons.notifications,
                      title: 'Notification Preferences',
                      subtitle: 'Push, Email, SMS',
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                          ),
                          builder: (context) => Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SwitchListTile(
                                  title: const Text('Push Notifications'),
                                  value: data['pushNotifications'] ?? true,
                                  onChanged: (val) {
                                    settingsDoc.update({
                                      'pushNotifications': val,
                                    });
                                  },
                                ),
                                SwitchListTile(
                                  title: const Text('Email Notifications'),
                                  value: data['emailNotifications'] ?? false,
                                  onChanged: (val) {
                                    settingsDoc.update({
                                      'emailNotifications': val,
                                    });
                                  },
                                ),
                                SwitchListTile(
                                  title: const Text('SMS Notifications'),
                                  value: data['smsNotifications'] ?? false,
                                  onChanged: (val) {
                                    settingsDoc.update({
                                      'smsNotifications': val,
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    _AnimatedSettingsTile(
                      icon: Icons.location_on,
                      title: 'Location Settings',
                      subtitle: 'Update your current location',
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () =>
                          _showLocationSettings(context, data, settingsDoc),
                    ),
                    _AnimatedSettingsTile(
                      icon: Icons.lock,
                      title: 'Privacy & Security',
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Privacy & Security'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Semantics(
                                  label: 'Privacy Enabled',
                                  child: SwitchListTile(
                                    title: const Text('Enable Privacy'),
                                    value: data['privacyEnabled'] ?? true,
                                    onChanged: (val) {
                                      settingsDoc.update({
                                        'privacyEnabled': val,
                                      });
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Manage your privacy and security settings.',
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    _AnimatedSettingsTile(
                      icon: Icons.language,
                      title: 'Language',
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                          ),
                          builder: (context) => Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Semantics(
                                  label: 'Select Language',
                                  child: Text(
                                    'Select Language',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ListTile(
                                  title: const Text('English'),
                                  trailing: Icon(
                                    Icons.check,
                                    color:
                                        (data['language'] ?? 'English') ==
                                            'English'
                                        ? Colors.blue
                                        : Colors.transparent,
                                  ),
                                  onTap: () {
                                    settingsDoc.update({'language': 'English'});
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  title: const Text('Swahili'),
                                  trailing: Icon(
                                    Icons.check,
                                    color:
                                        (data['language'] ?? 'English') ==
                                            'Swahili'
                                        ? Colors.blue
                                        : Colors.transparent,
                                  ),
                                  onTap: () {
                                    settingsDoc.update({'language': 'Swahili'});
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    _AnimatedSettingsTile(
                      icon: Icons.logout,
                      title: 'Logout',
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Logout'),
                            content: const Text(
                              'Are you sure you want to logout?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Logout'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await FirebaseAuth.instance.signOut();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Logged out successfully.'),
                              ),
                            );
                            // Navigate to login screen
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/login',
                              (route) => false,
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _AnimatedSettingsTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;
  const _AnimatedSettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  State<_AnimatedSettingsTile> createState() => _AnimatedSettingsTileState();
}

class _AnimatedSettingsTileState extends State<_AnimatedSettingsTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()..scale(_pressed ? 0.97 : 1.0),
        child: ListTile(
          leading: Icon(widget.icon, color: Colors.blue),
          title: Text(
            widget.title,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: widget.subtitle != null ? Text(widget.subtitle!) : null,
          trailing: widget.trailing,
        ),
      ),
    );
  }
}
