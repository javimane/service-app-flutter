import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/home/presentation/main_scaffold.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/reels/presentation/reels_screen.dart';
import '../../features/profile/presentation/specialist_profile_screen.dart';
import '../../features/profile/presentation/professional_store_screen.dart';
import '../../features/categories/presentation/categories_screen.dart';
import '../../features/services/presentation/services_screen.dart';
import '../../features/services/presentation/service_detail_screen.dart';
import '../../features/products/presentation/products_screen.dart';
import '../../features/products/presentation/product_detail_screen.dart';
import '../../features/dashboard/presentation/dashboard_main_screen.dart';
import '../../features/favorites/presentation/favorites_screen.dart';
import '../../features/promotions/presentation/promotions_screen.dart';
import '../../features/bank_promotions/presentation/bank_promotions_screen.dart';
import '../../features/bank_promotions/presentation/bank_promotion_detail_screen.dart';
import '../../features/plan_payment/presentation/plan_payment_screen.dart';
import '../../features/map/presentation/map_screen.dart';
import '../../features/chat/presentation/chat_screen.dart';
import '../../features/profile/presentation/settings_screen.dart';

final appRouter = GoRouter(
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
      builder: (context, state, child) {
        return MainScaffold(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) =>
              _fadeTransition(state, const HomeScreen()),
        ),
      ],
    ),

    // ─── Full screen routes ───────────────────────────────────────────────
    GoRoute(
      path: '/categories',
      pageBuilder: (context, state) =>
          _slideTransition(state, const CategoriesScreen()),
    ),
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
        // El parámetro 'initialCategoryId' no existe en ProductsScreen
        return _slideTransition(
          state,
          const ProductsScreen(),
        );
      },
    ),
    GoRoute(
      path: '/products/:id',
      pageBuilder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
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
      path: '/dashboard',
      pageBuilder: (context, state) =>
          _slideTransition(state, const DashboardMainScreen()),
    ),
    GoRoute(
      path: '/favorites',
      pageBuilder: (context, state) =>
          _slideTransition(state, const FavoritesScreen()),
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
      path: '/messages',
      pageBuilder: (context, state) =>
          _slideTransition(state, const ChatScreen()),
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) =>
          _slideTransition(state, const SettingsScreen()),
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

// Placeholder screens removed — not referenced in routes
