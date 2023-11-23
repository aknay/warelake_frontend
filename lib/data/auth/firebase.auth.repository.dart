import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firebase.auth.repository.g.dart';

class AuthRepository {
  AuthRepository(this._auth);
  final FirebaseAuth _auth;

  Stream<User?> authStateChanges() => _auth.authStateChanges();
  bool get isUserLoggedIn => currentUser.isSome();

  Option<User> get currentUser => optionOf(_auth.currentUser);

  Future<void> signInAnonymously() {
    return _auth.signInAnonymously();
  }

  Future<String> shouldGetToken() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw AssertionError('User can\'t be null');
    }

    final token = await user.getIdToken();
    return token!;
  }
}

@Riverpod(keepAlive: true)
FirebaseAuth firebaseAuth(FirebaseAuthRef ref) {
  return FirebaseAuth.instance;
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepository(ref.watch(firebaseAuthProvider));
}

@riverpod
Stream<User?> authStateChanges(AuthStateChangesRef ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
}
