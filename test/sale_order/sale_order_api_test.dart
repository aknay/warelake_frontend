import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:warelake/data/bill.account/bill.account.repository.dart';
import 'package:warelake/data/currency.code/valueobject.dart';
import 'package:warelake/data/item/item.repository.dart';
import 'package:warelake/data/purchase.order/purchase.order.repository.dart';
import 'package:warelake/data/sale.order/sale.order.repository.dart';
import 'package:warelake/data/team/team.repository.dart';
import 'package:warelake/domain/bill.account/entities.dart';
import 'package:warelake/domain/item/entities.dart';
import 'package:warelake/domain/item/requests.dart';
import 'package:warelake/domain/purchase.order/entities.dart';
import 'package:warelake/domain/sale.order/entities.dart';
import 'package:warelake/domain/team/entities.dart';

import '../helpers/sign.in.response.dart';
import '../helpers/test.helper.dart';

void main() async {
  final teamApi = TeamRepository();
  final itemApi = ItemRepository();
  final saleOrderApi = SaleOrderRepository();
  final billAccountApi = BillAccountRepository();
  final purchaseOrderApi = PurchaseOrderRepository();
  late String firstUserAccessToken;
  late Item shirtItem;
  late List<ItemVariation> shirtItemVariations;
  late Item jeanItem;
  late List<ItemVariation> jeanItemVariations;
  late BillAccount billAccount;
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

  test('creating so should be successful', () async {
    final lineItems = getLineItems(items: [Tuple2(5, shirtItemVariations), Tuple2(10, jeanItemVariations)]);

    final po = SaleOrder.create(
        accountId: billAccount.id!,
        date: DateTime.now(),
        currencyCode: CurrencyCode.AUD,
        lineItems: lineItems,
        subTotal: 10,
        total: 20,
        saleOrderNumber: "S0-00001",
        notes: const Some('Hello'));
    final poCreatedOrError = await saleOrderApi.create(saleOrder: po, teamId: teamId, token: firstUserAccessToken);

    expect(poCreatedOrError.isRight(), true);
    final createdPo = poCreatedOrError.toIterable().first;
    expect(createdPo.status.toIterable().first, SaleOrderStatus.issued);

    final whiteshirtLineItem = lineItems.where((element) => element.itemVariation.name == 'White Shirt').first;

    final poWhiteshirtLineItem =
        createdPo.lineItems.where((element) => element.itemVariation.name == 'White Shirt').first;

    expect(poWhiteshirtLineItem.quantity, whiteshirtLineItem.quantity);
    expect(poWhiteshirtLineItem.rateInDouble, whiteshirtLineItem.rateInDouble);
    expect(createdPo.saleOrderNumber, "S0-00001");
    expect(createdPo.notes, const Some('Hello'));
  });

  test('you can get back so', () async {
    final lineItems = getLineItemsWithRandomCount(items: shirtItemVariations +  jeanItemVariations);

    final accountListOrError = await billAccountApi.list(teamId: teamId, token: firstUserAccessToken);
    expect(accountListOrError.isRight(), true);
    expect(accountListOrError.toIterable().first.data.length == 1, true);
    final account = accountListOrError.toIterable().first.data.first;

    final so = SaleOrder.create(
        accountId: account.id!,
        date: DateTime.now(),
        currencyCode: CurrencyCode.AUD,
        lineItems: lineItems,
        subTotal: 10,
        total: 20,
        saleOrderNumber: "S0-00001");
    final soCreatedOrError = await saleOrderApi.create(saleOrder: so, teamId: teamId, token: firstUserAccessToken);

    expect(soCreatedOrError.isRight(), true);

    {
      final createdSo = soCreatedOrError.toIterable().first;

      final soOrError =
          await saleOrderApi.get(saleOrderId: createdSo.id!, teamId: teamId, token: firstUserAccessToken);
      expect(soOrError.isRight(), true);
    }
  });

  test('item utilization is correct after so is delivered', () async {
    final date = DateTime.now();

    {
      //add po first
      final po = PurchaseOrder.create(
          accountId: billAccount.id!,
          date: DateTime.now(),
          currencyCode: CurrencyCode.AUD,
          lineItems: getLineItems(items: [Tuple2(5, shirtItemVariations), Tuple2(10, jeanItemVariations)]),
          subTotal: 10,
          purchaseOrderNumber: "PO-0001",
          total: 20);
      final poCreatedOrError =
          await purchaseOrderApi.setToIssued(purchaseOrder: po, teamId: teamId, token: firstUserAccessToken);

      final createdPo = poCreatedOrError.toIterable().first;
      final now = DateTime.now();

      await purchaseOrderApi.setToReceived(
          purchaseOrderId: createdPo.id!, date: now, teamId: teamId, token: firstUserAccessToken);

      await Future.delayed(const Duration(seconds: 1));
      await purchaseOrderApi.get(purchaseOrderId: createdPo.id!, teamId: teamId, token: firstUserAccessToken);
    }
    {
      //deliver so
      final lineItems = getLineItems(items: [Tuple2(4, shirtItemVariations), Tuple2(8, jeanItemVariations)]);
      final po = SaleOrder.create(
          accountId: billAccount.id!,
          date: date,
          currencyCode: CurrencyCode.AUD,
          lineItems: lineItems,
          subTotal: 10,
          total: 20,
          saleOrderNumber: "S0-00001");
      final soCreatedOrError = await saleOrderApi.create(saleOrder: po, teamId: teamId, token: firstUserAccessToken);
      expect(soCreatedOrError.isRight(), true);

      final poItemsReceivedOrError = await saleOrderApi.setToDelivered(
          saleOrderId: soCreatedOrError.toIterable().first.id!,
          date: date,
          teamId: teamId,
          token: firstUserAccessToken);
      expect(poItemsReceivedOrError.isRight(), true);
      //sleep a while to update correctly
      await Future.delayed(const Duration(seconds: 1));
    }

    {
      final iuOrError = await itemApi.getItemUtilization(teamId: teamId, token: firstUserAccessToken);
      expect(iuOrError.isRight(), true);
      expect(iuOrError.toIterable().first.totalQuantityOfAllItemVariation, 6);
    }
  });

  test('you can change to delivered for so', () async {
    final date = DateTime.now();

    final so = SaleOrder.create(
        accountId: billAccount.id!,
        date: date,
        currencyCode: CurrencyCode.AUD,
        lineItems: getLineItems(items: [Tuple2(5, shirtItemVariations), Tuple2(10, jeanItemVariations)]),
        subTotal: 10,
        total: 20,
        saleOrderNumber: "S0-00001");
    final soCreatedOrError = await saleOrderApi.create(saleOrder: so, teamId: teamId, token: firstUserAccessToken);

    expect(soCreatedOrError.isRight(), true);
    final createdSo = soCreatedOrError.toIterable().first;

    // testing receiving items
    {
      final soItemDeliveredOrError = await saleOrderApi.setToDelivered(
          saleOrderId: createdSo.id!, date: date, teamId: teamId, token: firstUserAccessToken);
      expect(soItemDeliveredOrError.isRight(), true);
    }
  });

  test('you can change to delivered for so with more params', () async {
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
        sku: 'sku 234',
        salePriceMoney: salePriceMoney,
        purchasePriceMoney: purchasePriceMoney);
    final shirt = Item.create(name: "shirt", variations: [whiteShirt, blackShirt], unit: 'pcs');
    final request = CreateItemRequest(item: shirt, itemVariations: [whiteShirt, blackShirt]);

    final itemCreated =
        await itemApi.createItemRequest(request: request, teamId: teamId, token: firstUserAccessToken);
    expect(itemCreated.isRight(), true);

    final shirt1 = itemCreated.toIterable().first.variations[0];
    final shirt2 = itemCreated.toIterable().first.variations[1];

    final lineItem1 = LineItem.create(itemVariation: shirt1, rate: 3.5, quantity: 5, unit: 'cm');
    final lineItem2 = LineItem.create(itemVariation: shirt2, rate: 2.7, quantity: 4, unit: 'cm');

    final date = DateTime.now();

    final po = SaleOrder.create(
        accountId: billAccount.id!,
        date: date,
        currencyCode: CurrencyCode.AUD,
        lineItems: [lineItem1, lineItem2],
        subTotal: 10,
        total: 20,
        saleOrderNumber: "S0-00001");
    final poCreatedOrError = await saleOrderApi.create(saleOrder: po, teamId: teamId, token: firstUserAccessToken);

    expect(poCreatedOrError.isRight(), true);
    final createdSo = poCreatedOrError.toIterable().first;
    expect(createdSo.status.toIterable().first, SaleOrderStatus.issued);

    // testing receiving items

    final poItemsReceivedOrError = await saleOrderApi.setToDelivered(
        saleOrderId: createdSo.id!, date: date, teamId: teamId, token: firstUserAccessToken);
    expect(poItemsReceivedOrError.isRight(), true);
    //sleep a while to update correctly
    await Future.delayed(const Duration(seconds: 2));

    {
      //test delivered date
      final soOrError = await saleOrderApi.get(
        saleOrderId: createdSo.id!,
        teamId: teamId,
        token: firstUserAccessToken,
      );
      final so = soOrError.toIterable().first;
      expect(DateFormat('yyyy-MM-dd').format(so.deliveredAt!), DateFormat('yyyy-MM-dd').format(date));
    }

    {
      //test item increased after received
      final retrievedItemOrError = await itemApi.getItem(
          itemId: itemCreated.toIterable().first.id!, teamId: teamId, token: firstUserAccessToken);
      final item = retrievedItemOrError.toIterable().first;
      expect(item.variations[0].itemCount, -5);
      expect(item.variations[1].itemCount, -4);
    }

    {
      //check primary account is increased
      final accountListOrError = await billAccountApi.list(teamId: teamId, token: firstUserAccessToken);
      expect(accountListOrError.isRight(), true);
      expect(accountListOrError.toIterable().first.data.length == 1, true);
      final account = accountListOrError.toIterable().first.data.first;
      expect(account.balance, 28.3);
    }
  });

  test('you can delete the so with processig status', () async {
    final salePriceMoney = PriceMoney(amount: 10, currency: "SGD");
    final purchasePriceMoney = PriceMoney(amount: 5, currency: "SGD");

    final whiteShrt = ItemVariation.create(
        name: "White shirt",
        stockable: true,
        sku: 'sku 123',
        salePriceMoney: salePriceMoney,
        purchasePriceMoney: purchasePriceMoney);
    final shirt = Item.create(name: "shirt", variations: [whiteShrt], unit: 'kg');
  final request = CreateItemRequest(item: shirt, itemVariations: [whiteShrt]);

    final itemCreated = await itemApi.createItemRequest(request: request, teamId: teamId, token: firstUserAccessToken);
    expect(itemCreated.isRight(), true);

    final retrievedWhiteShirt = itemCreated.toIterable().first.variations.first;

    final lineItem = LineItem.create(itemVariation: retrievedWhiteShirt, rate: 2, quantity: 5, unit: 'cm');

    final accountListOrError = await billAccountApi.list(teamId: teamId, token: firstUserAccessToken);
    expect(accountListOrError.isRight(), true);
    expect(accountListOrError.toIterable().first.data.length == 1, true);
    final account = accountListOrError.toIterable().first.data.first;

    final so = SaleOrder.create(
        accountId: account.id!,
        date: DateTime.now(),
        currencyCode: CurrencyCode.AUD,
        lineItems: [lineItem],
        subTotal: 10,
        total: 20,
        saleOrderNumber: "S0-00001");
    final soCreatedOrError = await saleOrderApi.create(saleOrder: so, teamId: teamId, token: firstUserAccessToken);

    expect(soCreatedOrError.isRight(), true);

    {
      final createdSo = soCreatedOrError.toIterable().first;

      final deletedOrError =
          await saleOrderApi.delete(saleOrderId: createdSo.id!, teamId: teamId, token: firstUserAccessToken);
      expect(deletedOrError.isRight(), true);
    }

    {
      final createdSo = soCreatedOrError.toIterable().first;

      final soOrError =
          await saleOrderApi.get(saleOrderId: createdSo.id!, teamId: teamId, token: firstUserAccessToken);
      expect(soOrError.isRight(), false);
    }
  });

  test('item utilization is correct after so is delivered', () async {
    final date = DateTime.now();

    {
      //add po first
      final po = PurchaseOrder.create(
          accountId: billAccount.id!,
          date: DateTime.now(),
          currencyCode: CurrencyCode.AUD,
          lineItems: getLineItems(items: [Tuple2(5, shirtItemVariations), Tuple2(10, jeanItemVariations)]),
          subTotal: 10,
          purchaseOrderNumber: "PO-0001",
          total: 20);
      final poCreatedOrError =
          await purchaseOrderApi.setToIssued(purchaseOrder: po, teamId: teamId, token: firstUserAccessToken);

      final createdPo = poCreatedOrError.toIterable().first;
      final now = DateTime.now();

      await purchaseOrderApi.setToReceived(
          purchaseOrderId: createdPo.id!, date: now, teamId: teamId, token: firstUserAccessToken);

      await Future.delayed(const Duration(seconds: 1));
      await purchaseOrderApi.get(purchaseOrderId: createdPo.id!, teamId: teamId, token: firstUserAccessToken);
    }
    SaleOrder retrievedSo;
    {
      //deliver so
      final lineItems = getLineItems(items: [Tuple2(5, shirtItemVariations), Tuple2(10, jeanItemVariations)]);
      final so = SaleOrder.create(
          accountId: billAccount.id!,
          date: date,
          currencyCode: CurrencyCode.AUD,
          lineItems: lineItems,
          subTotal: 10,
          total: 20,
          saleOrderNumber: "S0-00001");
      final soCreatedOrError = await saleOrderApi.create(saleOrder: so, teamId: teamId, token: firstUserAccessToken);
      retrievedSo = soCreatedOrError.toIterable().first;

      final soItemsReceivedOrError = await saleOrderApi.setToDelivered(
          saleOrderId: retrievedSo.id!, date: date, teamId: teamId, token: firstUserAccessToken);

      expect(soItemsReceivedOrError.isRight(), true);
      //sleep a while to update correctly
      await Future.delayed(const Duration(seconds: 1));
    }
    {
      final deletedOrError =
          await saleOrderApi.delete(saleOrderId: retrievedSo.id!, teamId: teamId, token: firstUserAccessToken);
      expect(deletedOrError.isRight(), true);
    }
    {
      final iuOrError = await itemApi.getItemUtilization(teamId: teamId, token: firstUserAccessToken);
      expect(iuOrError.isRight(), true);
      expect(iuOrError.toIterable().first.totalQuantityOfAllItemVariation, 30);
    }
  });

  test('you can delete the so with delivered status', () async {
    final salePriceMoney = PriceMoney(amount: 10, currency: "SGD");
    final purchasePriceMoney = PriceMoney(amount: 5, currency: "SGD");

    final whiteShrt = ItemVariation.create(
        name: "White shirt",
        stockable: true,
        sku: 'sku 123',
        salePriceMoney: salePriceMoney,
        purchasePriceMoney: purchasePriceMoney);
    final shirt = Item.create(name: "shirt", variations: [whiteShrt], unit: 'kg');

     final request = CreateItemRequest(item: shirt, itemVariations: [whiteShrt]);

    final itemCreated = await itemApi.createItemRequest(request: request, teamId: teamId, token: firstUserAccessToken);
    expect(itemCreated.isRight(), true);

    final retrievedWhiteShirt = itemCreated.toIterable().first.variations.first;

    final lineItem = LineItem.create(itemVariation: retrievedWhiteShirt, rate: 2, quantity: 5, unit: 'cm');

    final accountListOrError = await billAccountApi.list(teamId: teamId, token: firstUserAccessToken);
    expect(accountListOrError.isRight(), true);
    expect(accountListOrError.toIterable().first.data.length == 1, true);
    final account = accountListOrError.toIterable().first.data.first;

    final so = SaleOrder.create(
        accountId: account.id!,
        date: DateTime.now(),
        currencyCode: CurrencyCode.AUD,
        lineItems: [lineItem],
        subTotal: 10,
        total: 20,
        saleOrderNumber: "S0-00001");
    final soCreatedOrError = await saleOrderApi.create(saleOrder: so, teamId: teamId, token: firstUserAccessToken);

    expect(soCreatedOrError.isRight(), true);

    final createdSo = soCreatedOrError.toIterable().first;
    final poItemsReceivedOrError = await saleOrderApi.setToDelivered(
        saleOrderId: createdSo.id!, date: DateTime.now(), teamId: teamId, token: firstUserAccessToken);
    expect(poItemsReceivedOrError.isRight(), true);
    //sleep a while to update correctly
    await Future.delayed(const Duration(seconds: 2));

    {
      //test item increased after received
      final retrievedItemOrError = await itemApi.getItem(
          itemId: itemCreated.toIterable().first.id!, teamId: teamId, token: firstUserAccessToken);
      final item = retrievedItemOrError.toIterable().first;
      expect(item.variations.first.itemCount, -5);
    }

    {
      //check primary account is increased
      final accountListOrError = await billAccountApi.list(teamId: teamId, token: firstUserAccessToken);
      expect(accountListOrError.isRight(), true);
      expect(accountListOrError.toIterable().first.data.length == 1, true);
      final account = accountListOrError.toIterable().first.data.first;
      expect(account.balance, 10);
    }

    {
      final deletedOrError =
          await saleOrderApi.delete(saleOrderId: createdSo.id!, teamId: teamId, token: firstUserAccessToken);
      expect(deletedOrError.isRight(), true);
    }

    {
      //test item count is back to zero
      final retrievedItemOrError = await itemApi.getItem(
          itemId: itemCreated.toIterable().first.id!, teamId: teamId, token: firstUserAccessToken);
      final item = retrievedItemOrError.toIterable().first;
      expect(item.variations.first.itemCount, 0);
    }

    {
      //check primary account balance is back to zero
      final accountListOrError = await billAccountApi.list(teamId: teamId, token: firstUserAccessToken);
      expect(accountListOrError.isRight(), true);
      expect(accountListOrError.toIterable().first.data.length == 1, true);
      final account = accountListOrError.toIterable().first.data.first;
      expect(account.balance, 0);
    }
  });
}
