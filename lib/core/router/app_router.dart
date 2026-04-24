import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/home/presentation/main_scaffold.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/reels/presentation/reels_screen.dart';
import '../../features/profile/presentation/specialist_profile_screen.dart';
import '../../features/categories/presentation/categories_screen.dart';
import '../../features/services/presentation/services_screen.dart';
import '../../features/products/presentation/products_screen.dart';
import '../../features/dashboard/presentation/dashboard_main_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) {
        return MainScaffold(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/reels',
      builder: (context, state) => const ReelsScreen(),
    ),
    GoRoute(
      path: '/specialist',
      builder: (context, state) => const SpecialistProfileScreen(),
    ),
    GoRoute(
      path: '/categories',
      builder: (context, state) => const CategoriesScreen(),
    ),
    GoRoute(
      path: '/services',
      builder: (context, state) => const ServicesScreen(),
    ),
    GoRoute(
      path: '/products',
      builder: (context, state) => const ProductsScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardMainScreen(),
    ),
  ],
);
