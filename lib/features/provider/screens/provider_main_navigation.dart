import 'package:flutter/material.dart';
import '../widgets/animated_badge.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:poafix/core/services/location_service.dart';
import 'package:poafix/core/models/location.dart' as app_location;
import 'provider_dashboard_screen.dart';
import 'service_list_screen.dart';
import 'booking_list_screen.dart';
import 'analytics_dashboard_screen.dart';

class ProviderMainNavigation extends StatefulWidget {
  final Widget child;
  const ProviderMainNavigation({super.key, required this.child});

  @override
  State<ProviderMainNavigation> createState() => _ProviderMainNavigationState();
}

class _ProviderMainNavigationState extends State<ProviderMainNavigation>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  int _selectedIndex = 0;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // Navigation handled by GoRouter

  final List<String> _titles = [
    'Dashboard',
    'Services',
    'Bookings',
    'Analytics',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _updateProviderLocation();
    super.dispose();
  }

  // Update provider location on app start and resume
  Future<void> _updateProviderLocation() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final locationService = LocationService();
      final position = await locationService.getCurrentLocation();
      await locationService.updateProviderLocation(
        user.uid,
        app_location.Location(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );
    } catch (e) {
      debugPrint('[ProviderLocation] Error updating location: $e');
      // Optionally show a snackbar or dialog
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _updateProviderLocation();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void deactivate() {
    WidgetsBinding.instance.removeObserver(this);
    super.deactivate();
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _controller.reset();
    _controller.forward();
  }

  Widget _buildAnimatedDestination(
    IconData icon,
    String label,
    int index, {
    int? notificationCount,
  }) {
    final isSelected = _selectedIndex == index;
    return NavigationDestination(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.all(isSelected ? 8.0 : 0),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).primaryColor.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: isSelected ? Theme.of(context).primaryColor : null,
            ),
          ),
          if (notificationCount != null && notificationCount > 0)
            Positioned(
              right: -8,
              top: -8,
              child: AnimatedNotificationBadge(
                count: notificationCount,
                child: const SizedBox(),
              ),
            ),
        ],
      ),
      label: label,
    );
  }

  Widget _getScreenForIndex(int index) {
    switch (index) {
      case 0:
        return ProviderDashboardScreen();
      case 1:
        return ServiceListScreen();
      case 2:
        return BookingListScreen();
      case 3:
        return AnalyticsDashboardScreen();
      default:
        return ProviderDashboardScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.3),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: Text(
            _titles[_selectedIndex],
            key: ValueKey(_titles[_selectedIndex]),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 35),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Service Provider',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Portfolio'),
              onTap: () {
                Navigator.pop(context);
                GoRouter.of(context).push('/providerHome/portfolio');
              },
            ),
            ListTile(
              leading: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.notifications),
                  Positioned(
                    right: -8,
                    top: -8,
                    child: AnimatedNotificationBadge(
                      count: 3,
                      child: const SizedBox(),
                    ),
                  ),
                ],
              ),
              title: const Text('Notifications'),
              onTap: () {
                Navigator.pop(context);
                GoRouter.of(context).push('/providerHome/notifications');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                GoRouter.of(context).push('/providerHome/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help & Support'),
              onTap: () {
                Navigator.pop(context);
                GoRouter.of(context).push('/providerHome/help');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Log Out'),
              onTap: () async {
                Navigator.pop(context);
                await FirebaseAuth.instance.signOut();
                GoRouter.of(context).go('/login');
              },
            ),
          ],
        ),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: _getScreenForIndex(_selectedIndex),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onDestinationSelected,
          animationDuration: const Duration(milliseconds: 400),
          destinations: [
            _buildAnimatedDestination(Icons.dashboard, 'Dashboard', 0),
            _buildAnimatedDestination(Icons.build, 'Services', 1),
            _buildAnimatedDestination(Icons.event, 'Bookings', 2),
            _buildAnimatedDestination(Icons.bar_chart, 'Analytics', 3),
          ],
        ),
      ),
    );
  }
}
