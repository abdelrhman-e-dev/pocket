import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLockState {
  const AppLockState({
    this.enabled = false,
    this.initialized = false,
    this.unlocked = false,
  });

  final bool enabled;
  final bool initialized;
  final bool unlocked;

  AppLockState copyWith({bool? enabled, bool? initialized, bool? unlocked}) =>
      AppLockState(
        enabled: enabled ?? this.enabled,
        initialized: initialized ?? this.initialized,
        unlocked: unlocked ?? this.unlocked,
      );
}

final appLockProvider = StateNotifierProvider<AppLockController, AppLockState>((
  ref,
) {
  return AppLockController(SharedPreferencesAsync(), LocalAuthentication());
});

class AppLockController extends StateNotifier<AppLockState> {
  AppLockController(this._preferences, this._authentication)
    : super(const AppLockState()) {
    _load();
  }

  static const _enabledKey = 'app_lock_enabled';

  final SharedPreferencesAsync _preferences;
  final LocalAuthentication _authentication;

  Future<void> _load() async {
    final enabled = await _preferences.getBool(_enabledKey) ?? false;
    state = state.copyWith(
      enabled: enabled,
      initialized: true,
      unlocked: !enabled,
    );
  }

  Future<bool> enable() async {
    if (!await _authentication.isDeviceSupported()) return false;

    final authenticated = await authenticate();
    if (!authenticated) return false;

    await _preferences.setBool(_enabledKey, true);
    state = state.copyWith(enabled: true, unlocked: true);
    return true;
  }

  Future<void> disable() async {
    await _preferences.setBool(_enabledKey, false);
    state = state.copyWith(enabled: false, unlocked: true);
  }

  Future<bool> authenticate() async {
    try {
      final authenticated = await _authentication.authenticate(
        localizedReason: 'صادق على هويتك لفتح Pocket',
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
      if (authenticated) {
        state = state.copyWith(unlocked: true);
      }
      return authenticated;
    } on LocalAuthException {
      state = state.copyWith(unlocked: false);
      return false;
    }
  }

  void lock() {
    if (state.enabled) state = state.copyWith(unlocked: false);
  }
}
