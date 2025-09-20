import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:poafix/core/router/app_router.dart';
import 'package:poafix/core/theme/app_theme.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:poafix/features/provider/screens/provider_main_navigation.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:poafix/core/services/firebase_service.dart';
import 'package:poafix/core/services/auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:poafix/core/services/direct_payment_service.dart';
import 'package:poafix/features/notifications/services/notification_service.dart';
// import 'package:poafix/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Request location permission at startup
  await _requestLocationPermission();
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Error loading .env file: $e');
    // Provide default values or handle the error accordingly
  }

  await Firebase.initializeApp();

  // Initialize App Check
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );

  await AuthService.init(); // Initialize auth service
  DirectPaymentService.init();

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();

  // This is a workaround for the MissingPluginException when using path_provider
  // on platforms that don't support it (like web)
  if (!kIsWeb) {
    try {
      await getTemporaryDirectory();
    } catch (e) {
      debugPrint('Error initializing path_provider: $e');
    }
  }

  runApp(const AuthGate());
}

// Request location permission using geolocator
Future<void> _requestLocationPermission() async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  // Optionally handle other permission states
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _loading = true;
  User? _user;
  String? _role;
  String? _targetRoute;

  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _loading = true;
      _user = user;
      _role = null;
      _targetRoute = null;
    });

    if (user == null) {
      setState(() {
        _role = null;
        _loading = false;
        _targetRoute = '/login';
      });
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final role = doc.data()?['role']?.toString();
    setState(() {
      _role = role;
      _loading = false;
      if (role == 'UserRole.provider' || role == 'provider') {
        _targetRoute = '/providerHome';
      } else {
        _targetRoute = '/';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return MaterialApp(
        title: 'poafix - Home Services',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/poafix_logo.jpg',
                  width: 160,
                  height: 160,
                  fit: BoxFit.contain,
                  semanticLabel: 'Poafix Logo',
                ),
                const SizedBox(height: 32),
                const CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      );
    }

    // Route based on _targetRoute
    return MaterialApp.router(
      title: 'poafix - Home Services',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
      // Use route information to control initial screen
      // If using go_router, set initialLocation
      // If not, handle with your router setup
    );
  }
}
