import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;



  Stream<User?> get usuarioStream => _auth.authStateChanges();

  User? get usuarioActual => _auth.currentUser;

  Future<UserCredential> registrar(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> iniciarSesion(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential?> iniciarSesionConGoogle() async {
    try {
      final GoogleSignInAccount googleUser =
          await GoogleSignIn.instance.authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      return null;
    }
  }

  Future<void> cerrarSesion() async {
    await GoogleSignIn.instance.signOut();
    await _auth.signOut();
  }
}
