import 'package:flutter/foundation.dart';
import 'package:warelake/data/user/user.service.dart';
import 'package:warelake/domain/user/valueobject.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current.user.provider.g.dart';

@Riverpod(keepAlive: true)
Future<User> currentUser(CurrentUserRef ref) async {
  final userService = ref.watch(userServiceProvider);
  final userOrError = await userService.getCurrentUser();
  if (kDebugMode) {
    await Future.delayed(const Duration(seconds: 1));
  }
  if (userOrError.isLeft()) {
    throw Exception('Unable to get current user');
  }
  return userOrError.toIterable().first;
}
