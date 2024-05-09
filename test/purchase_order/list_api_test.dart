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
  late List<ItemVariation> shirtItemVariations;
  late Item jeanItem;
  late List<ItemVariation> jeanItemVariations;
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

        final shirtCreatedOrError =
        await itemApi.createItemRequest(request: getShirtItemRequest(), teamId: team.id!, token: firstUserAccessToken);
    shirtItem = shirtCreatedOrError.toIterable().first;

    final shirtVaraitionsOrError =
        await itemApi.getItemVariations(teamId: team.id!, token: firstUserAccessToken, itemId: shirtItem.id!);
    shirtItemVariations = shirtVaraitionsOrError.toIterable().first;

    final jeansCreatedOrError =
        await itemApi.createItemRequest(request: getJeanItemRequest(), teamId: team.id!, token: firstUserAccessToken);
    jeanItem = jeansCreatedOrError.toIterable().first;
    final jeanVariationsOrError =
        await itemApi.getItemVariations(teamId: team.id!, token: firstUserAccessToken, itemId: jeanItem.id!);
    jeanItemVariations = jeanVariationsOrError.toIterable().first;
  });

  test('you can list po', () async {
    final lineItems = getLineItems(items: [Tuple2(5, shirtItemVariations), Tuple2(10, jeanItemVariations)]);

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

  test('you can sort po by date', () async {
    final lineItems = getLineItems(items: [Tuple2(5, shirtItemVariations), Tuple2(10, jeanItemVariations)]);
    {
      final po = PurchaseOrder.create(
        accountId: billAccount.id!,
        date: DateTime(2024, 3, 1),
        currencyCode: CurrencyCode.AUD,
        lineItems: lineItems,
        subTotal: 10,
        total: 20,
        purchaseOrderNumber: "PO-0001",
      );
      final poCreatedOrError =
          await purchaseOrderApi.setToIssued(purchaseOrder: po, teamId: team.id!, token: firstUserAccessToken);

      expect(poCreatedOrError.isRight(), true);
    }

    {
      final po = PurchaseOrder.create(
        accountId: billAccount.id!,
        date: DateTime(2024, 1, 1),
        currencyCode: CurrencyCode.AUD,
        lineItems: lineItems,
        subTotal: 10,
        total: 20,
        purchaseOrderNumber: "PO-0002",
      );
      final poCreatedOrError =
          await purchaseOrderApi.setToIssued(purchaseOrder: po, teamId: team.id!, token: firstUserAccessToken);

      expect(poCreatedOrError.isRight(), true);
    }

    {
      final po = PurchaseOrder.create(
        accountId: billAccount.id!,
        date: DateTime(2024, 2, 1),
        currencyCode: CurrencyCode.AUD,
        lineItems: lineItems,
        subTotal: 10,
        total: 20,
        purchaseOrderNumber: "PO-0003",
      );
      final poCreatedOrError =
          await purchaseOrderApi.setToIssued(purchaseOrder: po, teamId: team.id!, token: firstUserAccessToken);

      expect(poCreatedOrError.isRight(), true);
    }

    {
      final poOrError = await purchaseOrderApi.list(teamId: team.id!, token: firstUserAccessToken);
      expect(poOrError.isRight(), true);
      expect(poOrError.toIterable().first.data.isNotEmpty, true);
      expect(poOrError.toIterable().first.data[0].date, DateTime(2024, 3, 1));
      expect(poOrError.toIterable().first.data[1].date, DateTime(2024, 2, 1));
      expect(poOrError.toIterable().first.data[2].date, DateTime(2024, 1, 1));
    }
  });

  test('you can list po with empty search field', () async {
    final lineItems = getLineItems(items: [Tuple2(5, shirtItemVariations), Tuple2(10, jeanItemVariations)]);

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
    final lineItems = getLineItems(items: [Tuple2(5, shirtItemVariations), Tuple2(10, jeanItemVariations)]);
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
    final lineItems = getLineItems(items: [Tuple2(5, shirtItemVariations), Tuple2(10, jeanItemVariations)]);

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
      expect(DateFormat('yyyy-MM-dd').format(po.date), DateFormat('yyyy-MM-dd').format(now));
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
}
