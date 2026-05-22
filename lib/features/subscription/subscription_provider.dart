import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final isProProvider = FutureProvider<bool>((ref) async {
  // Wait for auth to be ready, then read the user document once.
  final user = await FirebaseAuth.instance.authStateChanges().first;
  if (user == null) return false;

  try {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    return doc.data()?['isPro'] == true;
  } catch (_) {
    return false;
  }
});
