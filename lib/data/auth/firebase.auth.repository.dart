import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firebase.auth.repository.g.dart';

class AuthRepository {
  AuthRepository(this._auth);
  final FirebaseAuth _auth;

  Stream<User?> authStateChanges() => _auth.authStateChanges();
  Future<bool> get isUserLoggedIn async {
    final f = await currentUser;
    return f.isSome();
  }

  Future<Option<User>> get currentUser async {
    // TODO: _auth will remember even we close emulator
    final authUser = _auth.currentUser;
    if (authUser == null) {
      return const None();
    }
    try {
      log("come to trying");
      //TODO: force to get token, still need to uninstall the app
      final token = await authUser.getIdToken();
      log("token: $token");
      return optionOf(authUser);
      // } on Exception catch (exception) {
      //   log("come to expection");
    } catch (error) {
      log("come to catch");
      _auth.signOut();
      return const None();
    }
  }

  User? get currentUserOrNull => _auth.currentUser;

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

  Future<void> signOut() async {
    _auth.signOut();
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
