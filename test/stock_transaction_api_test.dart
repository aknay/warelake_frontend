import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:warelake/data/currency.code/valueobject.dart';
import 'package:warelake/data/item/item.repository.dart';
import 'package:warelake/data/stock.transaction/stock.transaction.repository.dart';
import 'package:warelake/data/team/team.repository.dart';
import 'package:warelake/domain/item/entities.dart';
import 'package:warelake/domain/stock.transaction/entities.dart';
import 'package:warelake/domain/stock.transaction/search.field.dart';
import 'package:warelake/domain/team/entities.dart';

import 'helpers/sign.in.response.dart';
import 'helpers/test.helper.dart';

void main() async {
  final teamApi = TeamRepository();
  final itemApi = ItemRepository();
  final stockTransactionRepo = StockTransactionRepository();
  late String firstUserAccessToken;

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

  test('creating stx wiht stock in should be successful', () async {
    final newTeam = Team.create(name: 'Power Ranger', timeZone: "Africa/Abidjan", currencyCode: CurrencyCode.AUD);
    final createdOrError = await teamApi.create(team: newTeam, token: firstUserAccessToken);
    expect(createdOrError.isRight(), true);
    final team = createdOrError.toIterable().first;

    final shirt = getShirt();
    final jean = getJean();

    final shirtCreatedOrError = await itemApi.createItem(item: shirt, teamId: team.id!, token: firstUserAccessToken);
    final shirtCreated = shirtCreatedOrError.toIterable().first;

    final jeansCreatedOrError = await itemApi.createItem(item: jean, teamId: team.id!, token: firstUserAccessToken);
    final jeanCreated = jeansCreatedOrError.toIterable().first;

    final lineItems = getStocklLineItemWithRandomCount(createdItemList: [shirtCreated, jeanCreated]);

    final rawTx = StockTransaction.create(
      date: DateTime.now(),
      lineItems: lineItems,
      stockMovement: StockMovement.stockIn,
    );
    final stCreatedOrError =
        await stockTransactionRepo.create(stockTransaction: rawTx, teamId: team.id!, token: firstUserAccessToken);

    expect(stCreatedOrError.isRight(), true);

    final stx = stCreatedOrError.toIterable().first;
    {
      final retrivedWhiteShirt = stx.lineItems.where((element) => element.itemVariation.name == "White Shirt").first;
      final retrivedBlackShirt = stx.lineItems.where((element) => element.itemVariation.name == "Black Shirt").first;

      final whiteShirtLineItem = lineItems.where((e) => e.itemVariation.name == "White Shirt").first;
      final blackShirtLineItem = lineItems.where((e) => e.itemVariation.name == "Black Shirt").first;

      expect(retrivedWhiteShirt.quantity, whiteShirtLineItem.quantity);
      expect(retrivedWhiteShirt.oldStockLevel, 0);
      expect(retrivedWhiteShirt.newStockLevel, whiteShirtLineItem.quantity);
      expect(retrivedBlackShirt.quantity, blackShirtLineItem.quantity);
      expect(retrivedBlackShirt.oldStockLevel, 0);
      expect(retrivedBlackShirt.newStockLevel, blackShirtLineItem.quantity);
    }

    {
      // item utilization toal quatity of all item variation should be same as total line item
      final total = lineItems.map((e) => e.quantity).fold(0, (previousValue, element) => previousValue + element);

      final iuOrError = await itemApi.getItemUtilization(teamId: team.id!, token: firstUserAccessToken);
      expect(iuOrError.isRight(), true);
      expect(iuOrError.toIterable().first.totalQuantityOfAllItemVariation, total);
    }
  });

  test('creating stx with different date', () async {
    final newTeam = Team.create(name: 'Power Ranger', timeZone: "Africa/Abidjan", currencyCode: CurrencyCode.AUD);
    final createdOrError = await teamApi.create(team: newTeam, token: firstUserAccessToken);
    expect(createdOrError.isRight(), true);
    final team = createdOrError.toIterable().first;

    final shirt = getShirt();
    final jean = getJean();

    final shirtCreatedOrError = await itemApi.createItem(item: shirt, teamId: team.id!, token: firstUserAccessToken);
    final shirtCreated = shirtCreatedOrError.toIterable().first;

    final jeansCreatedOrError = await itemApi.createItem(item: jean, teamId: team.id!, token: firstUserAccessToken);
    final jeanCreated = jeansCreatedOrError.toIterable().first;

    final lineItems = getStocklLineItemWithRandomCount(createdItemList: [shirtCreated, jeanCreated]);

    final rawTx = StockTransaction.create(
      date: DateTime(2024, 1, 3, 9, 8, 7),
      lineItems: lineItems,
      stockMovement: StockMovement.stockIn,
    );
    final stCreatedOrError =
        await stockTransactionRepo.create(stockTransaction: rawTx, teamId: team.id!, token: firstUserAccessToken);

    expect(stCreatedOrError.isRight(), true);

    final stx = stCreatedOrError.toIterable().first;
    expect(stx.createdTime, DateTime(2024, 1, 3, 9, 8, 7));
  });

  test('you can get back the created stock transaction', () async {
    final newTeam = Team.create(name: 'Power Ranger', timeZone: "Africa/Abidjan", currencyCode: CurrencyCode.AUD);
    final createdOrError = await teamApi.create(team: newTeam, token: firstUserAccessToken);
    expect(createdOrError.isRight(), true);
    final team = createdOrError.toIterable().first;

    final salePriceMoney = PriceMoney(amount: 10, currency: "SGD");
    final purchasePriceMoney = PriceMoney(amount: 5, currency: "SGD");

    final whiteShirt = ItemVariation.create(
        name: "White shirt",
        stockable: true,
        sku: 'sku 123',
        salePriceMoney: salePriceMoney,
        purchasePriceMoney: purchasePriceMoney);

    final blackShirt = ItemVariation.create(
        name: "Black shirt",
        stockable: true,
        sku: 'sku 123',
        salePriceMoney: salePriceMoney,
        purchasePriceMoney: purchasePriceMoney);
    final shirt = Item.create(name: "shirt", variations: [whiteShirt, blackShirt], unit: 'kg');

    final itemCreated = await itemApi.createItem(item: shirt, teamId: team.id!, token: firstUserAccessToken);
    expect(itemCreated.isRight(), true);

    final retrievedShirts = itemCreated.toIterable().first.variations;
    final retrievedWhiteShirt = retrievedShirts.where((element) => element.name == "White shirt").first;
    final retrievedBlackShirt = retrievedShirts.where((element) => element.name == "Black shirt").first;

    final lineItems = [
      StockLineItem.create(itemVariation: retrievedWhiteShirt, quantity: 2),
      StockLineItem.create(itemVariation: retrievedBlackShirt, quantity: 3)
    ];

    final rawTx = StockTransaction.create(
      date: DateTime.now(),
      lineItems: lineItems,
      stockMovement: StockMovement.stockIn,
    );
    final stCreatedOrError =
        await stockTransactionRepo.create(stockTransaction: rawTx, teamId: team.id!, token: firstUserAccessToken);

    expect(stCreatedOrError.isRight(), true);

    final createdStx = stCreatedOrError.toIterable().first;
    {
      final stxOrError = await stockTransactionRepo.get(
          stockTransactionId: createdStx.id!, teamId: team.id!, token: firstUserAccessToken);
      final stx = stxOrError.toIterable().first;
      final retrivedWhiteShirt = stx.lineItems.where((element) => element.itemVariation.name == "White shirt").first;
      final retrivedBlackShirt = stx.lineItems.where((element) => element.itemVariation.name == "Black shirt").first;
      expect(retrivedWhiteShirt.quantity, 2);
      expect(retrivedWhiteShirt.oldStockLevel, 0);
      expect(retrivedWhiteShirt.newStockLevel, 2);
      expect(retrivedBlackShirt.quantity, 3);
      expect(retrivedBlackShirt.oldStockLevel, 0);
      expect(retrivedBlackShirt.newStockLevel, 3);
    }
  });

  test('creating stx with stock out should be successful', () async {
    final newTeam = Team.create(name: 'Power Ranger', timeZone: "Africa/Abidjan", currencyCode: CurrencyCode.AUD);
    final createdOrError = await teamApi.create(team: newTeam, token: firstUserAccessToken);
    expect(createdOrError.isRight(), true);
    final team = createdOrError.toIterable().first;

    final shirt = getShirt();
    final jean = getJean();

    final shirtCreatedOrError = await itemApi.createItem(item: shirt, teamId: team.id!, token: firstUserAccessToken);
    final shirtCreated = shirtCreatedOrError.toIterable().first;

    final jeansCreatedOrError = await itemApi.createItem(item: jean, teamId: team.id!, token: firstUserAccessToken);
    final jeanCreated = jeansCreatedOrError.toIterable().first;

    final stockInLineItems = getStocklLineItemWithRandomCount(createdItemList: [shirtCreated, jeanCreated]);

    final rawTx = StockTransaction.create(
      date: DateTime.now(),
      lineItems: stockInLineItems,
      stockMovement: StockMovement.stockIn,
    );
    final stCreatedOrError =
        await stockTransactionRepo.create(stockTransaction: rawTx, teamId: team.id!, token: firstUserAccessToken);

    expect(stCreatedOrError.isRight(), true);

    final stockInStx = stCreatedOrError.toIterable().first;
    final retrievedStxInWhiteShirtLineItem =
        stockInStx.lineItems.where((element) => element.itemVariation.name == "White Shirt").first;
    final retrievedStxInBlackShirtLineItem =
        stockInStx.lineItems.where((element) => element.itemVariation.name == "Black Shirt").first;

    final stockOutLineItems = getStocklLineItemWithRandomCount(createdItemList: [shirtCreated, jeanCreated]);
    {
      final rawTx = StockTransaction.create(
        date: DateTime.now(),
        lineItems: stockOutLineItems,
        stockMovement: StockMovement.stockOut,
      );
      final stCreatedOrError =
          await stockTransactionRepo.create(stockTransaction: rawTx, teamId: team.id!, token: firstUserAccessToken);
      expect(stCreatedOrError.isRight(), true);
      final stx = stCreatedOrError.toIterable().first;
      final retrivedWhiteShirt = stx.lineItems.where((element) => element.itemVariation.name == "White Shirt").first;
      final retrivedBlackShirt = stx.lineItems.where((element) => element.itemVariation.name == "Black Shirt").first;

      final whiteShirtLineItem = stockOutLineItems.where((e) => e.itemVariation.name == "White Shirt").first;
      final blackShirtLineItem = stockOutLineItems.where((e) => e.itemVariation.name == "Black Shirt").first;

      expect(retrivedWhiteShirt.quantity, whiteShirtLineItem.quantity);
      expect(retrivedWhiteShirt.oldStockLevel, retrievedStxInWhiteShirtLineItem.quantity);
      expect(retrivedWhiteShirt.newStockLevel, retrievedStxInWhiteShirtLineItem.quantity - whiteShirtLineItem.quantity);
      expect(retrivedBlackShirt.quantity, blackShirtLineItem.quantity);
      expect(retrivedBlackShirt.oldStockLevel, retrievedStxInBlackShirtLineItem.quantity);
      expect(retrivedBlackShirt.newStockLevel, retrievedStxInBlackShirtLineItem.quantity - blackShirtLineItem.quantity);
    }
    {
      // item utilization toal quatity of all item variation should be same as total line item
      final totalStockOut =
          stockOutLineItems.map((e) => e.quantity).fold(0, (previousValue, element) => previousValue + element);
      final totalStockIn =
          stockInLineItems.map((e) => e.quantity).fold(0, (previousValue, element) => previousValue + element);
      final iuOrError = await itemApi.getItemUtilization(teamId: team.id!, token: firstUserAccessToken);
      expect(iuOrError.isRight(), true);
      expect(iuOrError.toIterable().first.totalQuantityOfAllItemVariation, totalStockIn - totalStockOut);
    }
  });

  test('creating stx with stock adjust should be successful', () async {
    final newTeam = Team.create(name: 'Power Ranger', timeZone: "Africa/Abidjan", currencyCode: CurrencyCode.AUD);
    final createdOrError = await teamApi.create(team: newTeam, token: firstUserAccessToken);
    expect(createdOrError.isRight(), true);
    final team = createdOrError.toIterable().first;

    final shirt = getShirt();
    final jean = getJean();

    final shirtCreatedOrError = await itemApi.createItem(item: shirt, teamId: team.id!, token: firstUserAccessToken);
    final shirtCreated = shirtCreatedOrError.toIterable().first;

    final jeansCreatedOrError = await itemApi.createItem(item: jean, teamId: team.id!, token: firstUserAccessToken);
    final jeanCreated = jeansCreatedOrError.toIterable().first;

    final stockInLineItems = getStockLineItem(items: [Tuple2(10, shirtCreated), Tuple2(20, jeanCreated)]);

    final rawTx = StockTransaction.create(
      date: DateTime.now(),
      lineItems: stockInLineItems,
      stockMovement: StockMovement.stockIn,
    );
    final stCreatedOrError =
        await stockTransactionRepo.create(stockTransaction: rawTx, teamId: team.id!, token: firstUserAccessToken);

    expect(stCreatedOrError.isRight(), true);

    final stockInStx = stCreatedOrError.toIterable().first;
    final retrievedStxInWhiteShirtLineItem =
        stockInStx.lineItems.where((element) => element.itemVariation.name == "White Shirt").first;
    final retrievedStxInBlackShirtLineItem =
        stockInStx.lineItems.where((element) => element.itemVariation.name == "Black Shirt").first;

    final stockOutLineItems = getStockLineItem(items: [Tuple2(5, shirtCreated), Tuple2(10, jeanCreated)]);
    StockTransaction stockOut;
    {
      final rawTx = StockTransaction.create(
        date: DateTime.now(),
        lineItems: stockOutLineItems,
        stockMovement: StockMovement.stockOut,
      );
      final stCreatedOrError =
          await stockTransactionRepo.create(stockTransaction: rawTx, teamId: team.id!, token: firstUserAccessToken);
      expect(stCreatedOrError.isRight(), true);
      stockOut = stCreatedOrError.toIterable().first;
      final retrivedWhiteShirt =
          stockOut.lineItems.where((element) => element.itemVariation.name == "White Shirt").first;
      final retrivedBlackShirt =
          stockOut.lineItems.where((element) => element.itemVariation.name == "Black Shirt").first;

      final whiteShirtLineItem = stockOutLineItems.where((e) => e.itemVariation.name == "White Shirt").first;
      final blackShirtLineItem = stockOutLineItems.where((e) => e.itemVariation.name == "Black Shirt").first;

      expect(retrivedWhiteShirt.quantity, whiteShirtLineItem.quantity);
      expect(retrivedWhiteShirt.oldStockLevel, retrievedStxInWhiteShirtLineItem.quantity);
      expect(retrivedWhiteShirt.newStockLevel, retrievedStxInWhiteShirtLineItem.quantity - whiteShirtLineItem.quantity);
      expect(retrivedBlackShirt.quantity, blackShirtLineItem.quantity);
      expect(retrivedBlackShirt.oldStockLevel, retrievedStxInBlackShirtLineItem.quantity);
      expect(retrivedBlackShirt.newStockLevel, retrievedStxInBlackShirtLineItem.quantity - blackShirtLineItem.quantity);
    }
    {
      // item utilization toal quatity of all item variation should be same as total line item
      final totalStockOut =
          stockOutLineItems.map((e) => e.quantity).fold(0, (previousValue, element) => previousValue + element);
      final totalStockIn =
          stockInLineItems.map((e) => e.quantity).fold(0, (previousValue, element) => previousValue + element);
      final iuOrError = await itemApi.getItemUtilization(teamId: team.id!, token: firstUserAccessToken);
      expect(iuOrError.isRight(), true);
      expect(iuOrError.toIterable().first.totalQuantityOfAllItemVariation, totalStockIn - totalStockOut);
    }

    {
      final stockAdjustLineItems = getStockLineItem(items: [Tuple2(7, shirtCreated)]);
      final rawTx = StockTransaction.create(
        date: DateTime.now(),
        lineItems: stockAdjustLineItems,
        stockMovement: StockMovement.stockAdjust,
      );

      final stCreatedOrError =
          await stockTransactionRepo.create(stockTransaction: rawTx, teamId: team.id!, token: firstUserAccessToken);
      expect(stCreatedOrError.isRight(), true);

      final stx = stCreatedOrError.toIterable().first;
      final retrivedWhiteShirt = stx.lineItems.where((element) => element.itemVariation.name == "White Shirt").first;
      final retrivedBlackShirt = stx.lineItems.where((element) => element.itemVariation.name == "Black Shirt").first;

      final whiteShirtLineItem = stockAdjustLineItems.where((e) => e.itemVariation.name == "White Shirt").first;
      final blackShirtLineItem = stockAdjustLineItems.where((e) => e.itemVariation.name == "Black Shirt").first;

      final whiteShirtStockOutLineItem = stockOut.lineItems.where((e) => e.itemVariation.name == "White Shirt").first;
      final blackShirtStockOutLineItem = stockOut.lineItems.where((e) => e.itemVariation.name == "Black Shirt").first;

      expect(retrivedWhiteShirt.quantity, whiteShirtLineItem.quantity);
      expect(retrivedWhiteShirt.oldStockLevel, whiteShirtStockOutLineItem.newStockLevel);
      expect(retrivedWhiteShirt.newStockLevel, whiteShirtLineItem.quantity);
      expect(retrivedBlackShirt.quantity, blackShirtLineItem.quantity);
      expect(retrivedBlackShirt.oldStockLevel, blackShirtStockOutLineItem.newStockLevel);
      expect(retrivedBlackShirt.newStockLevel, blackShirtLineItem.quantity);
    }

    {
      final iuOrError = await itemApi.getItemUtilization(teamId: team.id!, token: firstUserAccessToken);
      expect(iuOrError.isRight(), true);
      expect(iuOrError.toIterable().first.totalQuantityOfAllItemVariation, 34);
    }
  });

  test('creating stx with stock adjust should be successful', () async {
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

    final itemCreated = await itemApi.createItem(item: shirt, teamId: team.id!, token: firstUserAccessToken);
    expect(itemCreated.isRight(), true);
    final tShirtItem = itemCreated.toIterable().first;

    final retrievedWhiteShirt = itemCreated.toIterable().first.variations.first;

    final lineItem = StockLineItem.create(itemVariation: retrievedWhiteShirt, quantity: 7);

    final rawTx = StockTransaction.create(
      date: DateTime.now(),
      lineItems: [lineItem],
      stockMovement: StockMovement.stockIn,
    );
    final stCreatedOrError =
        await stockTransactionRepo.create(stockTransaction: rawTx, teamId: team.id!, token: firstUserAccessToken);

    expect(stCreatedOrError.isRight(), true);

    final stx = stCreatedOrError.toIterable().first;
    expect(stx.lineItems.first.quantity, 7);
    expect(stx.lineItems.first.oldStockLevel, 0);
    expect(stx.lineItems.first.newStockLevel, 7);

    {
      //check item stock is updated
      final itemOrError = await itemApi.getItem(itemId: tShirtItem.id!, teamId: team.id!, token: firstUserAccessToken);
      final item = itemOrError.toIterable().first;
      final whiteTShirt = item.variations.first;
      expect(whiteTShirt.itemCount, 7);
    }

    {
      final lineItem = StockLineItem.create(itemVariation: retrievedWhiteShirt, quantity: 3);
      final rawTx = StockTransaction.create(
        date: DateTime.now(),
        lineItems: [lineItem],
        stockMovement: StockMovement.stockOut,
      );
      final stCreatedOrError =
          await stockTransactionRepo.create(stockTransaction: rawTx, teamId: team.id!, token: firstUserAccessToken);

      expect(stCreatedOrError.isRight(), true);

      final stx = stCreatedOrError.toIterable().first;
      expect(stx.lineItems.first.quantity, 3);
      expect(stx.lineItems.first.oldStockLevel, 7);
      expect(stx.lineItems.first.newStockLevel, 4);

      {
        //check item stock is updated
        final itemOrError =
            await itemApi.getItem(itemId: tShirtItem.id!, teamId: team.id!, token: firstUserAccessToken);
        final item = itemOrError.toIterable().first;
        final whiteTShirt = item.variations.first;
        expect(whiteTShirt.itemCount, 4);
      }
    }

    {
      final lineItem = StockLineItem.create(itemVariation: retrievedWhiteShirt, quantity: 10);
      final rawTx = StockTransaction.create(
        date: DateTime.now(),
        lineItems: [lineItem],
        stockMovement: StockMovement.stockAdjust,
      );
      final stCreatedOrError =
          await stockTransactionRepo.create(stockTransaction: rawTx, teamId: team.id!, token: firstUserAccessToken);

      expect(stCreatedOrError.isRight(), true);

      final stx = stCreatedOrError.toIterable().first;
      expect(stx.lineItems.first.quantity, 10);
      expect(stx.lineItems.first.oldStockLevel, 4);
      expect(stx.lineItems.first.newStockLevel, 10);

      {
        //check item stock is updated
        final itemOrError =
            await itemApi.getItem(itemId: tShirtItem.id!, teamId: team.id!, token: firstUserAccessToken);
        final item = itemOrError.toIterable().first;
        final whiteTShirt = item.variations.first;
        expect(whiteTShirt.itemCount, 10);
      }
    }
  });

  test('after transaction is deleted, it will not be shown in the list', () async {
    final newTeam = Team.create(name: 'Power Ranger', timeZone: "Africa/Abidjan", currencyCode: CurrencyCode.AUD);
    final createdOrError = await teamApi.create(team: newTeam, token: firstUserAccessToken);
    expect(createdOrError.isRight(), true);
    final team = createdOrError.toIterable().first;

    final shirt = getShirt();
    final jean = getJean();

    final shirtCreatedOrError = await itemApi.createItem(item: shirt, teamId: team.id!, token: firstUserAccessToken);
    final shirtCreated = shirtCreatedOrError.toIterable().first;

    final jeansCreatedOrError = await itemApi.createItem(item: jean, teamId: team.id!, token: firstUserAccessToken);
    final jeanCreated = jeansCreatedOrError.toIterable().first;
    StockTransaction stockInTransaction;
    {
      //stock in
      final stockInLineItems = getStockLineItem(items: [Tuple2(10, shirtCreated), Tuple2(20, jeanCreated)]);

      final rawTx = StockTransaction.create(
        date: DateTime.now(),
        lineItems: stockInLineItems,
        stockMovement: StockMovement.stockIn,
      );
      final stCreatedOrError =
          await stockTransactionRepo.create(stockTransaction: rawTx, teamId: team.id!, token: firstUserAccessToken);

      stockInTransaction = stCreatedOrError.toIterable().first;
    }

    {
      //delete stock in
      final deletedOrError = await stockTransactionRepo.delete(
          stockTransactionId: stockInTransaction.id!, teamId: team.id!, token: firstUserAccessToken);
      expect(deletedOrError.isRight(), true);
    }
    {
      // check in the list
      final stockTransactionOrError = await stockTransactionRepo.list(teamId: team.id!, token: firstUserAccessToken);
      expect(stockTransactionOrError.toIterable().first.data.isEmpty, true);
    }
  });

  test('deleting stx with stock in: totalQuantityOfAllItemVariation should be correct', () async {
    //TODO
    final newTeam = Team.create(name: 'Power Ranger', timeZone: "Africa/Abidjan", currencyCode: CurrencyCode.AUD);
    final createdOrError = await teamApi.create(team: newTeam, token: firstUserAccessToken);
    expect(createdOrError.isRight(), true);
    final team = createdOrError.toIterable().first;

    final shirt = getShirt();
    final jean = getJean();

    final shirtCreatedOrError = await itemApi.createItem(item: shirt, teamId: team.id!, token: firstUserAccessToken);
    final shirtCreated = shirtCreatedOrError.toIterable().first;

    final jeansCreatedOrError = await itemApi.createItem(item: jean, teamId: team.id!, token: firstUserAccessToken);
    final jeanCreated = jeansCreatedOrError.toIterable().first;
    StockTransaction stockInTransaction;
    {
      //stock in
      final stockInLineItems = getStockLineItem(items: [Tuple2(10, shirtCreated), Tuple2(20, jeanCreated)]);

      final rawTx = StockTransaction.create(
        date: DateTime.now(),
        lineItems: stockInLineItems,
        stockMovement: StockMovement.stockIn,
      );
      final stCreatedOrError =
          await stockTransactionRepo.create(stockTransaction: rawTx, teamId: team.id!, token: firstUserAccessToken);

      // expect(stCreatedOrError.isRight(), true);

      stockInTransaction = stCreatedOrError.toIterable().first;
    }

    {
      //stock out
      final stockOutLineItems = getStockLineItem(items: [Tuple2(5, shirtCreated), Tuple2(10, jeanCreated)]);

      final rawTx = StockTransaction.create(
        date: DateTime.now(),
        lineItems: stockOutLineItems,
        stockMovement: StockMovement.stockOut,
      );
      final stCreatedOrError =
          await stockTransactionRepo.create(stockTransaction: rawTx, teamId: team.id!, token: firstUserAccessToken);
      expect(stCreatedOrError.isRight(), true);
    }
    {
      //delete stock in
      final deletedOrError = await stockTransactionRepo.delete(
          stockTransactionId: stockInTransaction.id!, teamId: team.id!, token: firstUserAccessToken);
      expect(deletedOrError.isRight(), true);
    }
    {
      final iuOrError = await itemApi.getItemUtilization(teamId: team.id!, token: firstUserAccessToken);
      expect(iuOrError.isRight(), true);
      expect(iuOrError.toIterable().first.totalQuantityOfAllItemVariation, -30);
    }
  });

  test('deleting stx with stock out: totalQuantityOfAllItemVariation should be correct', () async {
    //TODO
    final newTeam = Team.create(name: 'Power Ranger', timeZone: "Africa/Abidjan", currencyCode: CurrencyCode.AUD);
    final createdOrError = await teamApi.create(team: newTeam, token: firstUserAccessToken);
    expect(createdOrError.isRight(), true);
    final team = createdOrError.toIterable().first;

    final shirt = getShirt();
    final jean = getJean();

    final shirtCreatedOrError = await itemApi.createItem(item: shirt, teamId: team.id!, token: firstUserAccessToken);
    final shirtCreated = shirtCreatedOrError.toIterable().first;

    final jeansCreatedOrError = await itemApi.createItem(item: jean, teamId: team.id!, token: firstUserAccessToken);
    final jeanCreated = jeansCreatedOrError.toIterable().first;
    {
      //stock in
      final stockInLineItems = getStockLineItem(items: [Tuple2(10, shirtCreated), Tuple2(20, jeanCreated)]);

      final rawTx = StockTransaction.create(
        date: DateTime.now(),
        lineItems: stockInLineItems,
        stockMovement: StockMovement.stockIn,
      );
      final stCreatedOrError =
          await stockTransactionRepo.create(stockTransaction: rawTx, teamId: team.id!, token: firstUserAccessToken);

      expect(stCreatedOrError.isRight(), true);
    }

    StockTransaction stockOutTransaction;
    {
      //stock out
      final stockOutLineItems = getStockLineItem(items: [Tuple2(5, shirtCreated)]);

      final rawTx = StockTransaction.create(
        date: DateTime.now(),
        lineItems: stockOutLineItems,
        stockMovement: StockMovement.stockOut,
      );
      final stCreatedOrError =
          await stockTransactionRepo.create(stockTransaction: rawTx, teamId: team.id!, token: firstUserAccessToken);
      expect(stCreatedOrError.isRight(), true);
      stockOutTransaction = stCreatedOrError.toIterable().first;
    }
    {
      //delete stock in
      final deletedOrError = await stockTransactionRepo.delete(
          stockTransactionId: stockOutTransaction.id!, teamId: team.id!, token: firstUserAccessToken);
      expect(deletedOrError.isRight(), true);
    }
    {
      final iuOrError = await itemApi.getItemUtilization(teamId: team.id!, token: firstUserAccessToken);
      expect(iuOrError.isRight(), true);
      expect(iuOrError.toIterable().first.totalQuantityOfAllItemVariation, 60);
    }
  });

  test('deleting stx with stock adjust: totalQuantityOfAllItemVariation should be correct', () async {
    final newTeam = Team.create(name: 'Power Ranger', timeZone: "Africa/Abidjan", currencyCode: CurrencyCode.AUD);
    final createdOrError = await teamApi.create(team: newTeam, token: firstUserAccessToken);
    expect(createdOrError.isRight(), true);
    final team = createdOrError.toIterable().first;

    final shirt = getShirt();
    final jean = getJean();

    final shirtCreatedOrError = await itemApi.createItem(item: shirt, teamId: team.id!, token: firstUserAccessToken);
    final shirtCreated = shirtCreatedOrError.toIterable().first;

    final jeansCreatedOrError = await itemApi.createItem(item: jean, teamId: team.id!, token: firstUserAccessToken);
    final jeanCreated = jeansCreatedOrError.toIterable().first;
    {
      //stock in
      final stockInLineItems = getStockLineItem(items: [Tuple2(10, shirtCreated), Tuple2(20, jeanCreated)]);

      final rawTx = StockTransaction.create(
        date: DateTime.now(),
        lineItems: stockInLineItems,
        stockMovement: StockMovement.stockIn,
      );
      final stCreatedOrError =
          await stockTransactionRepo.create(stockTransaction: rawTx, teamId: team.id!, token: firstUserAccessToken);

      expect(stCreatedOrError.isRight(), true);
    }

    {
      //stock out
      final stockOutLineItems = getStockLineItem(items: [Tuple2(5, shirtCreated)]);

      final rawTx = StockTransaction.create(
        date: DateTime.now(),
        lineItems: stockOutLineItems,
        stockMovement: StockMovement.stockOut,
      );
      final stCreatedOrError =
          await stockTransactionRepo.create(stockTransaction: rawTx, teamId: team.id!, token: firstUserAccessToken);
      expect(stCreatedOrError.isRight(), true);
    }

    StockTransaction stockAdjustTransaction;
    {
      //stock out
      final stockOutLineItems = getStockLineItem(items: [Tuple2(7, shirtCreated)]);

      final rawTx = StockTransaction.create(
        date: DateTime.now(),
        lineItems: stockOutLineItems,
        stockMovement: StockMovement.stockAdjust,
      );
      final stCreatedOrError =
          await stockTransactionRepo.create(stockTransaction: rawTx, teamId: team.id!, token: firstUserAccessToken);
      expect(stCreatedOrError.isRight(), true);
      stockAdjustTransaction = stCreatedOrError.toIterable().first;
    }
    {
      //delete stock adjust
      final deletedOrError = await stockTransactionRepo.delete(
          stockTransactionId: stockAdjustTransaction.id!, teamId: team.id!, token: firstUserAccessToken);
      expect(deletedOrError.isRight(), true);
    }
    {
      final iuOrError = await itemApi.getItemUtilization(teamId: team.id!, token: firstUserAccessToken);
      expect(iuOrError.isRight(), true);
      expect(iuOrError.toIterable().first.totalQuantityOfAllItemVariation, 50);
    }
  });

  test('delete stx with stock adjust should be successful', () async {
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

    final itemCreated = await itemApi.createItem(item: shirt, teamId: team.id!, token: firstUserAccessToken);
    expect(itemCreated.isRight(), true);
    final tShirtItem = itemCreated.toIterable().first;

    final retrievedWhiteShirt = itemCreated.toIterable().first.variations.first;

    final lineItem = StockLineItem.create(itemVariation: retrievedWhiteShirt, quantity: 7);

    final rawTx = StockTransaction.create(
      date: DateTime.now(),
      lineItems: [lineItem],
      stockMovement: StockMovement.stockIn,
    );
    final stCreatedOrError =
        await stockTransactionRepo.create(stockTransaction: rawTx, teamId: team.id!, token: firstUserAccessToken);

    expect(stCreatedOrError.isRight(), true);

    final stxWithStockIn = stCreatedOrError.toIterable().first;
    expect(stxWithStockIn.lineItems.first.quantity, 7);
    expect(stxWithStockIn.lineItems.first.oldStockLevel, 0);
    expect(stxWithStockIn.lineItems.first.newStockLevel, 7);

    {
      //check item stock is updated
      final itemOrError = await itemApi.getItem(itemId: tShirtItem.id!, teamId: team.id!, token: firstUserAccessToken);
      final item = itemOrError.toIterable().first;
      final whiteTShirt = item.variations.first;
      expect(whiteTShirt.itemCount, 7);
    }
    StockTransaction stxWithStockOut;
    {
      final lineItem = StockLineItem.create(itemVariation: retrievedWhiteShirt, quantity: 3);
      final rawTx = StockTransaction.create(
        date: DateTime.now(),
        lineItems: [lineItem],
        stockMovement: StockMovement.stockOut,
      );
      final stCreatedOrError =
          await stockTransactionRepo.create(stockTransaction: rawTx, teamId: team.id!, token: firstUserAccessToken);

      expect(stCreatedOrError.isRight(), true);

      stxWithStockOut = stCreatedOrError.toIterable().first;
      expect(stxWithStockOut.lineItems.first.quantity, 3);
      expect(stxWithStockOut.lineItems.first.oldStockLevel, 7);
      expect(stxWithStockOut.lineItems.first.newStockLevel, 4);

      {
        //check item stock is updated
        final itemOrError =
            await itemApi.getItem(itemId: tShirtItem.id!, teamId: team.id!, token: firstUserAccessToken);
        final item = itemOrError.toIterable().first;
        final whiteTShirt = item.variations.first;
        expect(whiteTShirt.itemCount, 4);
      }
    }
    StockTransaction stxWithStockAdjust;
    {
      final lineItem = StockLineItem.create(itemVariation: retrievedWhiteShirt, quantity: 10);
      final rawTx = StockTransaction.create(
        date: DateTime.now(),
        lineItems: [lineItem],
        stockMovement: StockMovement.stockAdjust,
      );
      final stCreatedOrError =
          await stockTransactionRepo.create(stockTransaction: rawTx, teamId: team.id!, token: firstUserAccessToken);

      expect(stCreatedOrError.isRight(), true);

      stxWithStockAdjust = stCreatedOrError.toIterable().first;
      expect(stxWithStockAdjust.lineItems.first.quantity, 10);
      expect(stxWithStockAdjust.lineItems.first.oldStockLevel, 4);
      expect(stxWithStockAdjust.lineItems.first.newStockLevel, 10);

      {
        //check item stock is updated
        final itemOrError =
            await itemApi.getItem(itemId: tShirtItem.id!, teamId: team.id!, token: firstUserAccessToken);
        final item = itemOrError.toIterable().first;
        final whiteTShirt = item.variations.first;
        expect(whiteTShirt.itemCount, 10);
      }
    }

    {
      final deletedOrError = await stockTransactionRepo.delete(
          stockTransactionId: stxWithStockAdjust.id!, teamId: team.id!, token: firstUserAccessToken);

      expect(deletedOrError.isRight(), true);

      //check item stock is updated
      final itemOrError = await itemApi.getItem(itemId: tShirtItem.id!, teamId: team.id!, token: firstUserAccessToken);
      final item = itemOrError.toIterable().first;
      final whiteTShirt = item.variations.first;
      expect(whiteTShirt.itemCount, 4);
    }

    {
      //delete stock out transaction and check item count

      final deletedOrError = await stockTransactionRepo.delete(
          stockTransactionId: stxWithStockOut.id!, teamId: team.id!, token: firstUserAccessToken);

      expect(deletedOrError.isRight(), true);

      //check item stock is updated
      final itemOrError = await itemApi.getItem(itemId: tShirtItem.id!, teamId: team.id!, token: firstUserAccessToken);
      final item = itemOrError.toIterable().first;
      final whiteTShirt = item.variations.first;
      expect(whiteTShirt.itemCount, 7);
    }

    {
      //delete stock in transaction and check item count

      final deletedOrError = await stockTransactionRepo.delete(
          stockTransactionId: stxWithStockIn.id!, teamId: team.id!, token: firstUserAccessToken);

      expect(deletedOrError.isRight(), true);

      //check item stock is updated
      final itemOrError = await itemApi.getItem(itemId: tShirtItem.id!, teamId: team.id!, token: firstUserAccessToken);
      final item = itemOrError.toIterable().first;
      final whiteTShirt = item.variations.first;
      expect(whiteTShirt.itemCount, 0);
    }
  });

  test('you can list stock transactions', () async {
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

    final itemCreated = await itemApi.createItem(item: shirt, teamId: team.id!, token: firstUserAccessToken);
    expect(itemCreated.isRight(), true);
    final tShirtItem = itemCreated.toIterable().first;

    final retrievedWhiteShirt = itemCreated.toIterable().first.variations.first;

    final lineItem = StockLineItem.create(itemVariation: retrievedWhiteShirt, quantity: 7);

    final rawTx = StockTransaction.create(
      date: DateTime.now(),
      lineItems: [lineItem],
      stockMovement: StockMovement.stockIn,
    );
    final stCreatedOrError =
        await stockTransactionRepo.create(stockTransaction: rawTx, teamId: team.id!, token: firstUserAccessToken);

    expect(stCreatedOrError.isRight(), true);

    final stx = stCreatedOrError.toIterable().first;
    expect(stx.lineItems.first.quantity, 7);
    expect(stx.lineItems.first.oldStockLevel, 0);
    expect(stx.lineItems.first.newStockLevel, 7);

    {
      //check item stock is updated
      final itemOrError = await itemApi.getItem(itemId: tShirtItem.id!, teamId: team.id!, token: firstUserAccessToken);
      final item = itemOrError.toIterable().first;
      final whiteTShirt = item.variations.first;
      expect(whiteTShirt.itemCount, 7);
    }
    {
      final stockTransactionListOrError =
          await stockTransactionRepo.list(teamId: team.id!, token: firstUserAccessToken);
      expect(stockTransactionListOrError.isRight(), true);
    }
  });

  test('you can paginate stock transactions', () async {
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

    final itemCreated = await itemApi.createItem(item: shirt, teamId: team.id!, token: firstUserAccessToken);
    expect(itemCreated.isRight(), true);
    final tShirtItem = itemCreated.toIterable().first;

    final retrievedWhiteShirt = itemCreated.toIterable().first.variations.first;

    final lineItem = StockLineItem.create(itemVariation: retrievedWhiteShirt, quantity: 7);

    {
      for (int i = 0; i < 5; i++) {
        final rawTx = StockTransaction.create(
          date: DateTime.now(),
          lineItems: [lineItem],
          stockMovement: StockMovement.stockIn,
        );
        final stCreatedOrError =
            await stockTransactionRepo.create(stockTransaction: rawTx, teamId: team.id!, token: firstUserAccessToken);
        expect(stCreatedOrError.isRight(), true);
        await Future.delayed(const Duration(seconds: 1));
      }
    }

    {
      //check item stock is updated
      final itemOrError = await itemApi.getItem(itemId: tShirtItem.id!, teamId: team.id!, token: firstUserAccessToken);
      expect(itemOrError.isRight(), true);
      final item = itemOrError.toIterable().first;
      final whiteTShirt = item.variations.first;
      expect(whiteTShirt.itemCount, 35);
    }
    {
      final stockTransactionListOrError =
          await stockTransactionRepo.list(teamId: team.id!, token: firstUserAccessToken);
      final stockTransactionList = stockTransactionListOrError.toIterable().first;
      expect(stockTransactionList.data.length, 5);
      expect(stockTransactionList.hasMore, false);
    }
    StockTransaction stockTransactionToCheck;
    {
      final rawTx = StockTransaction.create(
        date: DateTime.now(),
        lineItems: [lineItem],
        stockMovement: StockMovement.stockIn,
      );
      final stCreatedOrError =
          await stockTransactionRepo.create(stockTransaction: rawTx, teamId: team.id!, token: firstUserAccessToken);
      expect(stCreatedOrError.isRight(), true);
      stockTransactionToCheck = stCreatedOrError.toIterable().first;
      await Future.delayed(const Duration(seconds: 1));
    }

    {
      //check the list without starting after
      final stockTransactionListOrError = await stockTransactionRepo.list(
        teamId: team.id!,
        token: firstUserAccessToken,
      );
      final stockTransactionList = stockTransactionListOrError.toIterable().first;
      expect(stockTransactionList.data.length, 6);
      expect(stockTransactionList.hasMore, false);
    }

    {
      //check the list with starting after
      final searchField = StockTransactionSearchField(startingAfterStockTransactionId: stockTransactionToCheck.id);
      final stockTransactionListOrError =
          await stockTransactionRepo.list(teamId: team.id!, token: firstUserAccessToken, searchField: searchField);
      final stockTransactionList = stockTransactionListOrError.toIterable().first;
      expect(stockTransactionList.data.length, 5);
      expect(stockTransactionList.hasMore, false);
    }

    {
      for (int i = 0; i < 6; i++) {
        final rawTx = StockTransaction.create(
          date: DateTime.now(),
          lineItems: [lineItem],
          stockMovement: StockMovement.stockIn,
        );
        final stCreatedOrError =
            await stockTransactionRepo.create(stockTransaction: rawTx, teamId: team.id!, token: firstUserAccessToken);
        expect(stCreatedOrError.isRight(), true);
        await Future.delayed(const Duration(seconds: 1));
      }
    }

    {
      //check the list without starting after
      final stockTransactionListOrError = await stockTransactionRepo.list(
        teamId: team.id!,
        token: firstUserAccessToken,
      );
      final stockTransactionList = stockTransactionListOrError.toIterable().first;
      expect(stockTransactionList.data.length, 10);
      expect(stockTransactionList.hasMore, true);
    }

    {
      //check the list with starting after
      final searchField = StockTransactionSearchField(startingAfterStockTransactionId: stockTransactionToCheck.id);
      final stockTransactionListOrError =
          await stockTransactionRepo.list(teamId: team.id!, token: firstUserAccessToken, searchField: searchField);
      final stockTransactionList = stockTransactionListOrError.toIterable().first;
      expect(stockTransactionList.data.length, 5);
      expect(stockTransactionList.hasMore, false);
    }
  });

  test('you can search stock transactions', () async {
    final newTeam = Team.create(name: 'Power Ranger', timeZone: "Africa/Abidjan", currencyCode: CurrencyCode.AUD);
    final createdOrError = await teamApi.create(team: newTeam, token: firstUserAccessToken);
    expect(createdOrError.isRight(), true);
    final team = createdOrError.toIterable().first;

    final salePriceMoney = PriceMoney(amount: 10, currency: "SGD");
    final purchasePriceMoney = PriceMoney(amount: 5, currency: "SGD");

    final whiteShrt = ItemVariation.create(
        name: "White Shirt",
        stockable: true,
        sku: 'sku 123',
        salePriceMoney: salePriceMoney,
        purchasePriceMoney: purchasePriceMoney);

    final blackShirt = ItemVariation.create(
        name: "Black Shirt",
        stockable: true,
        sku: 'sku 123',
        salePriceMoney: salePriceMoney,
        purchasePriceMoney: purchasePriceMoney);

    final shirt = Item.create(name: "shirt", variations: [whiteShrt, blackShirt], unit: 'kg');

    final itemCreated = await itemApi.createItem(item: shirt, teamId: team.id!, token: firstUserAccessToken);
    expect(itemCreated.isRight(), true);

    final retrievedWhiteShirt =
        itemCreated.toIterable().first.variations.where((element) => element.name == 'White Shirt').first;

    final lineItem = StockLineItem.create(itemVariation: retrievedWhiteShirt, quantity: 7);

    {
      for (int i = 0; i < 1; i++) {
        final rawTx = StockTransaction.create(
          date: DateTime.now(),
          lineItems: [lineItem],
          stockMovement: StockMovement.stockAdjust,
        );
        final stCreatedOrError =
            await stockTransactionRepo.create(stockTransaction: rawTx, teamId: team.id!, token: firstUserAccessToken);
        expect(stCreatedOrError.isRight(), true);
        await Future.delayed(const Duration(seconds: 1));
      }
    }
    {
      //create a black shirt with stock in
      final retrievedBlackShirt =
          itemCreated.toIterable().first.variations.where((element) => element.name == 'Black Shirt').first;
      final lineItem = StockLineItem.create(itemVariation: retrievedBlackShirt, quantity: 7);
      final rawTx = StockTransaction.create(
        date: DateTime.now(),
        lineItems: [lineItem],
        stockMovement: StockMovement.stockIn,
      );
      final stCreatedOrError =
          await stockTransactionRepo.create(stockTransaction: rawTx, teamId: team.id!, token: firstUserAccessToken);
      expect(stCreatedOrError.isRight(), true);
      await Future.delayed(const Duration(seconds: 1));
    }
    {
      // you can search transaction with black shirt
      final searchField = StockTransactionSearchField(itemVaraiationName: "lack");
      final stockTransactionListOrError =
          await stockTransactionRepo.list(teamId: team.id!, token: firstUserAccessToken, searchField: searchField);
      final stockTransactionList = stockTransactionListOrError.toIterable().first;
      expect(stockTransactionList.data.length, 1);
      expect(stockTransactionList.hasMore, false);
    }

    {
      // you can one transactions when searching with black shirt and stock in
      final searchField = StockTransactionSearchField(itemVaraiationName: "lack", stockMovement: StockMovement.stockIn);
      final stockTransactionListOrError =
          await stockTransactionRepo.list(teamId: team.id!, token: firstUserAccessToken, searchField: searchField);
      final stockTransactionList = stockTransactionListOrError.toIterable().first;
      expect(stockTransactionList.data.length, 1);
      expect(stockTransactionList.hasMore, false);
    }

    {
      // you can empty transactions when searching with black shirt and stock out
      final searchField =
          StockTransactionSearchField(itemVaraiationName: "lack", stockMovement: StockMovement.stockOut);
      final stockTransactionListOrError =
          await stockTransactionRepo.list(teamId: team.id!, token: firstUserAccessToken, searchField: searchField);
      final stockTransactionList = stockTransactionListOrError.toIterable().first;
      expect(stockTransactionList.data.length, 0);
      expect(stockTransactionList.hasMore, false);
    }

    {
      // you can search transaction with any shirt
      final searchField = StockTransactionSearchField(itemVaraiationName: "irt");
      final stockTransactionListOrError =
          await stockTransactionRepo.list(teamId: team.id!, token: firstUserAccessToken, searchField: searchField);
      final stockTransactionList = stockTransactionListOrError.toIterable().first;
      expect(stockTransactionList.data.length, 2);
      expect(stockTransactionList.hasMore, false);
    }
  });
}
