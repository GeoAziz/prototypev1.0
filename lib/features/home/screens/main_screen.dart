import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poafix/core/models/notification_model.dart';
import 'package:poafix/core/services/notification_service.dart';
import 'package:poafix/core/theme/app_icons.dart';

class MainScreen extends StatefulWidget {
  final Widget child;

  const MainScreen({super.key, required this.child});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateIndexBasedOnLocation();
  }

  void _updateIndexBasedOnLocation() {
    final location = GoRouterState.of(context).matchedLocation;
    if (location == '/') {
      _currentIndex = 0;
    } else if (location == '/map') {
      _currentIndex = 1;
    } else if (location == '/services') {
      _currentIndex = 2;
    } else if (location == '/bookings') {
      _currentIndex = 3;
    } else if (location == '/profile') {
      _currentIndex = 4;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Poafix'),
        actions: [
          StreamBuilder<List<NotificationModel>>(
            stream: NotificationService().notificationsStream,
            builder: (context, snapshot) {
              final unreadCount =
                  snapshot.data?.where((n) => !n.isRead).length ?? 0;

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () => context.push('/notifications'),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });

          if (index == 0) {
            context.go('/');
          } else if (index == 1) {
            context.go('/map');
          } else if (index == 2) {
            context.go('/services');
          } else if (index == 3) {
            context.go('/bookings');
          } else if (index == 4) {
            context.go('/profile');
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(poafixIcons.homeOutline),
            selectedIcon: Icon(poafixIcons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.home_repair_service_outlined),
            selectedIcon: Icon(Icons.home_repair_service),
            label: 'Services',
          ),
          NavigationDestination(
            icon: Icon(poafixIcons.bookingOutline),
            selectedIcon: Icon(poafixIcons.booking),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: Icon(poafixIcons.profileOutline),
            selectedIcon: Icon(poafixIcons.profile),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
