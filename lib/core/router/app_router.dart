import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:service_app_flutter/features/chat/presentation/conversations_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/home/presentation/main_scaffold.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/home/presentation/menu_screen.dart';
import '../../features/reels/presentation/reels_screen.dart';
import '../../features/profile/presentation/specialist_profile_screen.dart';
import '../../features/profile/presentation/professional_store_screen.dart';
import '../../features/categories/presentation/categories_screen.dart';
import '../../features/services/presentation/services_screen.dart';
import '../../features/services/presentation/service_detail_screen.dart';
import '../../features/products/presentation/products_screen.dart';
import '../../features/products/presentation/product_detail_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_main_screen.dart';
import '../../features/favorites/presentation/favorites_screen.dart';
import '../../features/promotions/presentation/promotions_screen.dart';
import '../../features/bank_promotions/presentation/bank_promotions_screen.dart';
import '../../features/promotions/presentation/bank_promotion_detail_screen.dart';
import '../../features/promotions/presentation/professional_promotion_detail_screen.dart';
import '../../features/plan_payment/presentation/plan_payment_screen.dart';
import '../../features/map/presentation/map_screen.dart';
import '../../features/chat/presentation/chat_screen.dart';
import '../../features/profile/presentation/settings_screen.dart';
// Dashboard screens – Group 1 (Proposals & Promotions)
import '../../features/dashboard/presentation/screens/proposals_screen.dart';
import '../../features/dashboard/presentation/screens/promotions_management_screen.dart';
// Dashboard screens – Group 2 (Products, Services, Reels)
import '../../features/dashboard/presentation/screens/products_management_screen.dart';
import '../../features/dashboard/presentation/screens/services_management_screen.dart';
import '../../features/dashboard/presentation/screens/reels_management_screen.dart';
// Dashboard screens – Group 3 (Calendar, Notifications, Profile, Subscription, Referrals, Bank Promotions)
import '../../features/dashboard/presentation/screens/calendar_screen.dart';
import '../../features/dashboard/presentation/screens/notifications_screen.dart';
import '../../features/dashboard/presentation/screens/profile_screen.dart';
import '../../features/dashboard/presentation/screens/subscription_screen.dart';
import '../../features/dashboard/presentation/screens/referrals_screen.dart';
import '../../features/dashboard/presentation/screens/bank_promotions_management_screen.dart';
import '../../core/widgets/subscription_wrapper.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  routes: [
    // ─── Auth ────────────────────────────────────────────────────────────
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => _fadeTransition(
        state,
        const LoginScreen(),
      ),
    ),
    GoRoute(
      path: '/register',
      pageBuilder: (context, state) => _slideTransition(
        state,
        const RegisterScreen(),
      ),
    ),

    // ─── Shell (bottom nav) ───────────────────────────────────────────────
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainScaffold(child: child);
      },
      routes: [
        // Top level tabs (NavBar is visible)
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) =>
              _fadeTransition(state, const HomeScreen()),
        ),
        GoRoute(
          path: '/categories',
          pageBuilder: (context, state) =>
              _slideTransition(state, const CategoriesScreen()),
        ),

        GoRoute(
          path: '/favorites',
          pageBuilder: (context, state) =>
              _slideTransition(state, const FavoritesScreen()),
        ),
        GoRoute(
          path: '/chat',
          pageBuilder: (context, state) =>
              _slideTransition(state, const ConversationsScreen()),
        ),
        GoRoute(
          path: '/menu',
          pageBuilder: (context, state) =>
              _fadeTransition(state, const MenuScreen()),
        ),
      ],
    ),

    // ─── Sub-routes (Pushed over root navigator, NavBar hidden) ───────────
    GoRoute(
      path: '/services',
      pageBuilder: (context, state) {
        final categoryId = state.uri.queryParameters['categoryId'] != null
            ? int.tryParse(state.uri.queryParameters['categoryId']!)
            : null;
        return _slideTransition(
          state,
          ServicesScreen(initialCategoryId: categoryId),
        );
      },
    ),
    GoRoute(
      path: '/services/:id',
      pageBuilder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return _slideTransition(state, ServiceDetailScreen(serviceId: id));
      },
    ),
    GoRoute(
      path: '/products',
      pageBuilder: (context, state) {
        return _slideTransition(
          state,
          const ProductsScreen(),
        );
      },
    ),
    GoRoute(
      path: '/products/:id',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        return _slideTransition(state, ProductDetailScreen(productId: id));
      },
    ),
    GoRoute(
      path: '/reels',
      pageBuilder: (context, state) =>
          _slideTransition(state, const ReelsScreen()),
    ),
    GoRoute(
      path: '/specialist/:id',
      pageBuilder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return _slideTransition(state, const SpecialistProfileScreen());
        }
        return _slideTransition(
          state,
          ProfessionalStoreScreen(professionalId: id),
        );
      },
    ),
    GoRoute(
      path: '/specialist',
      pageBuilder: (context, state) =>
          _slideTransition(state, const SpecialistProfileScreen()),
    ),
    GoRoute(
      path: '/promotions',
      pageBuilder: (context, state) =>
          _slideTransition(state, const PromotionsScreen()),
    ),
    GoRoute(
      path: '/bank-promotions',
      pageBuilder: (context, state) =>
          _slideTransition(state, const BankPromotionsScreen()),
    ),
    GoRoute(
      path: '/bank-promotions/:id',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        return _slideTransition(state, BankPromotionDetailScreen(id: id));
      },
    ),
    GoRoute(
      path: '/professional-promotions/:id',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        return _slideTransition(
            state, ProfessionalPromotionDetailScreen(id: id));
      },
    ),
    GoRoute(
      path: '/plan-payment',
      pageBuilder: (context, state) =>
          _slideTransition(state, const PlanPaymentScreen()),
    ),
    GoRoute(
      path: '/map',
      pageBuilder: (context, state) =>
          _slideTransition(state, const MapScreen()),
    ),
    GoRoute(
      path: '/chat/:id',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        final initialMessage = state.uri.queryParameters['initialMessage'];
        return _slideTransition(
            state, ChatScreen(chatId: id, initialMessage: initialMessage));
      },
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) =>
          _slideTransition(state, const SettingsScreen()),
    ),
    // ─── Dashboard sub-routes ─────────────────────────────────────────
    GoRoute(
      path: '/dashboard/analytics',
      pageBuilder: (context, state) =>
          _slideTransition(state, const DashboardAnalyticsScreen()),
    ),
    GoRoute(
      path: '/dashboard/proposals',
      pageBuilder: (context, state) =>
          _slideTransition(state, const SubscriptionWrapper(child: DashboardProposalsScreen())),
    ),
    GoRoute(
      path: '/dashboard/promotions',
      pageBuilder: (context, state) =>
          _slideTransition(state, const SubscriptionWrapper(child: DashboardPromotionsScreen())),
    ),
    // Group 2 – Products, Services, Reels
    GoRoute(
      path: '/dashboard/products',
      pageBuilder: (context, state) =>
          _slideTransition(state, const DashboardProductsScreen()),
    ),
    GoRoute(
      path: '/dashboard/services',
      pageBuilder: (context, state) =>
          _slideTransition(state, const DashboardServicesScreen()),
    ),
    GoRoute(
      path: '/dashboard/reels',
      pageBuilder: (context, state) =>
          _slideTransition(state, const SubscriptionWrapper(child: DashboardReelsScreen())),
    ),
    // Group 3 – Calendar, Notifications, Profile, Subscription, Referrals, Bank Promotions
    GoRoute(
      path: '/dashboard/calendar',
      pageBuilder: (context, state) =>
          _slideTransition(state, const SubscriptionWrapper(child: DashboardCalendarScreen())),
    ),
    GoRoute(
      path: '/dashboard/notifications',
      pageBuilder: (context, state) =>
          _slideTransition(state, const DashboardNotificationsScreen()),
    ),
    GoRoute(
      path: '/dashboard/profile',
      pageBuilder: (context, state) =>
          _slideTransition(state, const DashboardProfileScreen()),
    ),
    GoRoute(
      path: '/dashboard/subscription',
      pageBuilder: (context, state) =>
          _slideTransition(state, const DashboardSubscriptionScreen()),
    ),
    GoRoute(
      path: '/dashboard/referrals',
      pageBuilder: (context, state) =>
          _slideTransition(state, const DashboardReferralsScreen()),
    ),
    GoRoute(
      path: '/dashboard/bank-promotions',
      pageBuilder: (context, state) =>
          _slideTransition(state, const SubscriptionWrapper(child: DashboardBankPromotionsScreen())),
    ),
  ],
);

CustomTransitionPage<void> _slideTransition(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOutCubic;
      final tween =
          Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

CustomTransitionPage<void> _fadeTransition(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    transitionDuration: const Duration(milliseconds: 250),
  );
}
