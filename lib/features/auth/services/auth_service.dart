import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

const _webClientId =
    '501054824114-125qlm6p0p1sjmu2t3rhhs72vc5j7le2.apps.googleusercontent.com';

final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn(serverClientId: _webClientId);
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    auth: ref.watch(firebaseAuthProvider),
    googleSignIn: ref.watch(googleSignInProvider),
  );
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

class AuthService {
  AuthService({
    required FirebaseAuth auth,
    required GoogleSignIn googleSignIn,
  })  : _auth = auth,
        _googleSignIn = googleSignIn;

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (name.trim().isNotEmpty) {
      await credential.user?.updateDisplayName(name.trim());
      await credential.user?.reload();
    }

    return credential;
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      provider.setCustomParameters({'prompt': 'select_account'});
      return _auth.signInWithPopup(provider);
    }

    final account = await _googleSignIn.signIn();
    if (account == null) {
      throw FirebaseAuthException(
        code: 'sign-in-cancelled',
        message: 'Google sign-in was cancelled.',
      );
    }

    final authentication = await account.authentication;
    final idToken = authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw FirebaseAuthException(
        code: 'missing-google-id-token',
        message: 'Google Sign-In did not return an ID token.',
      );
    }

    final credential = GoogleAuthProvider.credential(
      idToken: idToken,
      accessToken: authentication.accessToken,
    );
    return _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
    await _auth.signOut();
  }
}
