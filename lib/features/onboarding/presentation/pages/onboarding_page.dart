import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),

              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),

                child: Column(
                  children: [
                    // =========================
                    // Image Area
                    // =========================
                    SizedBox(
                      height: constraints.maxHeight * 0.34,
                      width: double.infinity,

                      child: Container(
                        color: AppTheme.imageAreaColor,

                        child: Image.asset(
                          'assets/images/onboard_background.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    // =========================
                    // Content
                    // =========================
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),

                      child: Column(
                        children: [
                          Text(
                            'أهلًا بك في Pocket',
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.center,

                            style: const TextStyle(
                              color: AppTheme.textColor,
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              height: 1.15,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Text(
                            'أدر أموالك وتابع مصروفاتك بسهولة.',
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.center,

                            style: const TextStyle(
                              color: AppTheme.subtitleColor,
                              fontSize: 18,
                              height: 1.6,
                            ),
                          ),

                          const SizedBox(height: 26),

                          // =========================
                          // Accounts
                          // =========================
                          const _FeatureCard(
                            icon: Icons.account_balance_wallet_rounded,
                            title: 'الحسابات',
                            subtitle: 'أدر جميع أموالك في مكان واحد.',
                          ),

                          const SizedBox(height: 12),

                          // =========================
                          // Expenses
                          // =========================
                          const _FeatureCard(
                            icon: Icons.receipt_long_rounded,
                            title: 'المصروفات',
                            subtitle: 'سجّل مصروفاتك في ثوانٍ.',
                          ),

                          const SizedBox(height: 12),

                          // =========================
                          // Reports
                          // =========================
                          const _FeatureCard(
                            icon: Icons.bar_chart_rounded,
                            title: 'التقارير',
                            subtitle: 'اعرف أين تذهب أموالك.',
                          ),

                          const SizedBox(height: 24),

                          // =========================
                          // Start Button
                          // =========================
                          SizedBox(
                            width: double.infinity,
                            height: 56,

                            child: FilledButton(
                              onPressed: () {
                                context.go('/enter-name');
                              },

                              child: const Text(
                                'ابدأ الآن',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // =========================
                          // Offline
                          // =========================
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,

                            children: [
                              Icon(
                                Icons.lock_outline,
                                size: 14,
                                color: Colors.black45,
                              ),

                              SizedBox(width: 5),

                              Text(
                                'يعمل دون اتصال بالإنترنت',
                                style: TextStyle(
                                  color: Colors.black45,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),

      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,

        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: AppTheme.borderColor, width: 1),
      ),

      child: Row(
        children: [
          // =========================
          // Text
          // =========================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,

                  style: const TextStyle(
                    color: AppTheme.textColor,
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,

                  style: const TextStyle(
                    color: AppTheme.subtitleColor,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // =========================
          // Icon
          // =========================
          Container(
            width: 56,
            height: 56,

            decoration: const BoxDecoration(
              color: AppTheme.iconBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 27),
          ),
        ],
      ),
    );
  }
}
