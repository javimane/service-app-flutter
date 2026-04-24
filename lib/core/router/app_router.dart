import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/home/presentation/main_scaffold.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/reels/presentation/reels_screen.dart';
import '../../features/profile/presentation/specialist_profile_screen.dart';

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
  ],
);
