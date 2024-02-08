import 'package:inventory_frontend/data/user/user.service.dart';
import 'package:inventory_frontend/domain/user/valueobject.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current.user.provider.g.dart';

@riverpod
Future<User> currentUser(CurrentUserRef ref) async {
  final userService = ref.watch(userServiceProvider);
  final userOrError = await userService.getCurrentUser();
  if (userOrError.isLeft()) {
    throw Exception('Unable to get current user');
  }
  return userOrError.toIterable().first;
}
