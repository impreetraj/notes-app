
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:note_app_ikokas/dbhelper/user_db_helper.dart';
import 'package:note_app_ikokas/model/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserLocalDbService _userDb;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  AuthRepository(this._userDb) {
    _googleSignIn.initialize();
  }

  Stream<User?> get user => _auth.authStateChanges();

  Future<UserModel?> getUserData(String uid) async {
    final data = await _userDb.getUser(uid);
    if (data != null) {
      return UserModel.fromMap(data);
    }
    return null;
  }

  Future<UserCredential> login(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signup(String name, String email, String password) async {
    UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    final userData = {
      'name': name,
      'email': email,
      'uid': credential.user!.uid,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    };

    await _firestore.collection('users').doc(credential.user!.uid).set(userData);
    await _userDb.saveUser(userData);

    return credential;
  }

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
    if (googleUser == null) throw Exception("Sign in aborted by user");

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    UserCredential userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user!;

    
    final userData = {
      'name': user.displayName ?? "No Name",
      'email': user.email ?? "",
      'uid': user.uid,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    };

    await _firestore.collection('users').doc(user.uid).set(userData);
    await _userDb.saveUser(userData);

    return userCredential;
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
