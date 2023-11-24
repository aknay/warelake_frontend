import 'package:inventory_frontend/data/auth/firebase.auth.repository.dart';
import 'package:inventory_frontend/data/item/item.repository.dart';
import 'package:inventory_frontend/data/onboarding/team.id.shared.ref.repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'item.service.g.dart';

class ItemService {
  final AuthRepository authRepo;
  final TeamIdSharedRefereceRepository teamIdSharedRefRepository;
  final ItemRepository itemRepo;
  ItemService({required this.authRepo, required this.teamIdSharedRefRepository, required this.itemRepo});
}

@Riverpod(keepAlive: true)
ItemService itemService(ItemServiceRef ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final teamIdSharedRefRepo = ref.watch(teamIdSharedReferenceRepositoryProvider);
  final itemRepo = ref.watch(itemRepositoryProvider);
  return ItemService(authRepo: authRepo, teamIdSharedRefRepository: teamIdSharedRefRepo, itemRepo: itemRepo);
}
