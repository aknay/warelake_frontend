import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:warelake/data/bill.account/bill.account.repository.dart';
import 'package:warelake/data/currency.code/valueobject.dart';
import 'package:warelake/data/item.variation/item.variation.repository.dart';
import 'package:warelake/data/item/item.repository.dart';
import 'package:warelake/data/team/team.repository.dart';
import 'package:warelake/domain/common/entities.dart';
import 'package:warelake/domain/item.utilization/entities.dart';
import 'package:warelake/domain/item.variation/payloads.dart';
import 'package:warelake/domain/item/entities.dart';
import 'package:warelake/domain/item/requests.dart';
import 'package:warelake/domain/item/search.fields.dart';
import 'package:warelake/domain/team/entities.dart';

import '../helpers/sign.in.response.dart';
import '../helpers/test.helper.dart';

void main() async {
  final teamApi = TeamRepository();
  final itemRepo = ItemRepository();
  final itemVariationRepo = ItemVariationRepository();
  final billAccountApi = BillAccountRepository();
  late String firstUserAccessToken;
  late String teamId;
  late Item phoneItem;
  late List<ItemVariation> phoneItemVariations;

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

    final salePriceMoney = PriceMoney(amount: 10, currency: "SGD");
    final purchasePriceMoney = PriceMoney(amount: 5, currency: "SGD");

    final whiteShirt = ItemVariation.create(
      name: "White shirt",
      stockable: true,
      sku: 'sku 123',
      salePriceMoney: salePriceMoney,
      purchasePriceMoney: purchasePriceMoney,
      barcode: '0001',
    );

    final blackShirt = ItemVariation.create(
      name: "Black shirt",
      stockable: true,
      sku: 'sku 123',
      salePriceMoney: salePriceMoney,
      purchasePriceMoney: purchasePriceMoney,
      barcode: '0002',
    );

    final shirt = Item.create(name: "shirt", unit: 'pcs');

    final request = CreateItemRequest(item: shirt, itemVariations: [whiteShirt, blackShirt]);

    final itemCreated = await itemRepo.createItemRequest(request: request, teamId: teamId, token: firstUserAccessToken);
    itemCreated.toIterable().first;

    await Future.delayed(const Duration(seconds: 1));

    final pixel8 = ItemVariation.create(
        name: "Pixel 8",
        stockable: true,
        sku: 'sku 123',
        salePriceMoney: salePriceMoney,
        purchasePriceMoney: purchasePriceMoney,
        barcode: '0003');

    {
      final phones = Item.create(name: "phones", unit: 'pcs');
      final request = CreateItemRequest(item: phones, itemVariations: [pixel8]);

      final itemCreated =
          await itemRepo.createItemRequest(request: request, teamId: teamId, token: firstUserAccessToken);
      phoneItem = itemCreated.toIterable().first;

      final phoneItemVariationsOrError =
          await itemVariationRepo.getItemVariations(itemId: phoneItem.id!, teamId: teamId, token: firstUserAccessToken);
      phoneItemVariations = phoneItemVariationsOrError.toIterable().first;
    }

    {
      await Future.delayed(const Duration(seconds: 1));

      final textbook = ItemVariation.create(
          name: "Text book",
          stockable: true,
          sku: 'sku 123',
          salePriceMoney: salePriceMoney,
          purchasePriceMoney: purchasePriceMoney,
          barcode: '0005');

      final novels = ItemVariation.create(
          name: "Novel",
          stockable: true,
          sku: 'sku 123',
          salePriceMoney: salePriceMoney,
          purchasePriceMoney: purchasePriceMoney,
          barcode: '0006');
      {
        final item = Item.create(name: "books", unit: 'pcs');
        final request = CreateItemRequest(item: item, itemVariations: [textbook, novels]);

        final itemCreated =
            await itemRepo.createItemRequest(request: request, teamId: teamId, token: firstUserAccessToken);

        itemCreated.toIterable().first;
      }
    }
  });

  test('you can list item variation', () async {
    final itemListOrError = await itemVariationRepo.getItemVariationList(teamId: teamId, token: firstUserAccessToken);
    expect(itemListOrError.isRight(), true);
    expect(itemListOrError.toIterable().first.data.length, 5);

    itemListOrError.toIterable().first.data.forEach((element) {
      log(element.name);
      log(element.createdAt!);
    });
  });

  test('you can list item variation with pagination', () async {
    final searchField = ItemVariationSearchField(startingAfterId: phoneItemVariations.first.id);
    final itemListOrError = await itemVariationRepo.getItemVariationList(
        teamId: teamId, token: firstUserAccessToken, searchField: searchField);
    expect(itemListOrError.isRight(), true);

    expect(itemListOrError.toIterable().first.data.length, 2);
  });

  test('you can search item variation by barcode', () async {
    final searchField = ItemVariationSearchField(barcode: '0003');
    final itemListOrError = await itemVariationRepo.getItemVariationList(
        teamId: teamId, token: firstUserAccessToken, searchField: searchField);
    expect(itemListOrError.isRight(), true);
    expect(itemListOrError.toIterable().first.data.length, 1);
    expect(itemListOrError.toIterable().first.data.first.barcode, '0003');
  });

  test('you can still search item variation by barcode after barcode is altered', () async {
    {
      final pixel8 = phoneItemVariations.where((element) => element.name == 'Pixel 8').first;

      final payload = ItemVariationPayload(barcode: const Some('0007'));
      final updatedOrError = await itemVariationRepo.updateItemVariation(
          payload: payload,
          itemId: phoneItem.id!,
          itemVariationId: pixel8.id!,
          teamId: teamId,
          token: firstUserAccessToken);

      expect(updatedOrError.isRight(), true);
    }

    final searchField = ItemVariationSearchField(barcode: '0007');
    final itemListOrError = await itemVariationRepo.getItemVariationList(
        teamId: teamId, token: firstUserAccessToken, searchField: searchField);
    expect(itemListOrError.isRight(), true);
    expect(itemListOrError.toIterable().first.data.length, 1);
    expect(itemListOrError.toIterable().first.data.first.barcode, '0007');
    expect(itemListOrError.toIterable().first.data.first.name, 'Pixel 8');
  });
}
