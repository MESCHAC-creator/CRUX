import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? lastError;

  Future<UserModel?> register(String name, String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await result.user!.updateDisplayName(name);
      UserModel user = UserModel(
        uid: result.user!.uid,
        name: name,
        email: email,
      );
      try {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(user.toMap())
            .timeout(const Duration(seconds: 8));
      } catch (e) {
        lastError = e.toString();
      }
      return user;
    } catch (e) {
      lastError = e.toString();
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
      try {
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .get()
            .timeout(const Duration(seconds: 8));
        if (doc.exists) {
          return UserModel.fromMap(doc.data() as Map<String, dynamic>);
        }
      } catch (e) {
        lastError = e.toString();
      }
      return UserModel(
        uid: result.user!.uid,
        name: result.user!.displayName ??
            email.split('@')[0],
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
