import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:warelake/data/bill.account/bill.account.repository.dart';
import 'package:warelake/data/currency.code/valueobject.dart';
import 'package:warelake/data/item/item.repository.dart';
import 'package:warelake/data/purchase.order/purchase.order.repository.dart';
import 'package:warelake/data/team/team.repository.dart';
import 'package:warelake/domain/bill.account/entities.dart';
import 'package:warelake/domain/item/entities.dart';
import 'package:warelake/domain/purchase.order/entities.dart';
import 'package:warelake/domain/purchase.order/search.field.dart';
import 'package:warelake/domain/purchase.order/valueobject.dart';
import 'package:warelake/domain/team/entities.dart';

import '../helpers/sign.in.response.dart';
import '../helpers/test.helper.dart';

void main() async {
  final teamApi = TeamRepository();
  final itemApi = ItemRepository();
  final purchaseOrderApi = PurchaseOrderRepository();
  final billAccountApi = BillAccountRepository();
  late String firstUserAccessToken;
  late Item shirtItem;
  late Item jeanItem;
  late BillAccount billAccount;
  late Team team;

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
    final accountListOrError = await billAccountApi.list(teamId: team.id!, token: firstUserAccessToken);
    expect(accountListOrError.isRight(), true);
    billAccount = accountListOrError.toIterable().first.data.first;

    final shirt = getShirt();
    final jean = getJean();

    final shirtCreatedOrError = await itemApi.createItem(item: shirt, teamId: team.id!, token: firstUserAccessToken);
    shirtItem = shirtCreatedOrError.toIterable().first;

    final jeansCreatedOrError = await itemApi.createItem(item: jean, teamId: team.id!, token: firstUserAccessToken);
    jeanItem = jeansCreatedOrError.toIterable().first;
  });

  test('creating po should be successful', () async {
    final po = PurchaseOrder.create(
        accountId: billAccount.id!,
        date: DateTime.now(),
        currencyCode: CurrencyCode.AUD,
        lineItems: getLineItems(items: [Tuple2(5, shirtItem), Tuple2(10, jeanItem)]),
        subTotal: 10,
        purchaseOrderNumber: "PO-0001",
        total: 20);
    final poCreatedOrError =
        await purchaseOrderApi.setToIssued(purchaseOrder: po, teamId: team.id!, token: firstUserAccessToken);

    expect(poCreatedOrError.isRight(), true);
    final createdPo = poCreatedOrError.toIterable().first;
    expect(createdPo.status, 'issued');
    expect(createdPo.purchaseOrderNumber, "PO-0001");
  });

  test('check totalQuantityOfAllItemVariation after po issued', () async {
    final po = PurchaseOrder.create(
        accountId: billAccount.id!,
        date: DateTime.now(),
        currencyCode: CurrencyCode.AUD,
        lineItems: getLineItems(items: [Tuple2(5, shirtItem), Tuple2(10, jeanItem)]),
        subTotal: 10,
        purchaseOrderNumber: "PO-0001",
        total: 20);

    final poCreatedOrError =
        await purchaseOrderApi.setToIssued(purchaseOrder: po, teamId: team.id!, token: firstUserAccessToken);

    expect(poCreatedOrError.isRight(), true);

    {
      final iuOrError = await itemApi.getItemUtilization(teamId: team.id!, token: firstUserAccessToken);
      expect(iuOrError.isRight(), true);
      expect(iuOrError.toIterable().first.totalQuantityOfAllItemVariation, 0);
    }
  });

  test('you can get po', () async {
    final po = PurchaseOrder.create(
        accountId: billAccount.id!,
        date: DateTime.now(),
        currencyCode: CurrencyCode.AUD,
        purchaseOrderNumber: "PO-0001",
        lineItems: getLineItems(items: [Tuple2(5, shirtItem), Tuple2(10, jeanItem)]),
        subTotal: 10,
        total: 20);
    final poCreatedOrError =
        await purchaseOrderApi.setToIssued(purchaseOrder: po, teamId: team.id!, token: firstUserAccessToken);

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
    final lineItems = getLineItems(items: [Tuple2(5, shirtItem), Tuple2(10, jeanItem)]);

    final po = PurchaseOrder.create(
      accountId: billAccount.id!,
      date: DateTime.now(),
      currencyCode: CurrencyCode.AUD,
      lineItems: lineItems,
      subTotal: 10,
      total: 20,
      purchaseOrderNumber: "PO-0001",
    );
    final poCreatedOrError =
        await purchaseOrderApi.setToIssued(purchaseOrder: po, teamId: team.id!, token: firstUserAccessToken);

    expect(poCreatedOrError.isRight(), true);

    {
      final poOrError = await purchaseOrderApi.list(teamId: team.id!, token: firstUserAccessToken);
      expect(poOrError.isRight(), true);
      expect(poOrError.toIterable().first.data.isNotEmpty, true);
    }
  });

  test('you can list po with empty search field', () async {
    final lineItems = getLineItems(items: [Tuple2(5, shirtItem), Tuple2(10, jeanItem)]);

    final po = PurchaseOrder.create(
      accountId: billAccount.id!,
      date: DateTime.now(),
      currencyCode: CurrencyCode.AUD,
      lineItems: lineItems,
      subTotal: 10,
      total: 20,
      purchaseOrderNumber: "PO-0001",
    );
    final poCreatedOrError =
        await purchaseOrderApi.setToIssued(purchaseOrder: po, teamId: team.id!, token: firstUserAccessToken);

    expect(poCreatedOrError.isRight(), true);

    {
      final searchField = PurchaseOrderSearchField();
      final poOrError =
          await purchaseOrderApi.list(teamId: team.id!, token: firstUserAccessToken, searchField: searchField);
      expect(poOrError.isRight(), true);
      expect(poOrError.toIterable().first.data.isNotEmpty, true);
    }
  });

  test('you can list po with last created item', () async {
    final lineItems = getLineItems(items: [Tuple2(5, shirtItem), Tuple2(10, jeanItem)]);
    PurchaseOrder firstPo;
    {
      final po = PurchaseOrder.create(
        accountId: billAccount.id!,
        date: DateTime.now(),
        currencyCode: CurrencyCode.AUD,
        lineItems: lineItems,
        subTotal: 10,
        total: 20,
        purchaseOrderNumber: "PO-0001",
      );
      final poCreatedOrError =
          await purchaseOrderApi.setToIssued(purchaseOrder: po, teamId: team.id!, token: firstUserAccessToken);
      firstPo = poCreatedOrError.toIterable().first;
      await Future.delayed(const Duration(seconds: 1));
    }
    PurchaseOrder secondPo;
    {
      final po = PurchaseOrder.create(
        accountId: billAccount.id!,
        date: DateTime.now(),
        currencyCode: CurrencyCode.AUD,
        lineItems: lineItems,
        subTotal: 10,
        total: 20,
        purchaseOrderNumber: "PO-0002",
      );
      final poCreatedOrError =
          await purchaseOrderApi.setToIssued(purchaseOrder: po, teamId: team.id!, token: firstUserAccessToken);
      secondPo = poCreatedOrError.toIterable().first;
      await Future.delayed(const Duration(seconds: 1));
    }

    {
      // final searchField = PurchaseOrderSearchField();
      final poListOrError = await purchaseOrderApi.list(teamId: team.id!, token: firstUserAccessToken);
      expect(poListOrError.isRight(), true);
      final poList = poListOrError.toIterable().first;
      expect(poList.data.length, 2);
      expect(poList.data.first.purchaseOrderNumber, 'PO-0002');
    }
    {
      // we will not see first PO after second PO
      final searchField = PurchaseOrderSearchField(startingAfterPurchaseOrderId: secondPo.id!);
      final poListOrError =
          await purchaseOrderApi.list(teamId: team.id!, token: firstUserAccessToken, searchField: searchField);
      expect(poListOrError.isRight(), true);
      final poList = poListOrError.toIterable().first;
      expect(poList.data.length, 1);
      expect(poList.data.first.purchaseOrderNumber, 'PO-0001');
    }

    {
      // we will not see any po after first PO
      final searchField = PurchaseOrderSearchField(startingAfterPurchaseOrderId: firstPo.id!);
      final poListOrError =
          await purchaseOrderApi.list(teamId: team.id!, token: firstUserAccessToken, searchField: searchField);
      expect(poListOrError.isRight(), true);
      final poList = poListOrError.toIterable().first;
      expect(poList.data.isEmpty, true);
    }
  });

  test('you can list po with search', () async {
    final lineItems = getLineItems(items: [Tuple2(5, shirtItem), Tuple2(10, jeanItem)]);

    final po = PurchaseOrder.create(
      accountId: billAccount.id!,
      date: DateTime.now(),
      currencyCode: CurrencyCode.AUD,
      lineItems: lineItems,
      subTotal: 10,
      total: 20,
      purchaseOrderNumber: "PO-0001",
    );
    final poCreatedOrError =
        await purchaseOrderApi.setToIssued(purchaseOrder: po, teamId: team.id!, token: firstUserAccessToken);

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
      await purchaseOrderApi.setToReceived(
          purchaseOrderId: poCreatedOrError.toIterable().first.id!,
          date: now,
          teamId: team.id!,
          token: firstUserAccessToken);

      await Future.delayed(const Duration(seconds: 2));

      final poOrError = await purchaseOrderApi.get(
          purchaseOrderId: poCreatedOrError.toIterable().first.id!, teamId: team.id!, token: firstUserAccessToken);
      final po = poOrError.toIterable().first;
      expect(DateFormat('yyyy-MM-dd').format(po.receivedAt!), DateFormat('yyyy-MM-dd').format(now));
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
    final lineItems = getLineItems(items: [Tuple2(5, shirtItem), Tuple2(10, jeanItem)]);
    final po = PurchaseOrder.create(
        purchaseOrderNumber: "PO-0001",
        accountId: billAccount.id!,
        date: DateTime.now(),
        currencyCode: CurrencyCode.AUD,
        lineItems: lineItems,
        subTotal: 10,
        total: 20);
    final poCreatedOrError =
        await purchaseOrderApi.setToIssued(purchaseOrder: po, teamId: team.id!, token: firstUserAccessToken);

    expect(poCreatedOrError.isRight(), true);
    final createdPo = poCreatedOrError.toIterable().first;

    //sleep a while to update correctly
    await Future.delayed(const Duration(seconds: 1));

    // testing receiving items
    {
      final now = DateTime.now();
      await purchaseOrderApi.setToReceived(
          purchaseOrderId: createdPo.id!, date: now, teamId: team.id!, token: firstUserAccessToken);

      await Future.delayed(const Duration(seconds: 2));

      final poOrError =
          await purchaseOrderApi.get(purchaseOrderId: createdPo.id!, teamId: team.id!, token: firstUserAccessToken);
      final po = poOrError.toIterable().first;
      expect( DateFormat('yyyy-MM-dd').format(po.receivedAt!), DateFormat('yyyy-MM-dd').format(now));
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

  test('check totalQuantityOfAllItemVariation after po received', () async {
    final lineItems = getLineItems(items: [Tuple2(5, shirtItem), Tuple2(10, jeanItem)]);
    final po = PurchaseOrder.create(
        purchaseOrderNumber: "PO-0001",
        accountId: billAccount.id!,
        date: DateTime.now(),
        currencyCode: CurrencyCode.AUD,
        lineItems: lineItems,
        subTotal: 10,
        total: 20);
    final poCreatedOrError =
        await purchaseOrderApi.setToIssued(purchaseOrder: po, teamId: team.id!, token: firstUserAccessToken);

    expect(poCreatedOrError.isRight(), true);
    final createdPo = poCreatedOrError.toIterable().first;

    //sleep a while to update correctly
    await Future.delayed(const Duration(seconds: 1));

    // testing receiving items
    {
      final now = DateTime.now();
      await purchaseOrderApi.setToReceived(
          purchaseOrderId: createdPo.id!, date: now, teamId: team.id!, token: firstUserAccessToken);

      await Future.delayed(const Duration(seconds: 2));

      final poOrError =
          await purchaseOrderApi.get(purchaseOrderId: createdPo.id!, teamId: team.id!, token: firstUserAccessToken);
      expect(poOrError.isRight(), true);
    }

    //sleep a while to update correctly
    await Future.delayed(const Duration(seconds: 1));

    {
      final iuOrError = await itemApi.getItemUtilization(teamId: team.id!, token: firstUserAccessToken);
      expect(iuOrError.isRight(), true);
      expect(iuOrError.toIterable().first.totalQuantityOfAllItemVariation, 30);
    }
  });

  test('you can delete po with issued state', () async {
    final lineItems = getLineItems(items: [Tuple2(5, shirtItem), Tuple2(10, jeanItem)]);

    final po = PurchaseOrder.create(
        purchaseOrderNumber: "PO-0001",
        accountId: billAccount.id!,
        date: DateTime.now(),
        currencyCode: CurrencyCode.AUD,
        lineItems: lineItems,
        subTotal: 10,
        total: 20);
    final poCreatedOrError =
        await purchaseOrderApi.setToIssued(purchaseOrder: po, teamId: team.id!, token: firstUserAccessToken);

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

  test('you can delete po with issued state and check totalQuantityOfAllItemVariation', () async {
    final lineItems = getLineItems(items: [Tuple2(5, shirtItem), Tuple2(10, jeanItem)]);

    final po = PurchaseOrder.create(
        purchaseOrderNumber: "PO-0001",
        accountId: billAccount.id!,
        date: DateTime.now(),
        currencyCode: CurrencyCode.AUD,
        lineItems: lineItems,
        subTotal: 10,
        total: 20);
    final poCreatedOrError =
        await purchaseOrderApi.setToIssued(purchaseOrder: po, teamId: team.id!, token: firstUserAccessToken);

    expect(poCreatedOrError.isRight(), true);
    final createdPo = poCreatedOrError.toIterable().first;

    {
      final deletedOrError = await purchaseOrderApi.delete(
        purchaseOrderId: createdPo.id!,
        teamId: team.id!,
        token: firstUserAccessToken,
      );
      expect(deletedOrError.isRight(), true);
    }

    {
      final iuOrError = await itemApi.getItemUtilization(teamId: team.id!, token: firstUserAccessToken);
      expect(iuOrError.isRight(), true);
      expect(iuOrError.toIterable().first.totalQuantityOfAllItemVariation, 0);
    }
  });

  test('you can delete po with received state and check totalQuantityOfAllItemVariation', () async {
    final lineItems = getLineItems(items: [Tuple2(5, shirtItem), Tuple2(10, jeanItem)]);
    final po = PurchaseOrder.create(
        purchaseOrderNumber: "PO-0001",
        accountId: billAccount.id!,
        date: DateTime.now(),
        currencyCode: CurrencyCode.AUD,
        lineItems: lineItems,
        subTotal: 10,
        total: 20);
    final poCreatedOrError =
        await purchaseOrderApi.setToIssued(purchaseOrder: po, teamId: team.id!, token: firstUserAccessToken);

    expect(poCreatedOrError.isRight(), true);
    final createdPo = poCreatedOrError.toIterable().first;
    expect(createdPo.status, 'issued');
    final poItemsReceivedOrError = await purchaseOrderApi.setToReceived(
        purchaseOrderId: createdPo.id!, date: DateTime.now(), teamId: team.id!, token: firstUserAccessToken);
    expect(poItemsReceivedOrError.isRight(), true);

    //sleep a while to update correctly
    await Future.delayed(const Duration(seconds: 1));

    {
      final deletedOrError = await purchaseOrderApi.delete(
        purchaseOrderId: createdPo.id!,
        teamId: team.id!,
        token: firstUserAccessToken,
      );
      expect(deletedOrError.isRight(), true);
    }

    //sleep a while to update correctly
    await Future.delayed(const Duration(seconds: 1));
    {
      final iuOrError = await itemApi.getItemUtilization(teamId: team.id!, token: firstUserAccessToken);
      expect(iuOrError.isRight(), true);
      expect(iuOrError.toIterable().first.totalQuantityOfAllItemVariation, 0);
    }
  });

  test('you can delete po with received state', () async {
    final lineItems = getLineItems(items: [Tuple2(5, shirtItem), Tuple2(10, jeanItem)]);
    final po = PurchaseOrder.create(
        purchaseOrderNumber: "PO-0001",
        accountId: billAccount.id!,
        date: DateTime.now(),
        currencyCode: CurrencyCode.AUD,
        lineItems: lineItems,
        subTotal: 10,
        total: 20);
    final poCreatedOrError =
        await purchaseOrderApi.setToIssued(purchaseOrder: po, teamId: team.id!, token: firstUserAccessToken);

    expect(poCreatedOrError.isRight(), true);
    final createdPo = poCreatedOrError.toIterable().first;
    expect(createdPo.status, 'issued');
    final poItemsReceivedOrError = await purchaseOrderApi.setToReceived(
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
