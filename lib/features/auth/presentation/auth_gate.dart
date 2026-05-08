import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/presentation/home_screen.dart';
import '../../player/providers/atmospheric_engine_provider.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Stop audio whenever the user signs out.
    ref.listen(authStateChangesProvider, (previous, next) {
      final wasSignedIn = previous?.valueOrNull != null;
      final isNowSignedOut = next.valueOrNull == null;
      if (wasSignedIn && isNowSignedOut) {
        ref.read(atmosphericEngineProvider.notifier).pause();
      }
    });

    final authState = ref.watch(authStateChangesProvider);

    return authState.when(
      data: (user) => user == null ? const LoginScreen() : const HomeScreen(),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const LoginScreen(),
    );
  }
}
