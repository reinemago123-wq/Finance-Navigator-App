import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────
//  UserService
//
//  Provides the current user's display data.
//  Falls back to Firebase Auth fields if the
//  Firestore doc hasn't loaded yet.
// ─────────────────────────────────────────────
class UserService {
  static final _auth = FirebaseAuth.instance;
  static final _db   = FirebaseFirestore.instance;

  // ── Quick getters (from Firebase Auth — always available) ──────────────────
  static String get displayName {
    final name = _auth.currentUser?.displayName ?? '';
    return name.isNotEmpty ? name : 'there';
  }

  static String get firstName {
    final full = displayName;
    return full.split(' ').first;
  }

  static String get email =>
      _auth.currentUser?.email ?? '';

  static String get uid =>
      _auth.currentUser?.uid ?? '';

  // ── Full Firestore profile (stream) ───────────────────────────────────────
  // Use this if you need the full doc (e.g. plan, createdAt).
  static Stream<DocumentSnapshot<Map<String, dynamic>>>? get profileStream {
    final id = uid;
    if (id.isEmpty) return null;
    return _db.collection('users').doc(id).snapshots();
  }

  // ── Update display name in both Auth and Firestore ─────────────────────────
  static Future<String?> updateName(String newName) async {
    try {
      await _auth.currentUser?.updateDisplayName(newName.trim());
      if (uid.isNotEmpty) {
        await _db.collection('users').doc(uid)
            .update({'fullName': newName.trim()});
      }
      return null;
    } catch (_) {
      return 'Could not update name. Please try again.';
    }
  }

  // ── Update email in both Auth and Firestore ────────────────────────────────
  static Future<String?> updateEmail(String newEmail) async {
    try {
      await _auth.currentUser?.verifyBeforeUpdateEmail(newEmail.trim());
      if (uid.isNotEmpty) {
        await _db.collection('users').doc(uid)
            .update({'email': newEmail.trim().toLowerCase()});
      }
      return null;
    } catch (_) {
      return 'Could not update email. Please try again.';
    }
  }
}