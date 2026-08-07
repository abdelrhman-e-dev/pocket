import 'package:go_router/go_router.dart';

import '../../features/accounts/presentation/pages/create_account_page.dart';
import '../../features/dashboard/dashboard.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';

final GoRouter router = GoRouter(
  initialLocation: '/onboarding',

  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),

    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashPage(),
    ),

    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
  path: '/create-account',
  builder: (context, state) => const CreateAccountPage(),
),
  ],
);