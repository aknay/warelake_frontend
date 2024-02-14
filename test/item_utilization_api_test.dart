import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:warelake/data/bill.account/bill.account.repository.dart';
import 'package:warelake/data/currency.code/valueobject.dart';
import 'package:warelake/data/item/item.repository.dart';
import 'package:warelake/data/purchase.order/purchase.order.repository.dart';
import 'package:warelake/data/stock.transaction/stock.transaction.repository.dart';
import 'package:warelake/data/team/team.repository.dart';
import 'package:warelake/domain/bill.account/entities.dart';
import 'package:warelake/domain/item/entities.dart';
import 'package:warelake/domain/item/payloads.dart';
import 'package:warelake/domain/purchase.order/entities.dart';
import 'package:warelake/domain/stock.transaction/entities.dart';
import 'package:warelake/domain/team/entities.dart';

import 'helpers/sign.in.response.dart';
import 'helpers/test.helper.dart';

void main() async {
  final teamApi = TeamRepository();
  final itemRepo = ItemRepository();
  final purchaseOrderApi = PurchaseOrderRepository();
  final billAccountApi = BillAccountRepository();
  final stockTransactionRepo = StockTransactionRepository();
  late String firstUserAccessToken;
  late Item shirtItem;
  late Item jeanItem;
  late BillAccount billAccount;
  late Team team;
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
    team = createdOrError.toIterable().first;
    teamId = team.id!;
    final accountListOrError = await billAccountApi.list(teamId: team.id!, token: firstUserAccessToken);
    expect(accountListOrError.isRight(), true);
    billAccount = accountListOrError.toIterable().first.data.first;

    final shirt = getShirt();
    final jean = getJean();

    final shirtCreatedOrError = await itemRepo.createItem(item: shirt, teamId: team.id!, token: firstUserAccessToken);
    shirtItem = shirtCreatedOrError.toIterable().first;

    final jeansCreatedOrError = await itemRepo.createItem(item: jean, teamId: team.id!, token: firstUserAccessToken);
    jeanItem = jeansCreatedOrError.toIterable().first;
  });

  test('you can create stock in, delete po with received state and check totalQuantityOfAllItemVariation', () async {
    {
      final rawTx = StockTransaction.create(
        date: DateTime.now(),
        lineItems: getStockLineItemWithIndividual(items: [
          Tuple2(1, shirtItem.variations[0]),
          Tuple2(2, shirtItem.variations[1]),
          Tuple2(3, jeanItem.variations[0]),
          Tuple2(4, jeanItem.variations[1]),
        ]),
        stockMovement: StockMovement.stockIn,
      );
      final stCreatedOrError =
          await stockTransactionRepo.create(stockTransaction: rawTx, teamId: team.id!, token: firstUserAccessToken);
      expect(stCreatedOrError.isRight(), true);
    }

    {
      //sleep a while to update correctly
      await Future.delayed(const Duration(seconds: 1));
      final iuOrError = await itemRepo.getItemUtilization(teamId: team.id!, token: firstUserAccessToken);
      expect(iuOrError.isRight(), true);
      expect(iuOrError.toIterable().first.totalQuantityOfAllItemVariation, 10);
    }
    PurchaseOrder purchaseOrder;
    {
      //sleep a while to update correctly
      await Future.delayed(const Duration(seconds: 1));
      final lineItems = getLineItemIndividual(items: [
        Tuple2(2, shirtItem.variations[0]),
        Tuple2(3, shirtItem.variations[1]),
        Tuple2(4, jeanItem.variations[0]),
        Tuple2(5, jeanItem.variations[1]),
      ]);
      final po = PurchaseOrder.create(
          purchaseOrderNumber: "PO-0001",
          accountId: billAccount.id!,
          date: DateTime.now(),
          currencyCode: CurrencyCode.AUD,
          lineItems: lineItems,
          subTotal: 10,
          total: 20);
      final poCreatedOrError =
          await purchaseOrderApi.issuedPurchaseOrder(purchaseOrder: po, teamId: team.id!, token: firstUserAccessToken);
  await Future.delayed(const Duration(seconds: 1));
      expect(poCreatedOrError.isRight(), true);
      purchaseOrder = poCreatedOrError.toIterable().first;
      final poItemsReceivedOrError = await purchaseOrderApi.receivedItems(
          purchaseOrderId: purchaseOrder.id!, date: DateTime.now(), teamId: team.id!, token: firstUserAccessToken);
      expect(poItemsReceivedOrError.isRight(), true);
    }
    {
      //sleep a while to update correctly
      await Future.delayed(const Duration(seconds: 1));
      final iuOrError = await itemRepo.getItemUtilization(teamId: team.id!, token: firstUserAccessToken);
      expect(iuOrError.isRight(), true);
      expect(iuOrError.toIterable().first.totalQuantityOfAllItemVariation, 24);
    }
    {
      await Future.delayed(const Duration(seconds: 1));
      final deletedOrError = await purchaseOrderApi.delete(
        purchaseOrderId: purchaseOrder.id!,
        teamId: team.id!,
        token: firstUserAccessToken,
      );
      expect(deletedOrError.isRight(), true);
    }
    {
      //sleep a while to update correctly
      await Future.delayed(const Duration(seconds: 1));
      final iuOrError = await itemRepo.getItemUtilization(teamId: team.id!, token: firstUserAccessToken);
      expect(iuOrError.isRight(), true);
      expect(iuOrError.toIterable().first.totalQuantityOfAllItemVariation, 10);
    }
  });

  test('item utilization count is correct after new item variations can be added to the item', () async {

  {
      //sleep a while to update correctly
      await Future.delayed(const Duration(seconds: 1));
      final iuOrError = await itemRepo.getItemUtilization(teamId: team.id!, token: firstUserAccessToken);
      expect(iuOrError.isRight(), true);
      expect(iuOrError.toIterable().first.totalItemVariationsCount, 4);
    }

    final salePriceMoney = PriceMoney(amount: 10, currency: "SGD");
    final purchasePriceMoney = PriceMoney(amount: 5, currency: "SGD");

    final greenShirt = ItemVariation.create(
        name: "Green Shirt",
        stockable: true,
        sku: 'sku 123',
        salePriceMoney: salePriceMoney,
        purchasePriceMoney: purchasePriceMoney);

    final updatedOrError = await itemRepo.updateItem(
        payload: ItemUpdatePayload(newItemVariationListOrNone: Some([greenShirt])),
        itemId: shirtItem.id!,
        teamId: teamId,
        token: firstUserAccessToken);

    expect(updatedOrError.isRight(), true);

    {
      //sleep a while to update correctly
      await Future.delayed(const Duration(seconds: 1));
      final iuOrError = await itemRepo.getItemUtilization(teamId: team.id!, token: firstUserAccessToken);
      expect(iuOrError.isRight(), true);
      expect(iuOrError.toIterable().first.totalItemVariationsCount, 5);
    }

  });
}
