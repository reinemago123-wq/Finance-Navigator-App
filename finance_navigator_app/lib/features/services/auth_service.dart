import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────
//  AuthService
//
//  Single place for all Firebase Auth calls.
//  Returns plain strings on error so the UI
//  can show them directly — no try/catch in widgets.
// ─────────────────────────────────────────────
class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _db   = FirebaseFirestore.instance;

  // ── Current user ──────────────────────────────────────────────────────────
  static User? get currentUser => _auth.currentUser;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Sign in ───────────────────────────────────────────────────────────────
  /// Returns null on success, or an error message string on failure.
  static Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null; // success
    } on FirebaseAuthException catch (e) {
      return _friendlyError(e.code);
    } catch (_) {
      return 'Something went wrong. Please try again.';
    }
  }

  // ── Register ──────────────────────────────────────────────────────────────
  /// Creates the Firebase Auth account and a Firestore user document.
  /// Returns null on success, or an error message string on failure.
  static Future<String?> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update display name
      await cred.user?.updateDisplayName(fullName.trim());

      // Create user document in Firestore
      await _db.collection('users').doc(cred.user!.uid).set({
        'uid':       cred.user!.uid,
        'fullName':  fullName.trim(),
        'email':     email.trim().toLowerCase(),
        'createdAt': FieldValue.serverTimestamp(),
        'plan':      'free',
      });

      return null; // success
    } on FirebaseAuthException catch (e) {
      return _friendlyError(e.code);
    } catch (_) {
      return 'Something went wrong. Please try again.';
    }
  }

  // ── Sign out ───────────────────────────────────────────────────────────────
  static Future<void> signOut() => _auth.signOut();

  // ── Password reset ─────────────────────────────────────────────────────────
  static Future<String?> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyError(e.code);
    }
  }

  // ── Friendly error messages ────────────────────────────────────────────────
  static String _friendlyError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with that email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Email or password is incorrect.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment.';
      case 'network-request-failed':
        return 'No internet connection. Check your network.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}