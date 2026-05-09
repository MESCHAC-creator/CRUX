import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> register(String name, String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      UserModel user = UserModel(
        uid: result.user!.uid,
        name: name,
        email: email,
      );
      await _firestore.collection('users').doc(user.uid).set(user.toMap());
      return user;
    } catch (e) {
      print('ERREUR INSCRIPTION: $e');
      return null;
    }
  }

  Future<UserModel?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(result.user!.uid)
          .get();
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    } catch (e) {
      print('ERREUR CONNEXION: $e');
      return null;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}