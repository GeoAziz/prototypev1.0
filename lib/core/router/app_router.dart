import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:poafix/features/provider/screens/provider_main_navigation.dart';
import 'package:poafix/features/provider/screens/portfolio_screen.dart';
import 'package:poafix/features/provider/screens/provider_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poafix/features/auth/screens/login_screen.dart';
import 'package:poafix/features/auth/screens/register_screen.dart';
import 'package:poafix/features/auth/screens/splash_screen.dart';
import 'package:poafix/features/auth/screens/welcome_slides_screen.dart';
import 'package:poafix/features/auth/screens/forgot_password_screen.dart';
import 'package:poafix/features/auth/screens/otp_verification_screen.dart';
import 'package:poafix/features/auth/screens/profile_setup_screen.dart';
import 'package:poafix/features/search/screens/search_screen.dart';
import 'package:poafix/features/booking/screens/booking_screen.dart';
import 'package:poafix/features/booking/screens/booking_success_screen.dart';
import 'package:poafix/features/booking/screens/booking_payment_screen.dart';
import 'package:poafix/features/payment/screens/payment_methods_screen.dart';
import 'package:poafix/features/payment/screens/payment_processing_screen.dart';
import 'package:poafix/features/payment/screens/payment_success_screen.dart';
import 'package:poafix/features/booking/screens/booking_history_screen.dart';
import 'package:poafix/features/booking/screens/cancel_reschedule_screen.dart';
import 'package:poafix/features/home/screens/home_screen.dart';
import 'package:poafix/features/home/screens/main_screen.dart';
import 'package:poafix/features/notifications/screens/notifications_screen.dart';
import 'package:poafix/features/notifications/screens/notifications_center_screen.dart';
import 'package:poafix/features/favorites/screens/favorites_screen.dart';
import 'package:poafix/features/help/screens/help_support_screen.dart';
import 'package:poafix/features/chat/screens/chat_messages_screen.dart';
import 'package:poafix/features/profile/screens/profile_screen.dart';
import 'package:poafix/features/service_category/screens/service_category_screen.dart';
import 'package:poafix/features/service_details/screens/service_details_screen.dart';
import 'package:poafix/features/service_details/screens/price_comparison_screen.dart';
import 'package:poafix/features/service_provider/screens/service_provider_list_screen.dart';
import 'package:poafix/features/settings/screens/settings_screen.dart';
import 'package:poafix/features/service_reviews/screens/service_reviews_screen.dart';
import 'package:poafix/features/service_provider/screens/service_provider_screen.dart';
import 'package:poafix/features/address/screens/address_management_screen.dart';
import 'package:poafix/features/about/screens/about_screen.dart';
import 'package:poafix/features/offers/screens/offers_screen.dart';
import 'package:poafix/features/quick_service/screens/quick_service_screen.dart';
import 'package:poafix/features/membership/screens/membership_screen.dart';
import 'package:poafix/features/categories/screens/all_categories_screen.dart';
import 'package:poafix/features/featured_services/screens/featured_services_screen.dart';
import 'package:poafix/features/popular_services/screens/popular_services_screen.dart';
import 'package:poafix/features/auth/screens/auth_screen.dart';
import 'package:poafix/features/provider/provider_screen.dart';
import 'package:poafix/features/provider/screens/service_edit_screen.dart';
import 'package:poafix/features/provider/screens/service_list_screen.dart';
import 'package:poafix/features/service_category/screens/sub_service_list_screen.dart';
import 'package:poafix/features/provider/screens/provider_selection_screen.dart';
import 'package:poafix/features/service_comparison/screens/service_comparison_screen.dart';
import 'package:poafix/features/smart_filtering/screens/smart_filtering_screen.dart';
import 'package:poafix/features/smart_filtering/models/filter_criteria.dart';
import 'package:poafix/features/map/screens/map_screen.dart';
import 'package:poafix/features/services/screens/services_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'shell',
);

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    navigatorKey: _rootNavigatorKey,
    redirect: (context, state) async {
      final user = FirebaseAuth.instance.currentUser;
      final allowedUnauthRoutes = ['/login', '/register', '/forgot-password'];
      final isAllowedUnauth = allowedUnauthRoutes.contains(
        state.matchedLocation,
      );

      if (user == null) {
        // Allow unauthenticated access to login, register, forgot-password
        return isAllowedUnauth ? null : '/login';
      }

      // If logged in and on login/register/forgot-password, redirect to correct home based on role
      if (isAllowedUnauth) {
        // Fetch user role from Firestore
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final role = doc.data()?['role']?.toString();
        if (role == 'UserRole.provider' || role == 'provider') {
          return '/providerHome';
        } else {
          return '/';
        }
      }

      // If on root '/', redirect to providerHome if provider
      if (state.matchedLocation == '/') {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final role = doc.data()?['role']?.toString();
        if (role == 'UserRole.provider' || role == 'provider') {
          return '/providerHome';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/providerHome',
        name: 'providerHome',
        builder: (context, state) =>
            ProviderMainNavigation(child: ProviderDashboardScreen()),
        routes: [
          GoRoute(
            path: 'portfolio',
            name: 'providerPortfolio',
            builder: (context, state) => PortfolioScreen(),
          ),
          GoRoute(
            path: 'services',
            builder: (context, state) => const ServiceListScreen(),
          ),
          GoRoute(
            path: 'service/edit/:serviceId',
            name: 'editService',
            builder: (context, state) {
              final serviceId = state.pathParameters['serviceId'];
              return ServiceEditScreen(serviceId: serviceId);
            },
          ),
          GoRoute(
            path: 'service/add',
            name: 'addService',
            builder: (context, state) => const ServiceEditScreen(),
          ),
          GoRoute(
            path: 'settings',
            name: 'providerSettings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: 'notifications',
            name: 'providerNotifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: 'help',
            name: 'providerHelp',
            builder: (context, state) => HelpSupportScreen(),
          ),
        ],
      ),
      // Auth routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        name: 'welcomeSlides',
        builder: (context, state) => WelcomeSlidesScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgotPassword',
        builder: (context, state) => ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/otp-verification',
        name: 'otpVerification',
        builder: (context, state) => OtpVerificationScreen(),
      ),
      GoRoute(
        path: '/profile-setup',
        name: 'profileSetup',
        builder: (context, state) => ProfileSetupScreen(),
      ),
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
        routes: [
          GoRoute(
            path: 'booking-payment',
            name: 'bookingPayment',
            pageBuilder: (context, state) {
              final args = state.extra as Map<String, dynamic>? ?? {};
              final amount = args['amount'];
              final double parsedAmount = (amount is num)
                  ? amount.toDouble()
                  : amount is String
                  ? double.tryParse(amount) ?? 0.0
                  : 0.0;
              return CustomTransitionPage<void>(
                key: state.pageKey,
                child: BookingPaymentScreen(
                  serviceId: args['serviceId'] as String? ?? '',
                  serviceTitle: args['serviceTitle'] as String? ?? '',
                  amount: parsedAmount,
                ),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
              );
            },
          ),
        ],
      ),
      // Provider list by category
      GoRoute(
        path: '/providers-list/:categoryId',
        name: 'providersList',
        builder: (context, state) {
          final categoryId = state.pathParameters['categoryId'] as String;
          return ProviderScreen(categoryId: categoryId);
        },
      ),

      // Main shell route with bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainScreen(child: child);
        },
        routes: [
          // Home tab
          GoRoute(
            path: '/',
            name: 'home',
            pageBuilder: (context, state) =>
                NoTransitionPage(child: const HomeScreen()),
          ),

          // Map tab
          GoRoute(
            path: '/map',
            name: 'map',
            pageBuilder: (context, state) =>
                NoTransitionPage(child: const MapScreen()),
          ),

          // Services tab
          GoRoute(
            path: '/services',
            name: 'services',
            pageBuilder: (context, state) =>
                NoTransitionPage(child: const ServicesScreen()),
          ),

          // Bookings tab
          GoRoute(
            path: '/bookings',
            name: 'bookings',
            pageBuilder: (context, state) =>
                NoTransitionPage(child: const BookingHistoryScreen()),
          ),

          // Profile tab
          GoRoute(
            path: '/profile',
            name: 'profile',
            pageBuilder: (context, state) =>
                NoTransitionPage(child: const ProfileScreen()),
          ),
        ],
      ),

      // Service category and sub-services screens
      GoRoute(
        path: '/categories/:categoryId',
        name: 'serviceCategory',
        builder: (context, state) {
          final categoryId = state.pathParameters['categoryId'] as String;
          final subService = state.uri.queryParameters['subService'];
          return ServiceCategoryScreen(
            categoryId: categoryId,
            subService: subService,
          );
        },
        routes: [
          // Sub-service specific route
          GoRoute(
            path: 'sub-services/:subServiceId',
            name: 'subServiceList',
            builder: (context, state) {
              final categoryId = state.pathParameters['categoryId'] as String;
              final subServiceId =
                  state.pathParameters['subServiceId'] as String;
              final extra = state.extra as Map<String, dynamic>? ?? {};
              return SubServiceListScreen(
                categoryId: categoryId,
                subServiceId: subServiceId,
                categoryName: extra['categoryName'] as String? ?? '',
                subServiceName:
                    extra['subServiceName'] as String? ?? subServiceId,
              );
            },
          ),
        ],
      ),

      // Provider selection for specific service
      GoRoute(
        path: '/service/:serviceId/providers',
        name: 'providerSelection',
        builder: (context, state) {
          final serviceId = state.pathParameters['serviceId'] as String;
          return ProviderSelectionScreen(serviceId: serviceId);
        },
      ),

      // Service comparison screen
      GoRoute(
        path: '/compare',
        name: 'serviceComparison',
        builder: (context, state) {
          final serviceIds = state.extra as List<String>? ?? [];
          return ServiceComparisonScreen(serviceIds: serviceIds);
        },
      ),

      // Smart filtering screen
      GoRoute(
        path: '/smart-filters',
        name: 'smartFiltering',
        builder: (context, state) {
          final initialCriteria = state.extra;
          return SmartFilteringScreen(
            initialCriteria: initialCriteria as FilterCriteria?,
          );
        },
      ),
      // Service search results screen
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) =>
            SearchScreen(initialQuery: state.extra as String? ?? ''),
      ),
      // Price comparison screen
      GoRoute(
        path: '/price-comparison',
        name: 'priceComparison',
        builder: (context, state) => PriceComparisonScreen(),
      ),
      // Service provider list view
      GoRoute(
        path: '/provider-list',
        name: 'serviceProviderList',
        builder: (context, state) => ServiceProviderListScreen(),
      ),

      // Service detail screen
      GoRoute(
        path: '/service/:serviceId',
        name: 'serviceDetails',
        builder: (context, state) {
          final serviceId = state.pathParameters['serviceId'] as String;
          return ServiceDetailsScreen(serviceId: serviceId);
        },
      ),

      // Booking screens
      GoRoute(
        path: '/booking',
        name: 'bookingQuery',
        builder: (context, state) {
          final serviceId = state.uri.queryParameters['serviceId'] ?? '';
          final providerId = state.uri.queryParameters['providerId'];
          return BookingScreen(serviceId: serviceId, providerId: providerId);
        },
      ),
      GoRoute(
        path: '/booking/:serviceId',
        name: 'booking',
        builder: (context, state) {
          final serviceId = state.pathParameters['serviceId'] as String;
          return BookingScreen(serviceId: serviceId);
        },
      ),
      GoRoute(
        path: '/booking-success',
        name: 'bookingSuccess',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>? ?? {};
          final amount = args['amount'] as String? ?? '';
          final serviceId = args['serviceId'] as String? ?? '';
          return BookingSuccessScreen(amount: amount, serviceId: serviceId);
        },
      ),
      GoRoute(
        path: '/payment-methods',
        name: 'paymentMethods',
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>? ?? {};
          final amount = args['amount'];
          // Ensure proper double conversion
          final double parsedAmount = (amount is num)
              ? amount.toDouble()
              : amount is String
              ? double.tryParse(amount) ?? 0.0
              : 0.0;

          return CustomTransitionPage<void>(
            key: state.pageKey,
            child: PaymentMethodsScreen(
              amount: parsedAmount,
              serviceId: args['serviceId'] as String? ?? '',
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          );
        },
      ),
      GoRoute(
        path: '/payment-processing',
        name: 'paymentProcessing',
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          final amount = args['amount'];
          // Ensure proper double conversion
          final double parsedAmount = (amount is num)
              ? amount.toDouble()
              : amount is String
              ? double.tryParse(amount) ?? 0.0
              : 0.0;

          return CustomTransitionPage<void>(
            key: state.pageKey,
            child: PaymentProcessingScreen(
              amount: parsedAmount,
              serviceId: args['serviceId'] as String,
              paymentMethod: args['paymentMethod'] as Map<String, dynamic>?,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          );
        },
      ),
      GoRoute(
        path: '/payment-success',
        name: 'paymentSuccess',
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>? ?? {};
          final amount = args['amount'] as String? ?? '';
          final serviceId = args['serviceId'] as String? ?? '';
          return CustomTransitionPage<void>(
            key: state.pageKey,
            child: PaymentSuccessScreen(amount: amount, serviceId: serviceId),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  const begin = Offset(0.0, 1.0);
                  const end = Offset.zero;
                  final tween = Tween(begin: begin, end: end);
                  final offsetAnimation = animation.drive(tween);
                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
          );
        },
      ),
      GoRoute(
        path: '/booking-history',
        name: 'bookingHistory',
        builder: (context, state) => BookingHistoryScreen(),
      ),
      GoRoute(
        path: '/cancel-reschedule',
        name: 'cancelReschedule',
        builder: (context, state) => CancelRescheduleScreen(),
      ),

      // Notifications screen
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/notifications-center',
        name: 'notificationsCenter',
        builder: (context, state) => NotificationsCenterScreen(),
      ),
      GoRoute(
        path: '/favorites',
        name: 'favorites',
        builder: (context, state) => FavoritesScreen(),
      ),
      GoRoute(
        path: '/help-support',
        name: 'helpSupport',
        builder: (context, state) => HelpSupportScreen(),
      ),
      GoRoute(
        path: '/chat',
        name: 'chatMessages',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>? ?? {};
          final receiverId = args['receiverId'] as String? ?? '';
          final receiverName = args['receiverName'] as String? ?? '';
          return ChatMessagesScreen(
            receiverId: receiverId,
            receiverName: receiverName,
          );
        },
      ),

      // Settings screen
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // Service reviews screen
      GoRoute(
        path: '/service/:serviceId/reviews',
        name: 'serviceReviews',
        builder: (context, state) {
          final serviceId = state.pathParameters['serviceId'] as String;
          return ServiceReviewsScreen(serviceId: serviceId);
        },
      ),

      // Service provider screen
      GoRoute(
        path: '/providers/:providerId',
        name: 'serviceProvider',
        builder: (context, state) {
          final providerId = state.pathParameters['providerId'] as String;
          return ServiceProviderScreen(providerId: providerId);
        },
      ),

      // Address management screen
      GoRoute(
        path: '/addresses',
        name: 'addressManagement',
        builder: (context, state) => const AddressManagementScreen(),
      ),
      GoRoute(
        path: '/about',
        name: 'about',
        builder: (context, state) => AboutScreen(),
      ),
      GoRoute(
        path: '/offers',
        name: 'offers',
        builder: (context, state) => OffersScreen(),
      ),
      GoRoute(
        path: '/quick-service',
        name: 'quickService',
        builder: (context, state) => QuickServiceScreen(),
      ),
      GoRoute(
        path: '/membership',
        name: 'membership',
        builder: (context, state) => MembershipScreen(),
      ),
      GoRoute(
        path: '/categories',
        name: 'allCategories',
        builder: (context, state) => AllCategoriesScreen(),
      ),
      GoRoute(
        path: '/featured-services',
        name: 'featuredServices',
        builder: (context, state) => FeaturedServicesScreen(),
      ),
      GoRoute(
        path: '/popular-services',
        name: 'popularServices',
        builder: (context, state) => PopularServicesScreen(),
      ),
    ],
  );
}
