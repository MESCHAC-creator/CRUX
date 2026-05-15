import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // Stream d'authentification
  static Stream<UserModel?> authStateChanges() {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      
      try {
        final doc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (doc.exists) {
          return UserModel.fromMap(doc.data() ?? {});
        }
      } catch (e) {
        print('Error getting user: $e');
      }
      
      return null;
    });
  }

  // Inscription avec email
  static Future<UserModel?> registerWithEmail(
    String name,
    String email,
    String password,
  ) async {
    try {
      print('📝 Registering user: $email');

      final userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) return null;

      final userModel = UserModel(
        uid: user.uid,
        name: name,
        email: email,
        createdAt: DateTime.now(),
      );

      // Sauvegarder dans Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toMap());

      print('✅ User registered: ${user.uid}');
      return userModel;
    } catch (e) {
      print('❌ Registration error: $e');
      rethrow;
    }
  }

  // Connexion avec email
  static Future<UserModel?> loginWithEmail(
    String email,
    String password,
  ) async {
    try {
      print('🔐 Logging in: $email');

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        print('✅ User logged in: ${user.uid}');
        return UserModel.fromMap(doc.data() ?? {});
      }

      return null;
    } catch (e) {
      print('❌ Login error: $e');
      rethrow;
    }
  }

  // Connexion avec Google
  static Future<UserModel?> loginWithGoogle(
    GoogleSignInAccount googleUser,
  ) async {
    try {
      print('🔵 Google Sign In: ${googleUser.email}');

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _auth.signInWithCredential(credential);

      final user = userCredential.user;
      if (user == null) return null;

      // Vérifier si l'utilisateur existe
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        // Créer un nouvel utilisateur
        final userModel = UserModel(
          uid: user.uid,
          name: user.displayName ?? 'User',
          email: user.email ?? '',
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toMap());

        print('✅ New Google user created: ${user.uid}');
        return userModel;
      } else {
        print('✅ Google user logged in: ${user.uid}');
        return UserModel.fromMap(doc.data() ?? {});
      }
    } catch (e) {
      print('❌ Google login error: $e');
      rethrow;
    }
  }

  // Déconnexion
  static Future<void> logout() async {
    try {
      print('👋 Logging out');
      await _auth.signOut();
      await GoogleSignIn().signOut();
      print('✅ Logged out');
    } catch (e) {
      print('❌ Logout error: $e');
      rethrow;
    }
  }

  // Obtenir l'utilisateur actuel
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Réinitialiser le mot de passe
  static Future<void> resetPassword(String email) async {
    try {
      print('📧 Sending password reset email to: $email');
      await _auth.sendPasswordResetEmail(email: email);
      print('✅ Password reset email sent');
    } catch (e) {
      print('❌ Reset password error: $e');
      rethrow;
    }
  }
}
