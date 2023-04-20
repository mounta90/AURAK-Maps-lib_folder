import 'package:firebase_auth/firebase_auth.dart';
import 'package:maps/services/auth/auth_exceptions.dart';

class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth;

  User? get user => _firebaseAuth.currentUser;

  FirebaseAuthService() : _firebaseAuth = FirebaseAuth.instance;

  Future<User> logInAnonymously() async {
    try {
      await _firebaseAuth.signInAnonymously();
      if (user != null) {
        return user!;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == "operation-not-allowed") {
        throw OperationNotAllowedAuthException();
      } else {
        throw GenericAuthException();
      }
    }
  }

  Future<User> logIn({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (user != null) {
        return user!;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw UserNotFoundAuthException();
      } else if (e.code == 'wrong-password') {
        throw WrongPasswordAuthException();
      } else {
        throw GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }

  Future<void> logOut() async {
    if (user != null) {
      await _firebaseAuth.signOut();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }
}
