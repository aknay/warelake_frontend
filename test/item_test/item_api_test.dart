import 'dart:convert';

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
import 'package:warelake/domain/item/payloads.dart';
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

  test('creating item should be successful', () async {
    final request = getShirtItemRequest();
    final itemCreated = await itemRepo.createItemRequest(request: request, teamId: teamId, token: firstUserAccessToken);
    expect(itemCreated.isRight(), true);

    {
      // item utilization must be zero when there is no item added
      final iuOrError = await itemRepo.getItemUtilization(teamId: teamId, token: firstUserAccessToken);
      expect(iuOrError.isRight(), true);
      expect(iuOrError.toIterable().first.totalItemVariationsCount, 2);
      expect(iuOrError.toIterable().first.totalItemCount, 1);
      expect(iuOrError.toIterable().first.totalQuantityOfAllItemVariation, 0);
    }
  });

  test('you can get back the item', () async {
    final newTeam = Team.create(name: 'Power Ranger', timeZone: "Africa/Abidjan", currencyCode: CurrencyCode.AUD);
    final createdOrError = await teamApi.create(team: newTeam, token: firstUserAccessToken);
    expect(createdOrError.isRight(), true);
    final team = createdOrError.toIterable().first;

    final salePriceMoney = PriceMoney(amount: 10, currency: "SGD");
    final purchasePriceMoney = PriceMoney(amount: 5, currency: "SGD");

    final whiteShrt = ItemVariation.create(
        name: "White shirt",
        stockable: true,
        sku: 'sku 123',
        salePriceMoney: salePriceMoney,
        purchasePriceMoney: purchasePriceMoney);
    final shirt = Item.create(name: "shirt", unit: 'kg');

    final request = CreateItemRequest(item: shirt, itemVariations: [whiteShrt]);

    final itemCreated =
        await itemRepo.createItemRequest(request: request, teamId: team.id!, token: firstUserAccessToken);
    expect(itemCreated.isRight(), true);

    final retrievedItemOrError = await itemRepo.getItem(
        itemId: itemCreated.toIterable().first.id!, teamId: team.id!, token: firstUserAccessToken);
    expect(retrievedItemOrError.isRight(), true);
  });

  test('you can update the item', () async {
    final newTeam = Team.create(name: 'Power Ranger', timeZone: "Africa/Abidjan", currencyCode: CurrencyCode.AUD);
    final createdOrError = await teamApi.create(team: newTeam, token: firstUserAccessToken);
    expect(createdOrError.isRight(), true);
    final team = createdOrError.toIterable().first;

    final salePriceMoney = PriceMoney(amount: 10, currency: "SGD");
    final purchasePriceMoney = PriceMoney(amount: 5, currency: "SGD");

    final whiteShrt = ItemVariation.create(
        name: "White shirt",
        stockable: true,
        sku: 'sku 123',
        salePriceMoney: salePriceMoney,
        purchasePriceMoney: purchasePriceMoney);
    final shirt = Item.create(name: "shirt", unit: 'pcs');

    final request = CreateItemRequest(item: shirt, itemVariations: [whiteShrt]);

    final itemCreated =
        await itemRepo.createItemRequest(request: request, teamId: team.id!, token: firstUserAccessToken);
    expect(itemCreated.isRight(), true);

    final updatedOrError = await itemRepo.updateItem(
        payload: ItemUpdatePayload(name: "Mango", unit: "Kg"),
        itemId: itemCreated.toIterable().first.id!,
        teamId: team.id!,
        token: firstUserAccessToken);
    expect(updatedOrError.isRight(), true);

    {
      //check the updated name
      final retrievedItemOrError = await itemRepo.getItem(
          itemId: itemCreated.toIterable().first.id!, teamId: team.id!, token: firstUserAccessToken);
      expect(retrievedItemOrError.toIterable().first.name, "Mango");
      expect(retrievedItemOrError.toIterable().first.unit, "Kg");
    }
  });

  test('you can delete the item', () async {
    final request = CreateItemRequest(item: getShirt(), itemVariations: [getWhiteShirt(), getBlackShirt()]);
    final itemCreated = await itemRepo.createItemRequest(request: request, teamId: teamId, token: firstUserAccessToken);
    expect(itemCreated.isRight(), true);

    {
      //check item list is not empty
      final itemListOrError = await itemRepo.getItemList(teamId: teamId, token: firstUserAccessToken);
      expect(itemListOrError.isRight(), true);
      expect(itemListOrError.toIterable().first.data.isEmpty, false);
    }

    {
      //check item variations before delete
      final itemVariaitonsOrError = await itemVariationRepo.getItemVariationList(teamId: teamId, token: firstUserAccessToken);
      expect(itemVariaitonsOrError.toIterable().first.data.length, 2);
    }

    final deletedOrError = await itemRepo.deleteItem(
        itemId: itemCreated.toIterable().first.id!, teamId: teamId, token: firstUserAccessToken);
    expect(deletedOrError.isRight(), true);

    {
      //check item list is empty
      final itemListOrError = await itemRepo.getItemList(teamId: teamId, token: firstUserAccessToken);
      expect(itemListOrError.isRight(), true);
      expect(itemListOrError.toIterable().first.data.isEmpty, true);
    }
    {
      // item utilization must be zero after deleted
      final iuOrError = await itemRepo.getItemUtilization(teamId: teamId, token: firstUserAccessToken);
      expect(iuOrError.isRight(), true);
      expect(iuOrError.toIterable().first.totalItemVariationsCount, 0);
      expect(iuOrError.toIterable().first.totalItemCount, 0);
      expect(iuOrError.toIterable().first.totalQuantityOfAllItemVariation, 0);
    }

    {
      //check item variations after delete
      final itemVariaitonsOrError = await itemVariationRepo.getItemVariationList(teamId: teamId, token: firstUserAccessToken);
      expect(itemVariaitonsOrError.toIterable().first.data.isEmpty, true);
    }
  });

  test('you can delete the item variation', () async {
    final request = CreateItemRequest(item: getShirt(), itemVariations: [getWhiteShirt(), getBlackShirt()]);
    final itemCreated = await itemRepo.createItemRequest(request: request, teamId: teamId, token: firstUserAccessToken);

    expect(itemCreated.isRight(), true);

    final itemVariationsOrError = await itemVariationRepo.getItemVariationListByItemId(
        teamId: teamId, itemId: itemCreated.toIterable().first.id!, token: firstUserAccessToken);
    final itemVariations = itemVariationsOrError.toIterable().first;
    {
      //check item list is not empty
      expect(itemVariations.data.isNotEmpty, true);
    }

    {
      //check item variations list before deleting
      final itemVariationsOrError = await itemVariationRepo.getItemVariations(
          itemId: itemCreated.toIterable().first.id!, teamId: teamId, token: firstUserAccessToken);
      expect(itemVariationsOrError.isRight(), true);
      expect(itemVariationsOrError.toIterable().first.length, 2);
    }
    final retrievedItem = itemCreated.toIterable().first;
    final deletedOrError = await itemVariationRepo.deleteItemVariation(
      itemId: retrievedItem.id!,
      teamId: teamId,
      token: firstUserAccessToken,
      itemVariationId: itemVariations.data.first.id!,
    );
    expect(deletedOrError.isRight(), true);

    {
      // item utilization must be 1 after only one deleted
      final iuOrError = await itemRepo.getItemUtilization(teamId: teamId, token: firstUserAccessToken);
      expect(iuOrError.isRight(), true);
      expect(iuOrError.toIterable().first.totalItemVariationsCount, 1);
      expect(iuOrError.toIterable().first.totalItemCount, 1);
      expect(iuOrError.toIterable().first.totalQuantityOfAllItemVariation, 0);
    }

    {
      //check item variations list after the delete
      final itemVariationsOrError = await itemVariationRepo.getItemVariations(
          itemId: itemCreated.toIterable().first.id!, teamId: teamId, token: firstUserAccessToken);
      expect(itemVariationsOrError.isRight(), true);
      expect(itemVariationsOrError.toIterable().first.length, 1);
    }
  });

  test('you can list item', () async {
    final newTeam = Team.create(name: 'Power Ranger', timeZone: "Africa/Abidjan", currencyCode: CurrencyCode.AUD);
    final createdOrError = await teamApi.create(team: newTeam, token: firstUserAccessToken);
    expect(createdOrError.isRight(), true);
    final team = createdOrError.toIterable().first;

    final request = CreateItemRequest(item: getShirt(), itemVariations: [getWhiteShirt(), getBlackShirt()]);
    final itemCreated =
        await itemRepo.createItemRequest(request: request, teamId: team.id!, token: firstUserAccessToken);
    expect(itemCreated.isRight(), true);

    final itemListOrError = await itemRepo.getItemList(teamId: team.id!, token: firstUserAccessToken);
    expect(itemListOrError.isRight(), true);
    expect(itemListOrError.toIterable().first.data.length, 1);
  });

  test('you can list item with pagination', () async {
    final newTeam = Team.create(name: 'Power Ranger', timeZone: "Africa/Abidjan", currencyCode: CurrencyCode.AUD);
    final createdOrError = await teamApi.create(team: newTeam, token: firstUserAccessToken);
    expect(createdOrError.isRight(), true);
    final team = createdOrError.toIterable().first;

    {
      for (int i = 0; i < 6; i++) {
        final request = CreateItemRequest(item: getShirt(), itemVariations: [getWhiteShirt(), getBlackShirt()]);

        final itemCreated =
            await itemRepo.createItemRequest(request: request, teamId: team.id!, token: firstUserAccessToken);
        expect(itemCreated.isRight(), true);
        await Future.delayed(const Duration(seconds: 1));
      }
    }

    {
      final itemListOrError = await itemRepo.getItemList(teamId: team.id!, token: firstUserAccessToken);
      final itemList = itemListOrError.toIterable().first;
      expect(itemList.data.length, 6);
      expect(itemList.hasMore, false);
    }

    final request = CreateItemRequest(item: getShirt(), itemVariations: [getWhiteShirt(), getBlackShirt()]);

    final itemCreatedOrError =
        await itemRepo.createItemRequest(request: request, teamId: team.id!, token: firstUserAccessToken);
    expect(itemCreatedOrError.isRight(), true);
    final itemToCheck = itemCreatedOrError.toIterable().first;
    await Future.delayed(const Duration(seconds: 1));

    {
      final itemListOrError = await itemRepo.getItemList(teamId: team.id!, token: firstUserAccessToken);
      final itemList = itemListOrError.toIterable().first;
      expect(itemList.data.length, 7);
      expect(itemList.hasMore, false);
    }

    {
      final searchField = ItemSearchField(startingAfterItemId: itemToCheck.id);
      final itemListOrError =
          await itemRepo.getItemList(teamId: team.id!, token: firstUserAccessToken, itemSearchField: searchField);
      final itemList = itemListOrError.toIterable().first;
      expect(itemList.data.length, 6);
      expect(itemList.hasMore, false);
    }

    {
      for (int i = 0; i < 5; i++) {
        final request = CreateItemRequest(item: getShirt(), itemVariations: [getWhiteShirt(), getBlackShirt()]);
        final itemCreated =
            await itemRepo.createItemRequest(request: request, teamId: team.id!, token: firstUserAccessToken);
        expect(itemCreated.isRight(), true);
        await Future.delayed(const Duration(seconds: 1));
      }
    }

    {
      final itemListOrError = await itemRepo.getItemList(teamId: team.id!, token: firstUserAccessToken);
      final itemList = itemListOrError.toIterable().first;
      expect(itemList.data.length, 10);
      expect(itemList.hasMore, true);
    }

    {
      final searchField = ItemSearchField(startingAfterItemId: itemToCheck.id);
      final itemListOrError = await itemRepo.getItemList(
        teamId: team.id!,
        token: firstUserAccessToken,
        itemSearchField: searchField,
      );
      final itemList = itemListOrError.toIterable().first;
      expect(itemList.data.length, 6);
      expect(itemList.hasMore, false);
    }
  });

  test('you can find items', () async {
    final newTeam = Team.create(name: 'Power Ranger', timeZone: "Africa/Abidjan", currencyCode: CurrencyCode.AUD);
    final createdOrError = await teamApi.create(team: newTeam, token: firstUserAccessToken);
    expect(createdOrError.isRight(), true);
    final team = createdOrError.toIterable().first;

    {
      final salePriceMoney = PriceMoney(amount: 10, currency: "SGD");
      final purchasePriceMoney = PriceMoney(amount: 5, currency: "SGD");

      final whiteShrt = ItemVariation.create(
          name: "White shirt",
          stockable: true,
          sku: 'sku 123',
          salePriceMoney: salePriceMoney,
          purchasePriceMoney: purchasePriceMoney);
      // final shirt = Item.create(name: "shirt", variations: [whiteShrt], unit: 'pcs');
      final request = CreateItemRequest(item: getShirt(), itemVariations: [whiteShrt]);
      final itemCreated =
          await itemRepo.createItemRequest(request: request, teamId: team.id!, token: firstUserAccessToken);
      expect(itemCreated.isRight(), true);
    }
    {
      final salePriceMoney = PriceMoney(amount: 10, currency: "SGD");
      final purchasePriceMoney = PriceMoney(amount: 5, currency: "SGD");

      final dryMango = ItemVariation.create(
          name: "Dry Mango",
          stockable: true,
          sku: 'sku 123',
          salePriceMoney: salePriceMoney,
          purchasePriceMoney: purchasePriceMoney);
      final shirt = Item.create(name: "Mango", unit: 'kg');
      final request = CreateItemRequest(item: shirt, itemVariations: [dryMango]);
      final itemCreated =
          await itemRepo.createItemRequest(request: request, teamId: team.id!, token: firstUserAccessToken);
      // final itemCreated = await itemRepo.createItem(item: shirt, teamId: team.id!, token: firstUserAccessToken);
      expect(itemCreated.isRight(), true);
    }
    {
      //you can list all
      final itemListOrError = await itemRepo.getItemList(teamId: team.id!, token: firstUserAccessToken);
      expect(itemListOrError.isRight(), true);
      expect(itemListOrError.toIterable().first.data.length, 2);
    }

    {
      //you can search a shirt
      final searchField = ItemSearchField(itemName: 'hir');
      final itemListOrError = await itemRepo.getItemList(
        teamId: team.id!,
        itemSearchField: searchField,
        token: firstUserAccessToken,
      );
      expect(itemListOrError.isRight(), true);
      expect(itemListOrError.toIterable().first.data.length, 1);
      expect(itemListOrError.toIterable().first.data.first.name, 'shirt');
    }

    {
      //you can search a mango
      final searchField = ItemSearchField(itemName: 'ang');
      final itemListOrError = await itemRepo.getItemList(
        teamId: team.id!,
        itemSearchField: searchField,
        token: firstUserAccessToken,
      );
      expect(itemListOrError.isRight(), true);
      expect(itemListOrError.toIterable().first.data.length, 1);
      expect(itemListOrError.toIterable().first.data.first.name, 'Mango');
    }
  });

  test('you can edit the item variation', () async {
    final newTeam = Team.create(name: 'Power Ranger', timeZone: "Africa/Abidjan", currencyCode: CurrencyCode.AUD);
    final createdOrError = await teamApi.create(team: newTeam, token: firstUserAccessToken);
    expect(createdOrError.isRight(), true);
    final team = createdOrError.toIterable().first;

    final salePriceMoney = PriceMoney(amount: 10, currency: "SGD");
    final purchasePriceMoney = PriceMoney(amount: 5, currency: "SGD");

    final whiteShrt = ItemVariation.create(
        name: "White shirt",
        stockable: true,
        sku: 'sku 123',
        salePriceMoney: salePriceMoney,
        purchasePriceMoney: purchasePriceMoney);
    final shirt = Item.create(name: "shirt", unit: 'kg');

    final request = CreateItemRequest(item: shirt, itemVariations: [whiteShrt]);
    final itemCreatedOrError =
        await itemRepo.createItemRequest(request: request, teamId: team.id!, token: firstUserAccessToken);

    // final itemCreatedOrError = await itemRepo.createItem(item: shirt, teamId: team.id!, token: firstUserAccessToken);
    expect(itemCreatedOrError.isRight(), true);
    final payload = ItemVariationPayload(name: "Blue shirt", salePrice: 2.5, pruchasePrice: 4.7);
    final item = itemCreatedOrError.toIterable().first;

    final itemVariationsOrError = await itemVariationRepo.getItemVariationListByItemId(
        teamId: team.id!, itemId: itemCreatedOrError.toIterable().first.id!, token: firstUserAccessToken);
    final itemVariations = itemVariationsOrError.toIterable().first;

    final updatedOrError = await itemVariationRepo.updateItemVariation(
        payload: payload,
        itemId: item.id!,
        itemVariationId: itemVariations.data.first.id!,
        teamId: team.id!,
        token: firstUserAccessToken);

    expect(updatedOrError.isRight(), true);

    {
      //get back the updated item
      final itemVariationsOrError = await itemVariationRepo.getItemVariationListByItemId(
          teamId: team.id!, itemId: itemCreatedOrError.toIterable().first.id!, token: firstUserAccessToken);
      final itemVariation = itemVariationsOrError.toIterable().first.data.first;
      expect(itemVariation.name, "Blue shirt");
      expect(itemVariation.salePriceMoney.amountInDouble, 2.5);
      expect(itemVariation.purchasePriceMoney.amountInDouble, 4.7);
    }

    // {
    //   //get back the updated item
    //   final itemOrError = await itemRepo.getItem(itemId: item.id!, teamId: team.id!, token: firstUserAccessToken);
    //   final updatedItem = itemOrError.toIterable().first;
    //   final updatedItemVariation = updatedItem.variations.first;
    //   expect(updatedItemVariation.name, "Blue shirt");
    //   expect(updatedItemVariation.salePriceMoney.amountInDouble, 2.5);
    //   expect(updatedItemVariation.purchasePriceMoney.amountInDouble, 4.7);
    // }
  });

  test('you can still search the item by name after the name is changed', () async {
    final newTeam = Team.create(name: 'Power Ranger', timeZone: "Africa/Abidjan", currencyCode: CurrencyCode.AUD);
    final createdOrError = await teamApi.create(team: newTeam, token: firstUserAccessToken);
    expect(createdOrError.isRight(), true);
    final team = createdOrError.toIterable().first;

    final salePriceMoney = PriceMoney(amount: 10, currency: "SGD");
    final purchasePriceMoney = PriceMoney(amount: 5, currency: "SGD");

    final whiteShrt = ItemVariation.create(
        name: "White shirt",
        stockable: true,
        sku: 'sku 123',
        salePriceMoney: salePriceMoney,
        purchasePriceMoney: purchasePriceMoney);
    final shirt = Item.create(name: "Shirt", unit: 'kg');
    final request = CreateItemRequest(item: shirt, itemVariations: [whiteShrt]);
    final itemCreated =
        await itemRepo.createItemRequest(request: request, teamId: team.id!, token: firstUserAccessToken);
    expect(itemCreated.isRight(), true);

    {
      //you can search a shirt
      final searchField = ItemSearchField(itemName: 'irt');
      final itemListOrError = await itemRepo.getItemList(
        teamId: team.id!,
        itemSearchField: searchField,
        token: firstUserAccessToken,
      );
      expect(itemListOrError.isRight(), true);
      expect(itemListOrError.toIterable().first.data.length, 1);
      expect(itemListOrError.toIterable().first.data.first.name, 'Shirt');
    }
    {
      //we updated the item name as Mango
      final updatedOrError = await itemRepo.updateItem(
          payload: ItemUpdatePayload(name: "Mango"),
          itemId: itemCreated.toIterable().first.id!,
          teamId: team.id!,
          token: firstUserAccessToken);
      expect(updatedOrError.isRight(), true);
    }

    {
      //check the updated name is Mango
      final retrievedItemOrError = await itemRepo.getItem(
          itemId: itemCreated.toIterable().first.id!, teamId: team.id!, token: firstUserAccessToken);
      expect(retrievedItemOrError.toIterable().first.name, "Mango");
    }

    {
      //you can search a Mango as updated name
      final searchField = ItemSearchField(itemName: 'ang');
      final itemListOrError = await itemRepo.getItemList(
        teamId: team.id!,
        itemSearchField: searchField,
        token: firstUserAccessToken,
      );
      expect(itemListOrError.isRight(), true);
      expect(itemListOrError.toIterable().first.data.length, 1);
      expect(itemListOrError.toIterable().first.data.first.name, 'Mango');
    }
  });
}
