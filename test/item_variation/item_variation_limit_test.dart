import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:warelake/data/bill.account/bill.account.repository.dart';
import 'package:warelake/data/currency.code/valueobject.dart';
import 'package:warelake/data/item/item.repository.dart';
import 'package:warelake/data/team/team.repository.dart';
import 'package:warelake/domain/errors/response.dart';
import 'package:warelake/domain/item/entities.dart';
import 'package:warelake/domain/item/requests.dart';
import 'package:warelake/domain/team/entities.dart';

import '../helpers/sign.in.response.dart';
import '../helpers/test.helper.dart';

void main() async {
  final teamApi = TeamRepository();
  final itemRepo = ItemRepository();
  final billAccountApi = BillAccountRepository();
  late String firstUserAccessToken;
  late String teamId;

  setUpAll(() async {
    final email = generateRandomEmail();
    const password = "nakbi6785!";

    Map<String, dynamic> signUpData = {};
    signUpData["email"] = email;
    signUpData["password"] = password;

    await http.post(Uri.parse("http://localhost:9099/identitytoolkit.googleapis.com/v1/accounts:signUp?key=abcdefg"),
        headers: {"Content-Type": "application/json"}, body: jsonEncode(signUpData));

    Map<String, dynamic> data = {};
    data["email"] = email;
    data["password"] = password;
    data["returnSecureToken"] = true;

    final response = await http.post(
        Uri.parse("http://localhost:9099/identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=abcdefg"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data));

    final signInResponse = SignInResponse.fromJson(jsonDecode(response.body));

    firstUserAccessToken = signInResponse.idToken!;
  });

  setUp(() async {
    final newTeam = Team.create(name: 'Power Ranger', timeZone: "Africa/Abidjan", currencyCode: CurrencyCode.AUD);
    final createdOrError = await teamApi.create(team: newTeam, token: firstUserAccessToken);
    expect(createdOrError.isRight(), true);
    teamId = createdOrError.toIterable().first.id!;
    final accountListOrError = await billAccountApi.list(teamId: teamId, token: firstUserAccessToken);
    expect(accountListOrError.isRight(), true);
  });

  test('you can add 100 item variations', () async {
    final newTeam = Team.create(name: 'Power Ranger', timeZone: "Africa/Abidjan", currencyCode: CurrencyCode.AUD);
    final createdOrError = await teamApi.create(team: newTeam, token: firstUserAccessToken);
    expect(createdOrError.isRight(), true);
    final team = createdOrError.toIterable().first;

    final salePriceMoney = PriceMoney(amount: 10, currency: "SGD");
    final purchasePriceMoney = PriceMoney(amount: 5, currency: "SGD");
    List<ItemVariation> itemVariations = [];
    {
      for (int i = 0; i < 100; i++) {
        final whiteShrt = ItemVariation.create(
            name: "White shirt",
            stockable: true,
            sku: '$i sku 123',
            salePriceMoney: salePriceMoney,
            purchasePriceMoney: purchasePriceMoney);

        itemVariations.add(whiteShrt);
      }
      final shirt = Item.create(name: "shirt", variations: itemVariations, unit: 'pcs');
      final request = CreateItemRequest(item: shirt, itemVariations: itemVariations);

      final itemCreated =
          await itemRepo.createItemRequest(request: request, teamId: team.id!, token: firstUserAccessToken);
      expect(itemCreated.isRight(), true);
      await Future.delayed(const Duration(seconds: 1));
    }

    {
      final itemListOrError = await itemRepo.getItemList(teamId: team.id!, token: firstUserAccessToken);
      final itemList = itemListOrError.toIterable().first;
      expect(itemList.data.length, 1);
      expect(itemList.hasMore, false);
    }
  });

  test('you cannot add more than 100 item variations', () async {
    final newTeam = Team.create(name: 'Power Ranger', timeZone: "Africa/Abidjan", currencyCode: CurrencyCode.AUD);
    final createdOrError = await teamApi.create(team: newTeam, token: firstUserAccessToken);
    expect(createdOrError.isRight(), true);
    final team = createdOrError.toIterable().first;

    final salePriceMoney = PriceMoney(amount: 10, currency: "SGD");
    final purchasePriceMoney = PriceMoney(amount: 5, currency: "SGD");
    List<ItemVariation> itemVariations = [];
    {
      for (int i = 0; i < 100; i++) {
        final whiteShrt = ItemVariation.create(
            name: "White shirt",
            stockable: true,
            sku: '$i sku 123',
            salePriceMoney: salePriceMoney,
            purchasePriceMoney: purchasePriceMoney);

        itemVariations.add(whiteShrt);
      }
      final shirt = Item.create(name: "shirt", variations: itemVariations, unit: 'pcs');
      final request = CreateItemRequest(item: shirt, itemVariations: itemVariations);

      final itemCreated =
          await itemRepo.createItemRequest(request: request, teamId: team.id!, token: firstUserAccessToken);
      expect(itemCreated.isRight(), true);
      await Future.delayed(const Duration(seconds: 1));
    }
    {
      for (int i = 0; i < 1; i++) {
        final whiteShrt = ItemVariation.create(
            name: "White shirt",
            stockable: true,
            sku: '$i sku 123',
            salePriceMoney: salePriceMoney,
            purchasePriceMoney: purchasePriceMoney);

        itemVariations.add(whiteShrt);
      }
      final shirt = Item.create(name: "shirt", variations: itemVariations, unit: 'pcs');
      final request = CreateItemRequest(item: shirt, itemVariations: itemVariations);

      final itemCreated =
          await itemRepo.createItemRequest(request: request, teamId: team.id!, token: firstUserAccessToken);
      expect(itemCreated.isLeft(), true);
      itemCreated.fold((l) {
        expect(l.code, ErrorCode.itemVarationForPersonalPlanLimitExecced);
      }, (r) => null);
    }
  });
}
