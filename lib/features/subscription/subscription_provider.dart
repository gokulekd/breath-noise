import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _ProStatusNotifier extends StateNotifier<bool> {
  _ProStatusNotifier() : super(false) {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final user = await FirebaseAuth.instance.authStateChanges().first;
    if (user == null) return;

    final cacheKey = 'is_pro_${user.uid}';

    // Apply cached value immediately — zero delay on 2nd+ app open
    final cached = prefs.getBool(cacheKey);
    if (cached == true && mounted) state = true;

    // Verify from Firestore and refresh the cache
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final isPro = doc.data()?['isPro'] == true;
      await prefs.setBool(cacheKey, isPro);
      if (mounted) state = isPro;
    } catch (_) {
      // Keep cached/default value on network error
    }
  }
}

/// Returns true if the current user has a Pro subscription.
/// On the first ever app open: resolves from Firestore (fast, ~200ms).
/// On every subsequent open: returns cached true instantly, then re-verifies.
final isProProvider = StateNotifierProvider<_ProStatusNotifier, bool>((ref) {
  return _ProStatusNotifier();
});
