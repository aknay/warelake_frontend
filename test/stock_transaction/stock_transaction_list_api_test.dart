import 'dart:convert';

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

import '../helpers/sign.in.response.dart';
import '../helpers/test.helper.dart';

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

  test('you can sort stock transactions by date', () async {
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

    final retrievedWhiteShirt = itemCreated.toIterable().first.variations.first;

    final lineItem = StockLineItem.create(itemVariation: retrievedWhiteShirt, quantity: 7);
    {
      //first stock transaction
      final rawTx = StockTransaction.create(
        date: DateTime(2024, 3, 1),
        lineItems: [lineItem],
        stockMovement: StockMovement.stockIn,
      );
      final stCreatedOrError =
          await stockTransactionRepo.create(stockTransaction: rawTx, teamId: team.id!, token: firstUserAccessToken);

      expect(stCreatedOrError.isRight(), true);
    }
    {
      //second stock transaction

      final rawTx = StockTransaction.create(
        date: DateTime(2024, 1, 1),
        lineItems: [lineItem],
        stockMovement: StockMovement.stockIn,
      );
      final stCreatedOrError =
          await stockTransactionRepo.create(stockTransaction: rawTx, teamId: team.id!, token: firstUserAccessToken);

      expect(stCreatedOrError.isRight(), true);
    }

    {
      //third stock transaction

      final rawTx = StockTransaction.create(
        date: DateTime(2024, 2, 1),
        lineItems: [lineItem],
        stockMovement: StockMovement.stockIn,
      );
      final stCreatedOrError =
          await stockTransactionRepo.create(stockTransaction: rawTx, teamId: team.id!, token: firstUserAccessToken);

      expect(stCreatedOrError.isRight(), true);
    }

    {
      final stockTransactionListOrError =
          await stockTransactionRepo.list(teamId: team.id!, token: firstUserAccessToken);
      final stockTransactionList = stockTransactionListOrError.toIterable().first;
      expect(stockTransactionList.data.length, 3);
      expect(stockTransactionList.hasMore, false);
      expect(stockTransactionList.data[0].date, DateTime(2024, 3, 1));
      expect(stockTransactionList.data[1].date, DateTime(2024, 2, 1));
      expect(stockTransactionList.data[2].date, DateTime(2024, 1, 1));
    }

    // final stx = stCreatedOrError.toIterable().first;
    // expect(stx.lineItems.first.quantity, 7);
    // expect(stx.lineItems.first.oldStockLevel, 0);
    // expect(stx.lineItems.first.newStockLevel, 7);

    // {
    //   //check item stock is updated
    //   final itemOrError = await itemApi.getItem(itemId: tShirtItem.id!, teamId: team.id!, token: firstUserAccessToken);
    //   final item = itemOrError.toIterable().first;
    //   final whiteTShirt = item.variations.first;
    //   expect(whiteTShirt.itemCount, 7);
    // }
    // {
    //   final stockTransactionListOrError =
    //       await stockTransactionRepo.list(teamId: team.id!, token: firstUserAccessToken);
    //   expect(stockTransactionListOrError.isRight(), true);
    // }
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
