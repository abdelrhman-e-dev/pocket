import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/app_strings.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),

              Image.asset('assets/images/logo.webp', width: 150, height: 150),

              const SizedBox(height: 40),

              Text(
                AppStrings.welcomeTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                AppStrings.welcomeDescription,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: () {
                    context.go('/create-account');
                  },
                  child: const Text(AppStrings.getStarted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
