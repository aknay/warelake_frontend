import 'dart:convert';

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
import 'package:warelake/domain/team/entities.dart';

import '../helpers/sign.in.response.dart';
import '../helpers/test.helper.dart';

void main() async {
  final teamApi = TeamRepository();
  final itemApi = ItemRepository();
  final itemVariationRepo = ItemVariationRepository();
  final billAccountApi = BillAccountRepository();
  late String firstUserAccessToken;
  late String teamId;

  setUpAll(() async {
    final email = generateRandomEmail();
    const password = "nakbi6785!";

    Map<String, dynamic> signUpData = {};
    signUpData["email"] = email;
    signUpData["password"] = password;

    await http.post(
        Uri.parse(
            "http://localhost:9099/identitytoolkit.googleapis.com/v1/accounts:signUp?key=abcdefg"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(signUpData));

    Map<String, dynamic> data = {};
    data["email"] = email;
    data["password"] = password;
    data["returnSecureToken"] = true;

    final response = await http.post(
        Uri.parse(
            "http://localhost:9099/identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=abcdefg"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data));

    final signInResponse = SignInResponse.fromJson(jsonDecode(response.body));

    firstUserAccessToken = signInResponse.idToken!;
  });

  setUp(() async {
    final newTeam = Team.create(
        name: 'Power Ranger',
        timeZone: "Africa/Abidjan",
        currencyCode: CurrencyCode.AUD);
    final createdOrError =
        await teamApi.create(team: newTeam, token: firstUserAccessToken);
    expect(createdOrError.isRight(), true);
    teamId = createdOrError.toIterable().first.id!;

    final accountListOrError =
        await billAccountApi.list(teamId: teamId, token: firstUserAccessToken);
    expect(accountListOrError.isRight(), true);
  });

  test('you can add item without minimum stock', () async {
    final salePriceMoney = PriceMoney(amount: 10, currency: "SGD");
    final purchasePriceMoney = PriceMoney(amount: 5, currency: "SGD");
    List<ItemVariation> itemVariations = [];

    final whiteShrt = ItemVariation.create(
        name: "White Shirt",
        stockable: true,
        sku: 'sku 123',
        salePriceMoney: salePriceMoney,
        purchasePriceMoney: purchasePriceMoney);

    itemVariations.add(whiteShrt);

    final shirt = Item.create(name: "shirt", unit: 'pcs');
    final request =
        CreateItemRequest(item: shirt, itemVariations: itemVariations);

    final itemCreated = await itemApi.createItemRequest(
        request: request, teamId: teamId, token: firstUserAccessToken);
    expect(itemCreated.isRight(), true);
    await Future.delayed(const Duration(seconds: 1));

    {
      //test variation without minimum stock
      final shirt = itemCreated.toIterable().first;
      final shirtVaraiationsOrError = await itemVariationRepo.getItemVariations(
          itemId: shirt.id!, teamId: teamId, token: firstUserAccessToken);
      final shirtVariations = shirtVaraiationsOrError.toIterable().first;
      final whiteShirt = shirtVariations
          .where((element) => element.name == 'White Shirt')
          .first;
      expect(whiteShirt.minimumStockCountOrNone, const None());
    }
  });

  test('you can add item with minimum stock', () async {
    final salePriceMoney = PriceMoney(amount: 10, currency: "SGD");
    final purchasePriceMoney = PriceMoney(amount: 5, currency: "SGD");
    List<ItemVariation> itemVariations = [];

    final whiteShrt = ItemVariation.create(
        name: "White Shirt",
        stockable: true,
        sku: 'sku 123',
        salePriceMoney: salePriceMoney,
        purchasePriceMoney: purchasePriceMoney,
        minimumStock: const Some(5));

    itemVariations.add(whiteShrt);

    final shirt = Item.create(name: "shirt", unit: 'pcs');
    final request =
        CreateItemRequest(item: shirt, itemVariations: itemVariations);

    final itemCreated = await itemApi.createItemRequest(
        request: request, teamId: teamId, token: firstUserAccessToken);
    expect(itemCreated.isRight(), true);
    await Future.delayed(const Duration(seconds: 1));

    {
      //test variation without minimum stock
      final shirt = itemCreated.toIterable().first;
      final shirtVaraiationsOrError = await itemVariationRepo.getItemVariations(
          itemId: shirt.id!, teamId: teamId, token: firstUserAccessToken);
      final shirtVariations = shirtVaraiationsOrError.toIterable().first;
      final whiteShirt = shirtVariations
          .where((element) => element.name == 'White Shirt')
          .first;
      expect(whiteShirt.minimumStockCountOrNone, const Some(5));
    }
  });

  test('you can update item with minimum stock', () async {
    final salePriceMoney = PriceMoney(amount: 10, currency: "SGD");
    final purchasePriceMoney = PriceMoney(amount: 5, currency: "SGD");
    List<ItemVariation> itemVariations = [];

    final whiteShrt = ItemVariation.create(
        name: "White Shirt",
        stockable: true,
        sku: 'sku 123',
        salePriceMoney: salePriceMoney,
        purchasePriceMoney: purchasePriceMoney,
        minimumStock: const Some(5));

    itemVariations.add(whiteShrt);

    final shirt = Item.create(name: "shirt", unit: 'pcs');
    final request =
        CreateItemRequest(item: shirt, itemVariations: itemVariations);

    final itemCreated = await itemApi.createItemRequest(
        request: request, teamId: teamId, token: firstUserAccessToken);
    expect(itemCreated.isRight(), true);
    await Future.delayed(const Duration(seconds: 1));

    {
      //test variation without minimum stock
      final shirt = itemCreated.toIterable().first;
      final shirtVaraiationsOrError = await itemVariationRepo.getItemVariations(
          itemId: shirt.id!, teamId: teamId, token: firstUserAccessToken);
      final shirtVariations = shirtVaraiationsOrError.toIterable().first;
      final whiteShirt = shirtVariations
          .where((element) => element.name == 'White Shirt')
          .first;
      expect(whiteShirt.minimumStockCountOrNone, const Some(5));
    }

    {
      //test you can update the minimum stock
      final shirt = itemCreated.toIterable().first;
      final shirtVaraiationsOrError = await itemVariationRepo.getItemVariations(
          itemId: shirt.id!, teamId: teamId, token: firstUserAccessToken);
      final shirtVariations = shirtVaraiationsOrError.toIterable().first;
      final whiteShirt = shirtVariations
          .where((element) => element.name == 'White Shirt')
          .first;
      final updatedOrError = await itemVariationRepo.updateItemVariation(
          payload: ItemVariationPayload(minimumStockOrNone: const Some(3)),
          itemId: shirt.id!,
          teamId: teamId,
          token: firstUserAccessToken,
          itemVariationId: whiteShirt.id!);
      expect(updatedOrError.isRight(), true);
    }
    {
      final shirt = itemCreated.toIterable().first;
      // check after the update
      final shirtVaraiationsOrError = await itemVariationRepo.getItemVariations(
          itemId: shirt.id!, teamId: teamId, token: firstUserAccessToken);
      final shirtVariations = shirtVaraiationsOrError.toIterable().first;
      final whiteShirt = shirtVariations
          .where((element) => element.name == 'White Shirt')
          .first;

      expect(whiteShirt.minimumStockCountOrNone, const Some(3));
    }
  });

  test('you can update item without minimum stock', () async {
    final salePriceMoney = PriceMoney(amount: 10, currency: "SGD");
    final purchasePriceMoney = PriceMoney(amount: 5, currency: "SGD");
    List<ItemVariation> itemVariations = [];

    final whiteShrt = ItemVariation.create(
        name: "White Shirt",
        stockable: true,
        sku: 'sku 123',
        salePriceMoney: salePriceMoney,
        purchasePriceMoney: purchasePriceMoney,
        minimumStock: const Some(5));

    itemVariations.add(whiteShrt);

    final shirt = Item.create(name: "shirt", unit: 'pcs');
    final request =
        CreateItemRequest(item: shirt, itemVariations: itemVariations);

    final itemCreated = await itemApi.createItemRequest(
        request: request, teamId: teamId, token: firstUserAccessToken);
    expect(itemCreated.isRight(), true);
    await Future.delayed(const Duration(seconds: 1));

    {
      //test variation without minimum stock
      final shirt = itemCreated.toIterable().first;
      final shirtVaraiationsOrError = await itemVariationRepo.getItemVariations(
          itemId: shirt.id!, teamId: teamId, token: firstUserAccessToken);
      final shirtVariations = shirtVaraiationsOrError.toIterable().first;
      final whiteShirt = shirtVariations
          .where((element) => element.name == 'White Shirt')
          .first;
      expect(whiteShirt.minimumStockCountOrNone, const Some(5));
    }

    {
      //test you can update the minimum stock
      final shirt = itemCreated.toIterable().first;
      final shirtVaraiationsOrError = await itemVariationRepo.getItemVariations(
          itemId: shirt.id!, teamId: teamId, token: firstUserAccessToken);
      final shirtVariations = shirtVaraiationsOrError.toIterable().first;
      final whiteShirt = shirtVariations
          .where((element) => element.name == 'White Shirt')
          .first;
      final updatedOrError = await itemVariationRepo.updateItemVariation(
          payload: ItemVariationPayload(minimumStockOrNone: const Some(0)),
          itemId: shirt.id!,
          teamId: teamId,
          token: firstUserAccessToken,
          itemVariationId: whiteShirt.id!);
      expect(updatedOrError.isRight(), true);
    }
    {
      final shirt = itemCreated.toIterable().first;
      // check after the update
      final shirtVaraiationsOrError = await itemVariationRepo.getItemVariations(
          itemId: shirt.id!, teamId: teamId, token: firstUserAccessToken);
      final shirtVariations = shirtVaraiationsOrError.toIterable().first;
      final whiteShirt = shirtVariations
          .where((element) => element.name == 'White Shirt')
          .first;

      expect(whiteShirt.minimumStockCountOrNone, const None());
    }
  });

  test('it will be empty list items which have no minimum stock', () async {
    final salePriceMoney = PriceMoney(amount: 10, currency: "SGD");
    final purchasePriceMoney = PriceMoney(amount: 5, currency: "SGD");
    List<ItemVariation> itemVariations = [];

    final whiteShrt = ItemVariation.create(
        name: "White Shirt",
        stockable: true,
        sku: 'sku 123',
        salePriceMoney: salePriceMoney,
        purchasePriceMoney: purchasePriceMoney);

    itemVariations.add(whiteShrt);

    final shirt = Item.create(name: "shirt", unit: 'pcs');
    final request =
        CreateItemRequest(item: shirt, itemVariations: itemVariations);

    final itemCreated = await itemApi.createItemRequest(
        request: request, teamId: teamId, token: firstUserAccessToken);
    expect(itemCreated.isRight(), true);
    await Future.delayed(const Duration(seconds: 1));

    {
      //test variation without minimum stock
      final shirt = itemCreated.toIterable().first;
      final shirtVaraiationsOrError = await itemVariationRepo.getItemVariations(
          itemId: shirt.id!, teamId: teamId, token: firstUserAccessToken);
      final shirtVariations = shirtVaraiationsOrError.toIterable().first;
      final whiteShirt = shirtVariations
          .where((element) => element.name == 'White Shirt')
          .first;
      expect(whiteShirt.minimumStockCountOrNone, const None());
    }
    {
      final lowStockItemVariationListOrError =
          await itemVariationRepo.getLowLevelItemVariationList(
              teamId: teamId, token: firstUserAccessToken);
      expect(lowStockItemVariationListOrError.isRight(), true);
      final lowStockItemVariations =
          lowStockItemVariationListOrError.toIterable().first;
      expect(lowStockItemVariations.data.isEmpty, true);
    }
  });

  test('it will be a list items which one minimum stock', () async {
    final salePriceMoney = PriceMoney(amount: 10, currency: "SGD");
    final purchasePriceMoney = PriceMoney(amount: 5, currency: "SGD");
    List<ItemVariation> itemVariations = [];

    final whiteShrt = ItemVariation.create(
        name: "White Shirt",
        stockable: true,
        sku: 'sku 123',
        salePriceMoney: salePriceMoney,
        purchasePriceMoney: purchasePriceMoney,
        minimumStock: const Some(5));

    itemVariations.add(whiteShrt);

    final shirt = Item.create(name: "shirt", unit: 'pcs');
    final request =
        CreateItemRequest(item: shirt, itemVariations: itemVariations);

    final itemCreated = await itemApi.createItemRequest(
        request: request, teamId: teamId, token: firstUserAccessToken);
    expect(itemCreated.isRight(), true);
    await Future.delayed(const Duration(seconds: 1));

    {
      //test variation without minimum stock
      final shirt = itemCreated.toIterable().first;
      final shirtVaraiationsOrError = await itemVariationRepo.getItemVariations(
          itemId: shirt.id!, teamId: teamId, token: firstUserAccessToken);
      final shirtVariations = shirtVaraiationsOrError.toIterable().first;
      final whiteShirt = shirtVariations
          .where((element) => element.name == 'White Shirt')
          .first;
      expect(whiteShirt.minimumStockCountOrNone, const Some(5));
    }
    {
      final lowStockItemVariationListOrError =
          await itemVariationRepo.getLowLevelItemVariationList(
              teamId: teamId, token: firstUserAccessToken);
      expect(lowStockItemVariationListOrError.isRight(), true);
      final lowStockItemVariations =
          lowStockItemVariationListOrError.toIterable().first;
      expect(lowStockItemVariations.data.isNotEmpty, true);
      expect(lowStockItemVariations.data.first.name, "White Shirt");
    }
  });
}
