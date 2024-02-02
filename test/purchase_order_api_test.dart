import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:inventory_frontend/data/bill.account/bill.account.repository.dart';
import 'package:inventory_frontend/data/currency.code/valueobject.dart';
import 'package:inventory_frontend/data/item/item.repository.dart';
import 'package:inventory_frontend/data/purchase.order/purchase.order.repository.dart';
import 'package:inventory_frontend/data/team/team.repository.dart';
import 'package:inventory_frontend/domain/item/entities.dart';
import 'package:inventory_frontend/domain/purchase.order/entities.dart';
import 'package:inventory_frontend/domain/purchase.order/search.field.dart';
import 'package:inventory_frontend/domain/purchase.order/valueobject.dart';
import 'package:inventory_frontend/domain/team/entities.dart';

import 'helpers/sign.in.response.dart';
import 'helpers/test.helper.dart';

void main() async {
  final teamApi = TeamRepository();
  final itemApi = ItemRepository();
  final purchaseOrderApi = PurchaseOrderRepository();
  final billAccountApi = BillAccountRepository();
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

  Item getShirt() {
    final salePriceMoney = PriceMoney(amount: Random().nextInt(1000) + 1000, currency: "SGD");
    final purchasePriceMoney = PriceMoney(amount: Random().nextInt(1000) + 1000, currency: "SGD");

    final whiteShirt = ItemVariation.create(
        name: "White Shirt",
        stockable: true,
        sku: 'sku 123',
        salePriceMoney: salePriceMoney,
        purchasePriceMoney: purchasePriceMoney);

    final blackShirt = ItemVariation.create(
        name: "Black Shirt",
        stockable: true,
        sku: 'sku 234',
        salePriceMoney: salePriceMoney,
        purchasePriceMoney: purchasePriceMoney);

    return Item.create(name: "shirt", variations: [whiteShirt, blackShirt], unit: 'pcs');
  }

  Item getJean() {
    final salePriceMoney = PriceMoney(amount: Random().nextInt(1000) + 1000, currency: "SGD");
    final purchasePriceMoney = PriceMoney(amount: Random().nextInt(1000) + 1000, currency: "SGD");

    final whiteJean = ItemVariation.create(
        name: "White Jean",
        stockable: true,
        sku: 'sku 123',
        salePriceMoney: salePriceMoney,
        purchasePriceMoney: purchasePriceMoney);

    final blackJean = ItemVariation.create(
        name: "Black Jean",
        stockable: true,
        sku: 'sku 234',
        salePriceMoney: salePriceMoney,
        purchasePriceMoney: purchasePriceMoney);

    return Item.create(name: "jeans", variations: [whiteJean, blackJean], unit: 'pcs');
  }

  Future<List<LineItem>> getLineItem({required String teamId}) async {
    final shirt = getShirt();
    final shirtCreated = await itemApi.createItem(item: shirt, teamId: teamId, token: firstUserAccessToken);
    expect(shirtCreated.isRight(), true);
    final shirtLineItems = shirtCreated
        .toIterable()
        .first
        .variations
        .map((e) => LineItem.create(
            itemVariation: e,
            rate: e.purchasePriceMoney.amountInDouble,
            quantity: Random().nextInt(1) + 5,
            unit: "pcs"))
        .toList();

    final jean = getJean();
    final jeanCreated = await itemApi.createItem(item: jean, teamId: teamId, token: firstUserAccessToken);
    expect(jeanCreated.isRight(), true);
    final jeanLineItems = jeanCreated
        .toIterable()
        .first
        .variations
        .map((e) => LineItem.create(
            itemVariation: e,
            rate: e.purchasePriceMoney.amountInDouble,
            quantity: Random().nextInt(1) + 5,
            unit: "pcs"))
        .toList();
    return shirtLineItems + jeanLineItems;
  }

  test('creating po should be successful', () async {
    final newTeam = Team.create(name: 'Power Ranger', timeZone: "Africa/Abidjan", currencyCode: CurrencyCode.AUD);
    final createdOrError = await teamApi.create(team: newTeam, token: firstUserAccessToken);
    expect(createdOrError.isRight(), true);
    final team = createdOrError.toIterable().first;
    final accountListOrError = await billAccountApi.list(teamId: team.id!, token: firstUserAccessToken);
    expect(accountListOrError.isRight(), true);
    final account = accountListOrError.toIterable().first.data.first;

    final po = PurchaseOrder.create(
        accountId: account.id!,
        date: DateTime.now(),
        currencyCode: CurrencyCode.AUD,
        lineItems: await getLineItem(teamId: team.id!),
        subTotal: 10,
        purchaseOrderNumber: "PO-0001",
        total: 20);
    final poCreatedOrError =
        await purchaseOrderApi.issuedPurchaseOrder(purchaseOrder: po, teamId: team.id!, token: firstUserAccessToken);

    expect(poCreatedOrError.isRight(), true);
    final createdPo = poCreatedOrError.toIterable().first;
    expect(createdPo.status, 'issued');
    expect(createdPo.purchaseOrderNumber, "PO-0001");
  });

  test('you can get po', () async {
    final newTeam = Team.create(name: 'Power Ranger', timeZone: "Africa/Abidjan", currencyCode: CurrencyCode.AUD);
    final createdOrError = await teamApi.create(team: newTeam, token: firstUserAccessToken);
    expect(createdOrError.isRight(), true);
    final team = createdOrError.toIterable().first;
    final accountListOrError = await billAccountApi.list(teamId: team.id!, token: firstUserAccessToken);
    expect(accountListOrError.isRight(), true);
    final account = accountListOrError.toIterable().first.data.first;

    final po = PurchaseOrder.create(
        accountId: account.id!,
        date: DateTime.now(),
        currencyCode: CurrencyCode.AUD,
        purchaseOrderNumber: "PO-0001",
        lineItems: await getLineItem(teamId: team.id!),
        subTotal: 10,
        total: 20);
    final poCreatedOrError =
        await purchaseOrderApi.issuedPurchaseOrder(purchaseOrder: po, teamId: team.id!, token: firstUserAccessToken);

    expect(poCreatedOrError.isRight(), true);
    final createdPo = poCreatedOrError.toIterable().first;

    {
      final poOrError =
          await purchaseOrderApi.get(purchaseOrderId: createdPo.id!, teamId: team.id!, token: firstUserAccessToken);
      expect(poOrError.isRight(), true);
      expect(poOrError.toIterable().first.status, 'issued');
    }
  });

  test('you can list po', () async {
    final newTeam = Team.create(name: 'Power Ranger', timeZone: "Africa/Abidjan", currencyCode: CurrencyCode.AUD);
    final createdOrError = await teamApi.create(team: newTeam, token: firstUserAccessToken);
    expect(createdOrError.isRight(), true);
    final team = createdOrError.toIterable().first;

    final lineItems = await getLineItem(teamId: team.id!);

    final accountListOrError = await billAccountApi.list(teamId: team.id!, token: firstUserAccessToken);
    expect(accountListOrError.isRight(), true);
    final account = accountListOrError.toIterable().first.data.first;

    final po = PurchaseOrder.create(
      accountId: account.id!,
      date: DateTime.now(),
      currencyCode: CurrencyCode.AUD,
      lineItems: lineItems,
      subTotal: 10,
      total: 20,
      purchaseOrderNumber: "PO-0001",
    );
    final poCreatedOrError =
        await purchaseOrderApi.issuedPurchaseOrder(purchaseOrder: po, teamId: team.id!, token: firstUserAccessToken);

    expect(poCreatedOrError.isRight(), true);

    {
      final poOrError = await purchaseOrderApi.list(teamId: team.id!, token: firstUserAccessToken);
      expect(poOrError.isRight(), true);
      expect(poOrError.toIterable().first.data.isNotEmpty, true);
    }
  });

  test('you can list po with search', () async {
    final newTeam = Team.create(name: 'Power Ranger', timeZone: "Africa/Abidjan", currencyCode: CurrencyCode.AUD);
    final createdOrError = await teamApi.create(team: newTeam, token: firstUserAccessToken);
    expect(createdOrError.isRight(), true);
    final team = createdOrError.toIterable().first;

    final lineItems = await getLineItem(teamId: team.id!);

    final accountListOrError = await billAccountApi.list(teamId: team.id!, token: firstUserAccessToken);
    expect(accountListOrError.isRight(), true);
    final account = accountListOrError.toIterable().first.data.first;

    final po = PurchaseOrder.create(
      accountId: account.id!,
      date: DateTime.now(),
      currencyCode: CurrencyCode.AUD,
      lineItems: lineItems,
      subTotal: 10,
      total: 20,
      purchaseOrderNumber: "PO-0001",
    );
    final poCreatedOrError =
        await purchaseOrderApi.issuedPurchaseOrder(purchaseOrder: po, teamId: team.id!, token: firstUserAccessToken);

    expect(poCreatedOrError.isRight(), true);

    {
      // for issued, we have a list with one po
      final searchField = PurchaseOrderSearchField(status: PurchaseOrderStatus.issued);
      final poListOrError =
          await purchaseOrderApi.list(teamId: team.id!, token: firstUserAccessToken, searchField: searchField);
      expect(poListOrError.isRight(), true);
      expect(poListOrError.toIterable().first.data.length, 1);
    }
    {
      // for received, we have a empty list
      final searchField = PurchaseOrderSearchField(status: PurchaseOrderStatus.received);
      final poListOrError =
          await purchaseOrderApi.list(teamId: team.id!, token: firstUserAccessToken, searchField: searchField);
      expect(poListOrError.isRight(), true);
      expect(poListOrError.toIterable().first.data.isEmpty, true);
    }

    {
      // receiving items
      final now = DateTime.now();
      await purchaseOrderApi.receivedItems(
          purchaseOrderId: poCreatedOrError.toIterable().first.id!,
          date: now,
          teamId: team.id!,
          token: firstUserAccessToken);

      await Future.delayed(const Duration(seconds: 2));

      final poOrError = await purchaseOrderApi.get(
          purchaseOrderId: poCreatedOrError.toIterable().first.id!, teamId: team.id!, token: firstUserAccessToken);
      final po = poOrError.toIterable().first;
      expect(po.receivedAt, DateFormat('yyyy-MM-dd').format(now));
    }
    {
      // for issued, we have a empty list
      final searchField = PurchaseOrderSearchField(status: PurchaseOrderStatus.issued);
      final poListOrError =
          await purchaseOrderApi.list(teamId: team.id!, token: firstUserAccessToken, searchField: searchField);
      expect(poListOrError.isRight(), true);
      expect(poListOrError.toIterable().first.data.isEmpty, true);
    }
    {
      // for received, we have a list with one po
      final searchField = PurchaseOrderSearchField(status: PurchaseOrderStatus.received);
      final poListOrError =
          await purchaseOrderApi.list(teamId: team.id!, token: firstUserAccessToken, searchField: searchField);
      expect(poListOrError.isRight(), true);
      expect(poListOrError.toIterable().first.data.length, 1);
    }
  });

  test('you can received item from po', () async {
    final newTeam = Team.create(name: 'Power Ranger', timeZone: "Africa/Abidjan", currencyCode: CurrencyCode.AUD);
    final createdOrError = await teamApi.create(team: newTeam, token: firstUserAccessToken);
    expect(createdOrError.isRight(), true);
    final team = createdOrError.toIterable().first;

    final accountListOrError = await billAccountApi.list(teamId: team.id!, token: firstUserAccessToken);
    expect(accountListOrError.isRight(), true);
    final account = accountListOrError.toIterable().first.data.first;
    final lineItems = await getLineItem(teamId: team.id!);
    final po = PurchaseOrder.create(
        purchaseOrderNumber: "PO-0001",
        accountId: account.id!,
        date: DateTime.now(),
        currencyCode: CurrencyCode.AUD,
        lineItems: lineItems,
        subTotal: 10,
        total: 20);
    final poCreatedOrError =
        await purchaseOrderApi.issuedPurchaseOrder(purchaseOrder: po, teamId: team.id!, token: firstUserAccessToken);

    expect(poCreatedOrError.isRight(), true);
    final createdPo = poCreatedOrError.toIterable().first;
    expect(createdPo.status, 'issued');

    //sleep a while to update correctly
    await Future.delayed(const Duration(seconds: 1));

    // testing receiving items
    {
      final now = DateTime.now();
      await purchaseOrderApi.receivedItems(
          purchaseOrderId: createdPo.id!, date: now, teamId: team.id!, token: firstUserAccessToken);

      await Future.delayed(const Duration(seconds: 2));

      final poOrError =
          await purchaseOrderApi.get(purchaseOrderId: createdPo.id!, teamId: team.id!, token: firstUserAccessToken);
      final po = poOrError.toIterable().first;
      expect(po.receivedAt, DateFormat('yyyy-MM-dd').format(now));
    }

    //sleep a while to update correctly
    await Future.delayed(const Duration(seconds: 1));

    {
      final whiteshirtLineItem = lineItems.where((element) => element.itemVariation.name == 'White Shirt').first;
      final blackshirtLineItem = lineItems.where((element) => element.itemVariation.name == 'Black Shirt').first;
      final retrievedItemOrError = await itemApi.getItem(
          itemId: whiteshirtLineItem.itemVariation.itemId!, teamId: team.id!, token: firstUserAccessToken);
      final whiteShirtItemVariation =
          retrievedItemOrError.toIterable().first.variations.where((element) => element.name == 'White Shirt').first;
      expect(whiteShirtItemVariation.itemCount, whiteshirtLineItem.quantity);
      final blackShirtItemVariation =
          retrievedItemOrError.toIterable().first.variations.where((element) => element.name == 'Black Shirt').first;
      expect(blackShirtItemVariation.itemCount, blackshirtLineItem.quantity);
    }

    {
      //check jean item count
      final whiteJeanLineItem = lineItems.where((element) => element.itemVariation.name == 'White Jean').first;
      final blackJeanLineItem = lineItems.where((element) => element.itemVariation.name == 'Black Jean').first;
      final retrievedItemOrError = await itemApi.getItem(
          itemId: whiteJeanLineItem.itemVariation.itemId!, teamId: team.id!, token: firstUserAccessToken);
      final whiteShirtItemVariation =
          retrievedItemOrError.toIterable().first.variations.where((element) => element.name == 'White Jean').first;
      expect(whiteShirtItemVariation.itemCount, whiteJeanLineItem.quantity);
      final blackShirtItemVariation =
          retrievedItemOrError.toIterable().first.variations.where((element) => element.name == 'Black Jean').first;
      expect(blackShirtItemVariation.itemCount, blackJeanLineItem.quantity);
    }

    {
      //check primary account's balance
      final total =
          lineItems.map((e) => e.quantity * e.rate).fold(0, (previousValue, element) => previousValue + element);
      final accountListOrError = await billAccountApi.list(teamId: team.id!, token: firstUserAccessToken);
      expect(accountListOrError.isRight(), true);
      expect(accountListOrError.toIterable().first.data.length == 1, true);
      final account = accountListOrError.toIterable().first.data.first;
      expect(account.balance, (total / 1000) * -1);
    }
  });

  test('you can delete po with issued state', () async {
    final newTeam = Team.create(name: 'Power Ranger', timeZone: "Africa/Abidjan", currencyCode: CurrencyCode.AUD);
    final createdOrError = await teamApi.create(team: newTeam, token: firstUserAccessToken);
    expect(createdOrError.isRight(), true);
    final team = createdOrError.toIterable().first;

    final lineItems = await getLineItem(teamId: team.id!);

    final accountListOrError = await billAccountApi.list(teamId: team.id!, token: firstUserAccessToken);
    expect(accountListOrError.isRight(), true);
    final account = accountListOrError.toIterable().first.data.first;

    final po = PurchaseOrder.create(
        purchaseOrderNumber: "PO-0001",
        accountId: account.id!,
        date: DateTime.now(),
        currencyCode: CurrencyCode.AUD,
        lineItems: lineItems,
        subTotal: 10,
        total: 20);
    final poCreatedOrError =
        await purchaseOrderApi.issuedPurchaseOrder(purchaseOrder: po, teamId: team.id!, token: firstUserAccessToken);

    expect(poCreatedOrError.isRight(), true);
    final createdPo = poCreatedOrError.toIterable().first;
    expect(createdPo.status, 'issued');

    {
      final deletedOrError = await purchaseOrderApi.delete(
        purchaseOrderId: createdPo.id!,
        teamId: team.id!,
        token: firstUserAccessToken,
      );
      expect(deletedOrError.isRight(), true);
    }
  });

  test('you can delete po with received state', () async {
    final newTeam = Team.create(name: 'Power Ranger', timeZone: "Africa/Abidjan", currencyCode: CurrencyCode.AUD);
    final createdOrError = await teamApi.create(team: newTeam, token: firstUserAccessToken);
    expect(createdOrError.isRight(), true);
    final team = createdOrError.toIterable().first;

    final accountListOrError = await billAccountApi.list(teamId: team.id!, token: firstUserAccessToken);
    expect(accountListOrError.isRight(), true);
    final account = accountListOrError.toIterable().first.data.first;
    final lineItems = await getLineItem(teamId: team.id!);
    final po = PurchaseOrder.create(
        purchaseOrderNumber: "PO-0001",
        accountId: account.id!,
        date: DateTime.now(),
        currencyCode: CurrencyCode.AUD,
        lineItems: lineItems,
        subTotal: 10,
        total: 20);
    final poCreatedOrError =
        await purchaseOrderApi.issuedPurchaseOrder(purchaseOrder: po, teamId: team.id!, token: firstUserAccessToken);

    expect(poCreatedOrError.isRight(), true);
    final createdPo = poCreatedOrError.toIterable().first;
    expect(createdPo.status, 'issued');
    final poItemsReceivedOrError = await purchaseOrderApi.receivedItems(
        purchaseOrderId: createdPo.id!, date: DateTime.now(), teamId: team.id!, token: firstUserAccessToken);
    expect(poItemsReceivedOrError.isRight(), true);

    //sleep a while to update correctly
    await Future.delayed(const Duration(seconds: 2));

    {
      final deletedOrError = await purchaseOrderApi.delete(
        purchaseOrderId: createdPo.id!,
        teamId: team.id!,
        token: firstUserAccessToken,
      );
      expect(deletedOrError.isRight(), true);
    }

    //sleep a while to update correctly
    await Future.delayed(const Duration(seconds: 2));

    {
      // check all item count reset back to zero
      final itemIds = lineItems.map((e) => e.itemVariation.itemId!).toSet();
      for (var itemId in itemIds) {
        final retrievedItemsOrError =
            await itemApi.getItem(itemId: itemId, teamId: team.id!, token: firstUserAccessToken);
        final itemVariations = retrievedItemsOrError.toIterable().first.variations;
        for (var iv in itemVariations) {
          expect(iv.itemCount, 0);
        }
      }
    }

    {
      //check primary account balance is correct
      final accountListOrError = await billAccountApi.list(teamId: team.id!, token: firstUserAccessToken);
      expect(accountListOrError.isRight(), true);
      expect(accountListOrError.toIterable().first.data.length == 1, true);
      final account = accountListOrError.toIterable().first.data.first;
      expect(account.balance, 0);
    }
  });
}
