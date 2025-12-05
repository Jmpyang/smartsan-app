import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../data/models/user_model.dart';


class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('users');

  Future<UserCredential> signUp(String email, String password) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Signs in the user using email and password
  Future<UserCredential> signIn(String email, String password) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Saves a new user record (profile) in the Realtime Database
  Future<void> createUserRecord(UserModel user) async {
    await _dbRef.child(user.uid).set(user.toJson());
  }
  
  // Exposes the current Firebase Auth state as a stream
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Signs out the current user
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}