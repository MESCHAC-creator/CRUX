import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? lastError;

  Future<UserModel?> register(String name, String email, String password) async {
    try {
      // Étape 1 : Créer le compte Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      UserModel user = UserModel(
        uid: result.user!.uid,
        name: name,
        email: email,
      );

      // Étape 2 : Sauvegarder dans Firestore avec timeout
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(user.toMap())
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Firestore timeout'),
      );

      return user;
    } on Exception catch (e) {
      lastError = e.toString();
      // Si Firestore échoue mais Auth a réussi, on retourne quand même l'user
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        return UserModel(
          uid: currentUser.uid,
          name: name,
          email: email,
        );
      }
      return null;
    }
  }

  Future<UserModel?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Tenter de récupérer depuis Firestore avec timeout
      try {
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .get()
            .timeout(const Duration(seconds: 10));

        if (doc.exists) {
          return UserModel.fromMap(doc.data() as Map<String, dynamic>);
        }
      } catch (e) {
        lastError = e.toString();
      }

      // Si Firestore échoue, retourner l'user depuis Auth
      return UserModel(
        uid: result.user!.uid,
        name: result.user!.displayName ?? email.split('@')[0],
        email: email,
      );
    } catch (e) {
      lastError = e.toString();
      return null;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}