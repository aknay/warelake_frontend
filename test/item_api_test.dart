import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:inventory_frontend/data/currency.code/valueobject.dart';
import 'package:inventory_frontend/data/item/item.repository.dart';
import 'package:inventory_frontend/data/team/rest.api.dart';
import 'package:inventory_frontend/domain/item/entities.dart';
import 'package:inventory_frontend/domain/item/payloads.dart';
import 'package:inventory_frontend/domain/item/requests.dart';
import 'package:inventory_frontend/domain/team/entities.dart';

import 'helpers/sign.in.response.dart';

void main() async {
  final teamApi = TeamRestApi();
  final itemRepo = ItemRepository();
  late String firstUserAccessToken;

  setUpAll(() async {
    const email = "abc@someemail.com";
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

  test('creating item should be successful', () async {
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
    final shirt = Item.create(name: "shirt", variations: [whiteShrt], unit: 'kg');

    final itemCreated = await itemRepo.createItem(item: shirt, teamId: team.id!, token: firstUserAccessToken);
    expect(itemCreated.isRight(), true);

    final item = itemCreated.toIterable().first;
    expect(item.variations.length, 1);
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
    final shirt = Item.create(name: "shirt", variations: [whiteShrt], unit: 'kg');

    final itemCreated = await itemRepo.createItem(item: shirt, teamId: team.id!, token: firstUserAccessToken);
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
    final shirt = Item.create(name: "shirt", variations: [whiteShrt], unit: 'kg');

    final itemCreated = await itemRepo.createItem(item: shirt, teamId: team.id!, token: firstUserAccessToken);
    expect(itemCreated.isRight(), true);

    final updatedOrError = await itemRepo.editItem(
        payloadItem: PayloadItem(name: "Mango"),
        itemId: itemCreated.toIterable().first.id!,
        teamId: team.id!,
        token: firstUserAccessToken);
    expect(updatedOrError.isRight(), true);

    {
      //check the updated name
      final retrievedItemOrError = await itemRepo.getItem(
          itemId: itemCreated.toIterable().first.id!, teamId: team.id!, token: firstUserAccessToken);
      expect(retrievedItemOrError.toIterable().first.name, "Mango");
    }
  });

  test('you can delete the item', () async {
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
    final shirt = Item.create(name: "shirt", variations: [whiteShrt], unit: 'kg');

    final itemCreated = await itemRepo.createItem(item: shirt, teamId: team.id!, token: firstUserAccessToken);
    expect(itemCreated.isRight(), true);

    {
      //check item list is not empty
      final itemListOrError = await itemRepo.getItemList(teamId: team.id!, token: firstUserAccessToken);
      expect(itemListOrError.isRight(), true);
      expect(itemListOrError.toIterable().first.data.isEmpty, false);
    }

    final deletedOrError = await itemRepo.deleteItem(
        itemId: itemCreated.toIterable().first.id!, teamId: team.id!, token: firstUserAccessToken);
    expect(deletedOrError.isRight(), true);

    {
      //check item list is empty
      final itemListOrError = await itemRepo.getItemList(teamId: team.id!, token: firstUserAccessToken);
      expect(itemListOrError.isRight(), true);
      expect(itemListOrError.toIterable().first.data.isEmpty, true);
    }
  });

  test('you can delete the item variation', () async {
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
    final shirt = Item.create(name: "shirt", variations: [whiteShrt], unit: 'kg');

    final itemCreated = await itemRepo.createItem(item: shirt, teamId: team.id!, token: firstUserAccessToken);
    expect(itemCreated.isRight(), true);

    {
      //check item list is not empty
      final itemListOrError = await itemRepo.getItemList(teamId: team.id!, token: firstUserAccessToken);
      expect(itemListOrError.isRight(), true);
      expect(itemListOrError.toIterable().first.data.isEmpty, false);
      expect(itemListOrError.toIterable().first.data.first.variations.isEmpty, false);
    }
    final retrievedItem = itemCreated.toIterable().first;
    final deletedOrError = await itemRepo.deleteItemVariation(
        itemId: retrievedItem.id!,
        teamId: team.id!,
        token: firstUserAccessToken,
        itemVariationId: retrievedItem.variations.first.id!);
    expect(deletedOrError.isRight(), true);

    {
      //check item list is empty
      final itemListOrError = await itemRepo.getItemList(teamId: team.id!, token: firstUserAccessToken);
      expect(itemListOrError.isRight(), true);
      expect(itemListOrError.toIterable().first.data.isEmpty, false);
      expect(itemListOrError.toIterable().first.data.first.variations.isEmpty, true);
    }
  });

  // we skip this test for now
  test('you can crate image for an item', () async {
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
    final shirt = Item.create(name: "shirt", variations: [whiteShrt], unit: 'kg');

    final itemCreated = await itemRepo.createItem(item: shirt, teamId: team.id!, token: firstUserAccessToken);
    expect(itemCreated.isRight(), true);

    final retrievedItemOrError = await itemRepo.getItem(
        itemId: itemCreated.toIterable().first.id!, teamId: team.id!, token: firstUserAccessToken);
    expect(retrievedItemOrError.isRight(), true);
    final item = retrievedItemOrError.toIterable().first;

//create image
    {
      final whiteShirt = item.variations.first;

      String currentDirectory = Directory.current.path;

      // Construct the path to the image file in the same directory as the test file
      final String imagePath = '$currentDirectory/test/gc.png'; // Adjust the image file name

      final request = ItemVariationImageRequest(
          itemId: item.id!, itemVariationId: whiteShirt.id!, imagePath: File(imagePath), teamId: team.id!);

      final createdImageOrError = await itemRepo.createImage(request: request, token: firstUserAccessToken);

      expect(createdImageOrError.isRight(), true);
    }
  }, skip: true);

  test('you can list item', () async {
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
    final shirt = Item.create(name: "shirt", variations: [whiteShrt], unit: 'kg');

    final itemCreated = await itemRepo.createItem(item: shirt, teamId: team.id!, token: firstUserAccessToken);
    expect(itemCreated.isRight(), true);

    final item = itemCreated.toIterable().first;
    expect(item.variations.length, 1);

    final itemListOrError = await itemRepo.getItemList(teamId: team.id!, token: firstUserAccessToken);
    expect(itemListOrError.isRight(), true);
    expect(itemListOrError.toIterable().first.data.length, 1);
  });

  test('you can list item with pagination', () async {
    final newTeam = Team.create(name: 'Power Ranger', timeZone: "Africa/Abidjan", currencyCode: CurrencyCode.AUD);
    final createdOrError = await teamApi.create(team: newTeam, token: firstUserAccessToken);
    expect(createdOrError.isRight(), true);
    final team = createdOrError.toIterable().first;

    final salePriceMoney = PriceMoney(amount: 10, currency: "SGD");
    final purchasePriceMoney = PriceMoney(amount: 5, currency: "SGD");

    {
      for (int i = 0; i < 6; i++) {
        final whiteShrt = ItemVariation.create(
            name: "White shirt",
            stockable: true,
            sku: '$i sku 123',
            salePriceMoney: salePriceMoney,
            purchasePriceMoney: purchasePriceMoney);
        final shirt = Item.create(name: "shirt", variations: [whiteShrt], unit: 'kg');

        final itemCreated = await itemRepo.createItem(item: shirt, teamId: team.id!, token: firstUserAccessToken);
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

    final whiteShrt = ItemVariation.create(
        name: "White shirt",
        stockable: true,
        sku: 'sku 123',
        salePriceMoney: salePriceMoney,
        purchasePriceMoney: purchasePriceMoney);
    final shirt = Item.create(name: "shirt", variations: [whiteShrt], unit: 'kg');

    final itemCreatedOrError = await itemRepo.createItem(item: shirt, teamId: team.id!, token: firstUserAccessToken);
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
      final itemListOrError = await itemRepo.getItemList(
          teamId: team.id!, token: firstUserAccessToken, startingAfterItemId: itemToCheck.id);
      final itemList = itemListOrError.toIterable().first;
      expect(itemList.data.length, 6);
      expect(itemList.hasMore, false);
    }

    {
      for (int i = 0; i < 5; i++) {
        final whiteShrt = ItemVariation.create(
            name: "White shirt",
            stockable: true,
            sku: '$i sku 123',
            salePriceMoney: salePriceMoney,
            purchasePriceMoney: purchasePriceMoney);
        final shirt = Item.create(name: "shirt", variations: [whiteShrt], unit: 'kg');

        final itemCreated = await itemRepo.createItem(item: shirt, teamId: team.id!, token: firstUserAccessToken);
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
      final itemListOrError = await itemRepo.getItemList(
        teamId: team.id!,
        token: firstUserAccessToken,
        startingAfterItemId: itemToCheck.id,
      );
      final itemList = itemListOrError.toIterable().first;
      expect(itemList.data.length, 6);
      expect(itemList.hasMore, false);
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
    final shirt = Item.create(name: "shirt", variations: [whiteShrt], unit: 'kg');

    final itemCreatedOrError = await itemRepo.createItem(item: shirt, teamId: team.id!, token: firstUserAccessToken);
    expect(itemCreatedOrError.isRight(), true);
    final payload = ItemVariationPayload(name: "Blue shirt", salePrice: 2.5, pruchasePrice: 4.7);
    final item = itemCreatedOrError.toIterable().first;
    final updatedOrError = await itemRepo.updateItemVariation(
        payload: payload,
        itemId: item.id!,
        itemVariationId: item.variations.first.id!,
        teamId: team.id!,
        token: firstUserAccessToken);

    expect(updatedOrError.isRight(), true);

    {
      //get back the updated item
      final itemOrError = await itemRepo.getItem(itemId: item.id!, teamId: team.id!, token: firstUserAccessToken);
      final updatedItem = itemOrError.toIterable().first;
      final updatedItemVariation = updatedItem.variations.first;
      expect(updatedItemVariation.name, "Blue shirt");
      expect(updatedItemVariation.salePriceMoney.amountInDouble, 2.5);
      expect(updatedItemVariation.purchasePriceMoney.amountInDouble, 4.7);
    }
  });
}
