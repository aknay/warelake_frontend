import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:warelake/data/bill.account/bill.account.repository.dart';
import 'package:warelake/data/currency.code/valueobject.dart';
import 'package:warelake/data/item/item.repository.dart';
import 'package:warelake/data/team/team.repository.dart';
import 'package:warelake/domain/item/entities.dart';
import 'package:warelake/domain/item/payloads.dart';
import 'package:warelake/domain/item/search.fields.dart';
import 'package:warelake/domain/team/entities.dart';

import '../helpers/sign.in.response.dart';
import '../helpers/test.helper.dart';

void main() async {
  final teamApi = TeamRepository();
  final itemApi = ItemRepository();
  final billAccountApi = BillAccountRepository();
  late String firstUserAccessToken;
  late Item shirtItem;
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
    final team = createdOrError.toIterable().first;
    teamId = team.id!;
    final accountListOrError = await billAccountApi.list(teamId: team.id!, token: firstUserAccessToken);
    expect(accountListOrError.isRight(), true);

    final shirtCreatedOrError =
        await itemApi.createItemRequest(request: getShirtItemRequest(), teamId: team.id!, token: firstUserAccessToken);
    shirtItem = shirtCreatedOrError.toIterable().first;
  });

  test('new item variations can be added after the item is created', () async {
    final salePriceMoney = PriceMoney(amount: 10, currency: "SGD");
    final purchasePriceMoney = PriceMoney(amount: 5, currency: "SGD");

    final greenShirt = ItemVariation.create(
        name: "Green Shirt",
        stockable: true,
        sku: 'sku 123',
        salePriceMoney: salePriceMoney,
        purchasePriceMoney: purchasePriceMoney);

    final updatedOrError = await itemApi.updateItem(
        payload: ItemUpdatePayload(newItemVariationListOrNone: [greenShirt]),
        itemId: shirtItem.id!,
        teamId: teamId,
        token: firstUserAccessToken);

    expect(updatedOrError.isRight(), true);

    {
      //check the item variation is there
      final retrievedItemOrError =
          await itemApi.getItem(itemId: shirtItem.id!, teamId: teamId, token: firstUserAccessToken);
      final newShirtItem = retrievedItemOrError.toIterable().first;

      final itemVariationsOrError = await itemApi.getItemVariationListByItemId(
          itemId: newShirtItem.id!, teamId: teamId, token: firstUserAccessToken);

      expect(itemVariationsOrError.toIterable().first.data.length, 3);
      expect(itemVariationsOrError.toIterable().first.data.where((element) => element.name == 'Green Shirt').isNotEmpty,
          true);
    }
  });

  test('item can be search after the item variations are added to item', () async {
    //TODO: not sure we need this test
    final salePriceMoney = PriceMoney(amount: 10, currency: "SGD");
    final purchasePriceMoney = PriceMoney(amount: 5, currency: "SGD");

    final greenShirt = ItemVariation.create(
        name: "Green Shirt",
        stockable: true,
        sku: 'sku 123',
        salePriceMoney: salePriceMoney,
        purchasePriceMoney: purchasePriceMoney);

    final updatedOrError = await itemApi.updateItem(
        payload: ItemUpdatePayload(newItemVariationListOrNone: [greenShirt]),
        itemId: shirtItem.id!,
        teamId: teamId,
        token: firstUserAccessToken);

    expect(updatedOrError.isRight(), true);

    {
      //you can search a shirt
      final searchField = ItemSearchField(itemName: 'shirt');
      final itemListOrError = await itemApi.getItemList(
        teamId: teamId,
        itemSearchField: searchField,
        token: firstUserAccessToken,
      );
      expect(itemListOrError.isRight(), true);
      expect(itemListOrError.toIterable().first.data.length, 1);
      expect(itemListOrError.toIterable().first.data.first.name, 'shirt');
    }
  });
}
