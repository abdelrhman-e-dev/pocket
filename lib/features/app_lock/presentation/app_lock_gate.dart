import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_lock_provider.dart';

class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate>
    with WidgetsBindingObserver {
  static const _gracePeriod = Duration(seconds: 30);
  DateTime? _backgroundedAt;
  bool _authenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _authenticateIfNeeded(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _backgroundedAt ??= DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      final elapsed = _backgroundedAt == null
          ? _gracePeriod
          : DateTime.now().difference(_backgroundedAt!);
      _backgroundedAt = null;
      if (elapsed >= _gracePeriod) {
        ref.read(appLockProvider.notifier).lock();
      }
      _authenticateIfNeeded();
    }
  }

  Future<void> _authenticateIfNeeded() async {
    final lock = ref.read(appLockProvider);
    if (!lock.initialized ||
        !lock.enabled ||
        lock.unlocked ||
        _authenticating) {
      return;
    }
    _authenticating = true;
    await ref.read(appLockProvider.notifier).authenticate();
    _authenticating = false;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final lock = ref.watch(appLockProvider);
    if (!lock.initialized || (lock.enabled && !lock.unlocked)) {
      return _LockScreen(
        authenticating: _authenticating,
        onUnlock: _authenticateIfNeeded,
      );
    }
    return widget.child;
  }
}

class _LockScreen extends StatelessWidget {
  const _LockScreen({required this.authenticating, required this.onUnlock});

  final bool authenticating;
  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colors.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.account_balance_wallet_rounded,
                size: 72,
                color: colors.primary,
              ),
              const SizedBox(height: 20),
              Text('Pocket', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 32),
              Semantics(
                button: true,
                label: 'فتح التطبيق بالبصمة',
                child: InkWell(
                  borderRadius: BorderRadius.circular(64),
                  onTap: authenticating ? null : onUnlock,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Icon(
                      Icons.fingerprint_rounded,
                      size: 88,
                      color: colors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('المس لفتح التطبيق'),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: authenticating ? null : onUnlock,
                icon: const Icon(Icons.lock_open_rounded),
                label: const Text('استخدم رمز الجهاز'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
