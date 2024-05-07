import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:warelake/data/bill.account/bill.account.repository.dart';
import 'package:warelake/data/currency.code/valueobject.dart';
import 'package:warelake/data/item/item.repository.dart';
import 'package:warelake/data/stock.transaction/stock.transaction.repository.dart';
import 'package:warelake/data/team/team.repository.dart';
import 'package:warelake/domain/bill.account/entities.dart';
import 'package:warelake/domain/item/entities.dart';
import 'package:warelake/domain/stock.transaction/entities.dart';
import 'package:warelake/domain/team/entities.dart';

import '../helpers/sign.in.response.dart';
import '../helpers/test.helper.dart';

void main() async {
  final teamApi = TeamRepository();
  final itemApi = ItemRepository();
  final stockTransactionRepo = StockTransactionRepository();
  final billAccountApi = BillAccountRepository();
  late String firstUserAccessToken;
  late String teamId;
  late Item shirtItem;
  late List<ItemVariation> shirtItemVariations;
  late Item jeanItem;
  late List<ItemVariation> jeanItemVariations;
  late BillAccount billAccount;

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
    billAccount = accountListOrError.toIterable().first.data.first;

    final shirtCreatedOrError =
        await itemApi.createItemRequest(request: getShirtItemRequest(), teamId: teamId, token: firstUserAccessToken);
    shirtItem = shirtCreatedOrError.toIterable().first;

    final shirtVaraitionsOrError =
        await itemApi.getItemVariations(teamId: teamId, token: firstUserAccessToken, itemId: shirtItem.id!);
    shirtItemVariations = shirtVaraitionsOrError.toIterable().first;

    final jeansCreatedOrError =
        await itemApi.createItemRequest(request: getJeanItemRequest(), teamId: teamId, token: firstUserAccessToken);
    jeanItem = jeansCreatedOrError.toIterable().first;
    final jeanVariationsOrError =
        await itemApi.getItemVariations(teamId: teamId, token: firstUserAccessToken, itemId: jeanItem.id!);
    jeanItemVariations = jeanVariationsOrError.toIterable().first;
  });

  test('creating stx wiht stock in should be successful', () async {
    final lineItems = getStocklLineItemWithRandomCount(createdItemList: shirtItemVariations + jeanItemVariations);
    log('line items ${lineItems}');
    final rawTx = StockTransaction.create(
      date: DateTime.now(),
      lineItems: lineItems,
      stockMovement: StockMovement.stockIn,
    );
    final stCreatedOrError =
        await stockTransactionRepo.create(stockTransaction: rawTx, teamId: teamId, token: firstUserAccessToken);

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

      final iuOrError = await itemApi.getItemUtilization(teamId: teamId, token: firstUserAccessToken);
      expect(iuOrError.isRight(), true);
      expect(iuOrError.toIterable().first.totalQuantityOfAllItemVariation, total);
    }
  });

  test('creating stx with stock in and you can get back the note', () async {
    final lineItems = getStocklLineItemWithRandomCount(createdItemList: shirtItemVariations + jeanItemVariations);

    final rawTx = StockTransaction.create(
        date: DateTime.now(), lineItems: lineItems, stockMovement: StockMovement.stockIn, notes: optionOf('hello'));
    final stCreatedOrError =
        await stockTransactionRepo.create(stockTransaction: rawTx, teamId: teamId, token: firstUserAccessToken);

    expect(stCreatedOrError.isRight(), true);
    final st = stCreatedOrError.toIterable().first;
    expect(st.notes, const Some('hello'));
  });

  test('creating stx with different date', () async {
    final lineItems = getStocklLineItemWithRandomCount(createdItemList: shirtItemVariations);

    final rawTx = StockTransaction.create(
      date: DateTime(2024, 1, 3, 9, 8, 7),
      lineItems: lineItems,
      stockMovement: StockMovement.stockIn,
    );
    final stCreatedOrError =
        await stockTransactionRepo.create(stockTransaction: rawTx, teamId: teamId, token: firstUserAccessToken);

    expect(stCreatedOrError.isRight(), true);

    final stx = stCreatedOrError.toIterable().first;
    expect(stx.date, DateTime(2024, 1, 3, 9, 8, 7));
  });

  test('you can get back the created stock transaction', () async {
    final retrievedWhiteShirt = shirtItemVariations.where((element) => element.name == "White Shirt").first;
    final retrievedBlackShirt = shirtItemVariations.where((element) => element.name == "Black Shirt").first;

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
        await stockTransactionRepo.create(stockTransaction: rawTx, teamId: teamId, token: firstUserAccessToken);

    expect(stCreatedOrError.isRight(), true);

    final createdStx = stCreatedOrError.toIterable().first;
    {
      final stxOrError = await stockTransactionRepo.get(
          stockTransactionId: createdStx.id!, teamId: teamId, token: firstUserAccessToken);
      final stx = stxOrError.toIterable().first;
      final retrivedWhiteShirt = stx.lineItems.where((element) => element.itemVariation.name == "White Shirt").first;
      final retrivedBlackShirt = stx.lineItems.where((element) => element.itemVariation.name == "Black Shirt").first;
      expect(retrivedWhiteShirt.quantity, 2);
      expect(retrivedWhiteShirt.oldStockLevel, 0);
      expect(retrivedWhiteShirt.newStockLevel, 2);
      expect(retrivedBlackShirt.quantity, 3);
      expect(retrivedBlackShirt.oldStockLevel, 0);
      expect(retrivedBlackShirt.newStockLevel, 3);
    }
  });

  test('creating stx with stock out should be successful', () async {
    final stockInLineItems =
        getStocklLineItemWithRandomCount(createdItemList: shirtItemVariations + jeanItemVariations);

    final rawTx = StockTransaction.create(
      date: DateTime.now(),
      lineItems: stockInLineItems,
      stockMovement: StockMovement.stockIn,
    );
    final stCreatedOrError =
        await stockTransactionRepo.create(stockTransaction: rawTx, teamId: teamId, token: firstUserAccessToken);

    expect(stCreatedOrError.isRight(), true);

    final stockInStx = stCreatedOrError.toIterable().first;
    final retrievedStxInWhiteShirtLineItem =
        stockInStx.lineItems.where((element) => element.itemVariation.name == "White Shirt").first;
    final retrievedStxInBlackShirtLineItem =
        stockInStx.lineItems.where((element) => element.itemVariation.name == "Black Shirt").first;

    final stockOutLineItems = getStocklLineItemWithRandomCount(createdItemList: shirtItemVariations);
    {
      final rawTx = StockTransaction.create(
        date: DateTime.now(),
        lineItems: stockOutLineItems,
        stockMovement: StockMovement.stockOut,
      );
      final stCreatedOrError =
          await stockTransactionRepo.create(stockTransaction: rawTx, teamId: teamId, token: firstUserAccessToken);
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
      final iuOrError = await itemApi.getItemUtilization(teamId: teamId, token: firstUserAccessToken);
      expect(iuOrError.isRight(), true);
      expect(iuOrError.toIterable().first.totalQuantityOfAllItemVariation, totalStockIn - totalStockOut);
    }
  });

  test('creating stx with stock adjust should be successful', () async {
    final stockInLineItems = getStockLineItem(items: [Tuple2(10, shirtItemVariations), Tuple2(20, jeanItemVariations)]);

    final rawTx = StockTransaction.create(
      date: DateTime.now(),
      lineItems: stockInLineItems,
      stockMovement: StockMovement.stockIn,
    );
    final stCreatedOrError =
        await stockTransactionRepo.create(stockTransaction: rawTx, teamId: teamId, token: firstUserAccessToken);

    expect(stCreatedOrError.isRight(), true);

    final stockInStx = stCreatedOrError.toIterable().first;
    final retrievedStxInWhiteShirtLineItem =
        stockInStx.lineItems.where((element) => element.itemVariation.name == "White Shirt").first;
    final retrievedStxInBlackShirtLineItem =
        stockInStx.lineItems.where((element) => element.itemVariation.name == "Black Shirt").first;

    final stockOutLineItems = getStockLineItem(items: [Tuple2(5, shirtItemVariations), Tuple2(10, jeanItemVariations)]);
    StockTransaction stockOut;
    {
      final rawTx = StockTransaction.create(
        date: DateTime.now(),
        lineItems: stockOutLineItems,
        stockMovement: StockMovement.stockOut,
      );
      final stCreatedOrError =
          await stockTransactionRepo.create(stockTransaction: rawTx, teamId: teamId, token: firstUserAccessToken);
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
      final iuOrError = await itemApi.getItemUtilization(teamId: teamId, token: firstUserAccessToken);
      expect(iuOrError.isRight(), true);
      expect(iuOrError.toIterable().first.totalQuantityOfAllItemVariation, totalStockIn - totalStockOut);
    }

    {
      final stockAdjustLineItems = getStockLineItem(items: [Tuple2(7, shirtItemVariations)]);
      final rawTx = StockTransaction.create(
        date: DateTime.now(),
        lineItems: stockAdjustLineItems,
        stockMovement: StockMovement.stockAdjust,
      );

      final stCreatedOrError =
          await stockTransactionRepo.create(stockTransaction: rawTx, teamId: teamId, token: firstUserAccessToken);
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
      final iuOrError = await itemApi.getItemUtilization(teamId: teamId, token: firstUserAccessToken);
      expect(iuOrError.isRight(), true);
      expect(iuOrError.toIterable().first.totalQuantityOfAllItemVariation, 34);
    }
  });

  test('creating stx with stock adjust should be successful', () async {
    final lineItem = StockLineItem.create(itemVariation: shirtItemVariations.first, quantity: 7);

    final rawTx = StockTransaction.create(
      date: DateTime.now(),
      lineItems: [lineItem],
      stockMovement: StockMovement.stockIn,
    );
    final stCreatedOrError =
        await stockTransactionRepo.create(stockTransaction: rawTx, teamId: teamId, token: firstUserAccessToken);

    expect(stCreatedOrError.isRight(), true);

    final stx = stCreatedOrError.toIterable().first;
    expect(stx.lineItems.first.quantity, 7);
    expect(stx.lineItems.first.oldStockLevel, 0);
    expect(stx.lineItems.first.newStockLevel, 7);

    {
      //check item stock is updated
      final itemOrError = await itemApi.getItemVariation(
          itemId: shirtItem.id!,
          itemVariationId: shirtItemVariations.first.id!,
          teamId: teamId,
          token: firstUserAccessToken);
      final item = itemOrError.toIterable().first;
      expect(item.itemCount, 7);
    }

    {
      final lineItem = StockLineItem.create(itemVariation: shirtItemVariations.first, quantity: 3);
      final rawTx = StockTransaction.create(
        date: DateTime.now(),
        lineItems: [lineItem],
        stockMovement: StockMovement.stockOut,
      );
      final stCreatedOrError =
          await stockTransactionRepo.create(stockTransaction: rawTx, teamId: teamId, token: firstUserAccessToken);

      expect(stCreatedOrError.isRight(), true);

      final stx = stCreatedOrError.toIterable().first;
      expect(stx.lineItems.first.quantity, 3);
      expect(stx.lineItems.first.oldStockLevel, 7);
      expect(stx.lineItems.first.newStockLevel, 4);

      {
        //check item stock is updated
        final itemOrError = await itemApi.getItemVariation(
            itemId: shirtItem.id!,
            itemVariationId: shirtItemVariations.first.id!,
            teamId: teamId,
            token: firstUserAccessToken);
        final item = itemOrError.toIterable().first;
        expect(item.itemCount, 4);
      }
    }

    {
      final lineItem = StockLineItem.create(itemVariation: shirtItemVariations.first, quantity: 10);
      final rawTx = StockTransaction.create(
        date: DateTime.now(),
        lineItems: [lineItem],
        stockMovement: StockMovement.stockAdjust,
      );
      final stCreatedOrError =
          await stockTransactionRepo.create(stockTransaction: rawTx, teamId: teamId, token: firstUserAccessToken);

      expect(stCreatedOrError.isRight(), true);

      final stx = stCreatedOrError.toIterable().first;
      expect(stx.lineItems.first.quantity, 10);
      expect(stx.lineItems.first.oldStockLevel, 4);
      expect(stx.lineItems.first.newStockLevel, 10);

      {
        //check item stock is updated
        final itemOrError = await itemApi.getItemVariation(
            itemId: shirtItem.id!,
            itemVariationId: shirtItemVariations.first.id!,
            teamId: teamId,
            token: firstUserAccessToken);
        final item = itemOrError.toIterable().first;
        expect(item.itemCount, 10);
      }
    }
  });

  test('after transaction is deleted, it will not be shown in the list', () async {
    StockTransaction stockInTransaction;
    {
      //stock in
      final stockInLineItems =
          getStockLineItem(items: [Tuple2(10, shirtItemVariations), Tuple2(20, jeanItemVariations)]);

      final rawTx = StockTransaction.create(
        date: DateTime.now(),
        lineItems: stockInLineItems,
        stockMovement: StockMovement.stockIn,
      );
      final stCreatedOrError =
          await stockTransactionRepo.create(stockTransaction: rawTx, teamId: teamId, token: firstUserAccessToken);

      stockInTransaction = stCreatedOrError.toIterable().first;
    }

    {
      //delete stock in
      final deletedOrError = await stockTransactionRepo.delete(
          stockTransactionId: stockInTransaction.id!, teamId: teamId, token: firstUserAccessToken);
      expect(deletedOrError.isRight(), true);
    }
    {
      // check in the list
      final stockTransactionOrError = await stockTransactionRepo.list(teamId: teamId, token: firstUserAccessToken);
      expect(stockTransactionOrError.toIterable().first.data.isEmpty, true);
    }
  });

  test('deleting stx with stock in: totalQuantityOfAllItemVariation should be correct', () async {
    StockTransaction stockInTransaction;
    {
      //stock in
      final stockInLineItems =
          getStockLineItem(items: [Tuple2(10, shirtItemVariations), Tuple2(20, jeanItemVariations)]);

      final rawTx = StockTransaction.create(
        date: DateTime.now(),
        lineItems: stockInLineItems,
        stockMovement: StockMovement.stockIn,
      );
      final stCreatedOrError =
          await stockTransactionRepo.create(stockTransaction: rawTx, teamId: teamId, token: firstUserAccessToken);

      stockInTransaction = stCreatedOrError.toIterable().first;
    }

    {
      //stock out
      final stockOutLineItems =
          getStockLineItem(items: [Tuple2(5, shirtItemVariations), Tuple2(10, jeanItemVariations)]);

      final rawTx = StockTransaction.create(
        date: DateTime.now(),
        lineItems: stockOutLineItems,
        stockMovement: StockMovement.stockOut,
      );
      final stCreatedOrError =
          await stockTransactionRepo.create(stockTransaction: rawTx, teamId: teamId, token: firstUserAccessToken);
      expect(stCreatedOrError.isRight(), true);
    }
    {
      //delete stock in
      final deletedOrError = await stockTransactionRepo.delete(
          stockTransactionId: stockInTransaction.id!, teamId: teamId, token: firstUserAccessToken);
      expect(deletedOrError.isRight(), true);
    }
    {
      final iuOrError = await itemApi.getItemUtilization(teamId: teamId, token: firstUserAccessToken);
      expect(iuOrError.isRight(), true);
      expect(iuOrError.toIterable().first.totalQuantityOfAllItemVariation, -30);
    }
  });

  test('deleting stx with stock out: totalQuantityOfAllItemVariation should be correct', () async {
    {
      //stock in
      final stockInLineItems =
          getStockLineItem(items: [Tuple2(10, shirtItemVariations), Tuple2(20, jeanItemVariations)]);

      final rawTx = StockTransaction.create(
        date: DateTime.now(),
        lineItems: stockInLineItems,
        stockMovement: StockMovement.stockIn,
      );
      final stCreatedOrError =
          await stockTransactionRepo.create(stockTransaction: rawTx, teamId: teamId, token: firstUserAccessToken);

      expect(stCreatedOrError.isRight(), true);
    }

    StockTransaction stockOutTransaction;
    {
      //stock out
      final stockOutLineItems = getStockLineItem(items: [Tuple2(5, shirtItemVariations)]);

      final rawTx = StockTransaction.create(
        date: DateTime.now(),
        lineItems: stockOutLineItems,
        stockMovement: StockMovement.stockOut,
      );
      final stCreatedOrError =
          await stockTransactionRepo.create(stockTransaction: rawTx, teamId: teamId, token: firstUserAccessToken);
      expect(stCreatedOrError.isRight(), true);
      stockOutTransaction = stCreatedOrError.toIterable().first;
    }
    {
      //delete stock in
      final deletedOrError = await stockTransactionRepo.delete(
          stockTransactionId: stockOutTransaction.id!, teamId: teamId, token: firstUserAccessToken);
      expect(deletedOrError.isRight(), true);
    }
    {
      final iuOrError = await itemApi.getItemUtilization(teamId: teamId, token: firstUserAccessToken);
      expect(iuOrError.isRight(), true);
      expect(iuOrError.toIterable().first.totalQuantityOfAllItemVariation, 60);
    }
  });

  test('deleting stx with stock adjust: totalQuantityOfAllItemVariation should be correct', () async {
    {
      //stock in
      final stockInLineItems =
          getStockLineItem(items: [Tuple2(10, shirtItemVariations), Tuple2(20, jeanItemVariations)]);

      final rawTx = StockTransaction.create(
        date: DateTime.now(),
        lineItems: stockInLineItems,
        stockMovement: StockMovement.stockIn,
      );
      final stCreatedOrError =
          await stockTransactionRepo.create(stockTransaction: rawTx, teamId: teamId, token: firstUserAccessToken);

      expect(stCreatedOrError.isRight(), true);
    }

    {
      //stock out
      final stockOutLineItems = getStockLineItem(items: [Tuple2(5, shirtItemVariations)]);

      final rawTx = StockTransaction.create(
        date: DateTime.now(),
        lineItems: stockOutLineItems,
        stockMovement: StockMovement.stockOut,
      );
      final stCreatedOrError =
          await stockTransactionRepo.create(stockTransaction: rawTx, teamId: teamId, token: firstUserAccessToken);
      expect(stCreatedOrError.isRight(), true);
    }

    StockTransaction stockAdjustTransaction;
    {
      //stock out
      final stockOutLineItems = getStockLineItem(items: [Tuple2(7, shirtItemVariations)]);

      final rawTx = StockTransaction.create(
        date: DateTime.now(),
        lineItems: stockOutLineItems,
        stockMovement: StockMovement.stockAdjust,
      );
      final stCreatedOrError =
          await stockTransactionRepo.create(stockTransaction: rawTx, teamId: teamId, token: firstUserAccessToken);
      expect(stCreatedOrError.isRight(), true);
      stockAdjustTransaction = stCreatedOrError.toIterable().first;
    }
    {
      //delete stock adjust
      final deletedOrError = await stockTransactionRepo.delete(
          stockTransactionId: stockAdjustTransaction.id!, teamId: teamId, token: firstUserAccessToken);
      expect(deletedOrError.isRight(), true);
    }
    {
      final iuOrError = await itemApi.getItemUtilization(teamId: teamId, token: firstUserAccessToken);
      expect(iuOrError.isRight(), true);
      expect(iuOrError.toIterable().first.totalQuantityOfAllItemVariation, 50);
    }
  });

  test('delete stx with stock adjust should be successful', () async {
    final lineItem = StockLineItem.create(itemVariation: shirtItemVariations.first, quantity: 7);

    final rawTx = StockTransaction.create(
      date: DateTime.now(),
      lineItems: [lineItem],
      stockMovement: StockMovement.stockIn,
    );
    final stCreatedOrError =
        await stockTransactionRepo.create(stockTransaction: rawTx, teamId: teamId, token: firstUserAccessToken);

    expect(stCreatedOrError.isRight(), true);

    final stxWithStockIn = stCreatedOrError.toIterable().first;
    expect(stxWithStockIn.lineItems.first.quantity, 7);
    expect(stxWithStockIn.lineItems.first.oldStockLevel, 0);
    expect(stxWithStockIn.lineItems.first.newStockLevel, 7);

    {
      //check item stock is updated
      final itemOrError = await itemApi.getItemVariation(
          itemId: shirtItem.id!,
          itemVariationId: shirtItemVariations.first.id!,
          teamId: teamId,
          token: firstUserAccessToken);
      final item = itemOrError.toIterable().first;
      final whiteTShirt = item;
      expect(whiteTShirt.itemCount, 7);
    }
    StockTransaction stxWithStockOut;
    {
      final lineItem = StockLineItem.create(itemVariation: shirtItemVariations.first, quantity: 3);
      final rawTx = StockTransaction.create(
        date: DateTime.now(),
        lineItems: [lineItem],
        stockMovement: StockMovement.stockOut,
      );
      final stCreatedOrError =
          await stockTransactionRepo.create(stockTransaction: rawTx, teamId: teamId, token: firstUserAccessToken);

      expect(stCreatedOrError.isRight(), true);

      stxWithStockOut = stCreatedOrError.toIterable().first;
      expect(stxWithStockOut.lineItems.first.quantity, 3);
      expect(stxWithStockOut.lineItems.first.oldStockLevel, 7);
      expect(stxWithStockOut.lineItems.first.newStockLevel, 4);

      {
        //check item stock is updated

        final itemOrError = await itemApi.getItemVariation(
            itemId: shirtItem.id!,
            itemVariationId: shirtItemVariations.first.id!,
            teamId: teamId,
            token: firstUserAccessToken);
        final item = itemOrError.toIterable().first;
        final whiteTShirt = item;
        expect(whiteTShirt.itemCount, 4);
      }
    }
    StockTransaction stxWithStockAdjust;
    {
      final lineItem = StockLineItem.create(itemVariation: shirtItemVariations.first, quantity: 10);
      final rawTx = StockTransaction.create(
        date: DateTime.now(),
        lineItems: [lineItem],
        stockMovement: StockMovement.stockAdjust,
      );
      final stCreatedOrError =
          await stockTransactionRepo.create(stockTransaction: rawTx, teamId: teamId, token: firstUserAccessToken);

      expect(stCreatedOrError.isRight(), true);

      stxWithStockAdjust = stCreatedOrError.toIterable().first;
      expect(stxWithStockAdjust.lineItems.first.quantity, 10);
      expect(stxWithStockAdjust.lineItems.first.oldStockLevel, 4);
      expect(stxWithStockAdjust.lineItems.first.newStockLevel, 10);

      {
        //check item stock is updated

        final itemOrError = await itemApi.getItemVariation(
            itemId: shirtItem.id!,
            itemVariationId: shirtItemVariations.first.id!,
            teamId: teamId,
            token: firstUserAccessToken);
        final item = itemOrError.toIterable().first;
        final whiteTShirt = item;
        expect(whiteTShirt.itemCount, 10);
      }
    }

    {
      final deletedOrError = await stockTransactionRepo.delete(
          stockTransactionId: stxWithStockAdjust.id!, teamId: teamId, token: firstUserAccessToken);

      expect(deletedOrError.isRight(), true);

      //check item stock is updated
      final itemOrError = await itemApi.getItemVariation(
          itemId: shirtItem.id!,
          itemVariationId: shirtItemVariations.first.id!,
          teamId: teamId,
          token: firstUserAccessToken);
      final item = itemOrError.toIterable().first;
      final whiteTShirt = item;
      expect(whiteTShirt.itemCount, 4);
    }

    {
      //delete stock out transaction and check item count

      final deletedOrError = await stockTransactionRepo.delete(
          stockTransactionId: stxWithStockOut.id!, teamId: teamId, token: firstUserAccessToken);

      expect(deletedOrError.isRight(), true);

      //check item stock is updated
      final itemOrError = await itemApi.getItemVariation(
          itemId: shirtItem.id!,
          itemVariationId: shirtItemVariations.first.id!,
          teamId: teamId,
          token: firstUserAccessToken);
      final item = itemOrError.toIterable().first;
      final whiteTShirt = item;
      expect(whiteTShirt.itemCount, 7);
    }

    {
      //delete stock in transaction and check item count

      final deletedOrError = await stockTransactionRepo.delete(
          stockTransactionId: stxWithStockIn.id!, teamId: teamId, token: firstUserAccessToken);

      expect(deletedOrError.isRight(), true);

      //check item stock is updated
      final itemOrError = await itemApi.getItemVariation(
          itemId: shirtItem.id!,
          itemVariationId: shirtItemVariations.first.id!,
          teamId: teamId,
          token: firstUserAccessToken);
      final item = itemOrError.toIterable().first;
      final whiteTShirt = item;
      expect(whiteTShirt.itemCount, 0);
    }
  });
}
