import 'package:dartz/dartz.dart';
import 'package:inventory_frontend/data/auth/firebase.auth.repository.dart';
import 'package:inventory_frontend/data/onboarding/team.id.shared.ref.repository.dart';
import 'package:inventory_frontend/data/user/user.repository.dart';
import 'package:inventory_frontend/domain/user/api.dart';
import 'package:inventory_frontend/domain/user/valueobject.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user.service.g.dart';

class UserService {
  final AuthRepository _authRepo;
  final TeamIdSharedRefereceRepository _teamIdSharedRefRepository;
  final UserApi _userApi;
  UserService(
      {required AuthRepository authRepo,
      required TeamIdSharedRefereceRepository teamIdSharedRefRepository,
      required UserApi userApi})
      : _authRepo = authRepo,
        _userApi = userApi,
        _teamIdSharedRefRepository = teamIdSharedRefRepository;

  Future<Either<String, User>> getCurrentUser() async {
    final teamIdOrNone = _teamIdSharedRefRepository.existingTeamId;
    if (teamIdOrNone.isNone()) {
      return left("Team Id is empty");
    }
    final token = await _authRepo.shouldGetToken();
    final userOrError = await _userApi.getUser(teamId: teamIdOrNone.toNullable()!, token: token);
    return userOrError.fold((l) => left(l.message), (r) => right(r));
  }
}

@Riverpod(keepAlive: true)
UserService userService(UserServiceRef ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final teamIdSharedRefRepo = ref.watch(teamIdSharedReferenceRepositoryProvider);
  final userApi = ref.watch(userRepositoryProvider);
  return UserService(authRepo: authRepo, teamIdSharedRefRepository: teamIdSharedRefRepo, userApi: userApi);
}
