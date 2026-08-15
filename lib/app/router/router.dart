import 'package:go_router/go_router.dart';

import '../../features/accounts/presentation/pages/create_account_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/transactions/presentation/pages/add_transaction_page.dart';
import '../../features/transactions/presentation/pages/transactions_page.dart';
import '../../features/transactions/presentation/pages/transaction_details_page.dart';
import '../../features/transactions/models/transaction_with_details.dart';
import '../../features/transfers/presentation/pages/add_transfer_page.dart';
import '../../features/accounts/presentation/pages/accounts_page.dart';
import '../../features/transfers/models/transfer_with_details.dart';
import '../../features/transfers/presentation/pages/transfer_details_page.dart';
import '../../features/transfers/presentation/pages/edit_transfer_page.dart';


final GoRouter router = GoRouter(
  initialLocation: '/',

  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashPage()),

    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardPage(),
    ),
    GoRoute(
      path: '/transactions',
      builder: (context, state) => const TransactionsPage(),
    ),
    GoRoute(
      path: '/accounts',
      builder: (context, state) => const AccountsPage(),
    ),
    GoRoute(
      path: '/transactions/edit',
      builder: (context, state) {
        final transaction = state.extra as TransactionWithDetails;

        return AddTransactionPage(transaction: transaction);
      },
    ),
    GoRoute(
      path: '/transfers/edit',
      builder: (context, state) {
        final transfer = state.extra as TransferWithDetails;

        return EditTransferPage(transfer: transfer);
      },
    ),
    GoRoute(
      path: '/add-transfer',
      builder: (context, state) => const AddTransferPage(),
    ),
    GoRoute(
      path: '/transfers/details',
      builder: (context, state) {
        final transfer = state.extra as TransferWithDetails;

        return TransferDetailsPage(transfer: transfer);
      },
    ),
    GoRoute(
      path: '/transfers/edit',
      builder: (context, state) {
        final transfer = state.extra as TransferWithDetails;

        return AddTransferPage(transfer: transfer);
      },
    ),
    GoRoute(
      path: '/create-account',
      builder: (context, state) => const CreateAccountPage(),
    ),

    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: '/add-transaction',
      builder: (context, state) => const AddTransactionPage(),
    ),

    GoRoute(
      path: '/transactions/details',
      builder: (context, state) {
        final transaction = state.extra as TransactionWithDetails;

        return TransactionDetailsPage(transaction: transaction);
      },
    ),
  ],
);
