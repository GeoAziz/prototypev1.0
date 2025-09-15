import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:poafix/core/router/app_router.dart';
import 'package:poafix/core/theme/app_theme.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  runApp(
    Provider<FirebaseService>(
      create: (_) => FirebaseService(),
      child: const MyApp(),
    ),
  );
}

// Request location permission using geolocator
Future<void> _requestLocationPermission() async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  // Optionally handle other permission states
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final isLoggedIn = snapshot.hasData;
        return MaterialApp.router(
          title: 'poafix - Home Services',
          theme: AppTheme.lightTheme,
          routerConfig: AppRouter.router,
          debugShowCheckedModeBanner: false,
          // Redirect to /login if not logged in
          builder: (context, child) {
            if (!isLoggedIn) {
              Future.microtask(() => AppRouter.router.go('/login'));
            }
            return child!;
          },
        );
      },
    );
  }
}
