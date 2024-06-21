import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:warelake/data/bill.account/bill.account.repository.dart';
import 'package:warelake/data/currency.code/valueobject.dart';
import 'package:warelake/data/item.variation/item.variation.repository.dart';
import 'package:warelake/data/item/item.repository.dart';
import 'package:warelake/data/monthly.order.summary/monthly.order.summary.repository.dart';
import 'package:warelake/data/purchase.order/purchase.order.repository.dart';
import 'package:warelake/data/sale.order/sale.order.repository.dart';
import 'package:warelake/data/team/team.repository.dart';
import 'package:warelake/domain/item.utilization/entities.dart';
import 'package:warelake/domain/item/entities.dart';
import 'package:warelake/domain/purchase.order/entities.dart';
import 'package:warelake/domain/sale.order/entities.dart';
import 'package:warelake/domain/team/entities.dart';

import '../helpers/sign.in.response.dart';
import '../helpers/test.helper.dart';

void main() async {
  final teamApi = TeamRepository();
  final itemApi = ItemRepository();
  final itemVariationRepo = ItemVariationRepository();
  final monthlyOrderSummaryApi = MonthlyOrderSummaryRepository();
  final billAccountApi = BillAccountRepository();
  final purchaseOrderApi = PurchaseOrderRepository();
  final saleOrderApi = SaleOrderRepository();
  late String firstUserAccessToken;

  late String teamId;
  late String billAccountId;
      late Item shirtItem;
  late List<ItemVariation> shirtItemVariations;
  late Item jeanItem;
  late List<ItemVariation> jeanItemVariations;
    

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
    final account = accountListOrError.toIterable().first.data.first;
    billAccountId = account.id!;

    final shirtCreatedOrError =
        await itemApi.createItemRequest(request: getShirtItemRequest(), teamId: teamId, token: firstUserAccessToken);
    shirtItem = shirtCreatedOrError.toIterable().first;

    final shirtVaraitionsOrError =
        await itemVariationRepo.getItemVariations(teamId: teamId, token: firstUserAccessToken, itemId: shirtItem.id!);
    shirtItemVariations = shirtVaraitionsOrError.toIterable().first;

    final jeansCreatedOrError =
        await itemApi.createItemRequest(request: getJeanItemRequest(), teamId: teamId, token: firstUserAccessToken);
    jeanItem = jeansCreatedOrError.toIterable().first;
    final jeanVariationsOrError =
        await itemVariationRepo.getItemVariations(teamId: teamId, token: firstUserAccessToken, itemId: jeanItem.id!);
    jeanItemVariations = jeanVariationsOrError.toIterable().first;
  });

  test('monthly order summary can be retrieved even it has not be created yet', () async {
    final monthlyOrderSummaryOrError = await monthlyOrderSummaryApi.get(teamId: teamId, token: firstUserAccessToken);
    expect(monthlyOrderSummaryOrError.isRight(), true);
  });

  test('monthly order summary count will be increased for PO when a po is added', () async {
    final po = PurchaseOrder.create(
        accountId: billAccountId,
        date: DateTime.now(),
        currencyCode: CurrencyCode.AUD,
        lineItems: getLineItems(items: [Tuple2(5, shirtItemVariations), Tuple2(10, jeanItemVariations)]),
        subTotal: 10,
        purchaseOrderNumber: "PO-0001",
        total: 20);

    final poCreatedOrError =
        await purchaseOrderApi.setToIssued(purchaseOrder: po, teamId: teamId, token: firstUserAccessToken);
    await Future.delayed(const Duration(seconds: 1));
    expect(poCreatedOrError.isRight(), true);
    {
      final monthlyOrderSummaryOrError = await monthlyOrderSummaryApi.get(teamId: teamId, token: firstUserAccessToken);
      expect(monthlyOrderSummaryOrError.isRight(), true);
      final monthlyOrderSummary = monthlyOrderSummaryOrError.toIterable().first;
      expect(monthlyOrderSummary.purchaseOrderCount, 1);

      expect(monthlyOrderSummary.purchaseOrderAmount, 0);
    }
  });

  test('monthly order summary amount will be increased for PO when a po is issued', () async {
    final po = PurchaseOrder.create(
        accountId: billAccountId,
        date: DateTime.now(),
        currencyCode: CurrencyCode.AUD,
        lineItems: getLineItems(items: [Tuple2(5, shirtItemVariations), Tuple2(10, jeanItemVariations)]),
        subTotal: 10,
        purchaseOrderNumber: "PO-0001",
        total: 20);

    final poCreatedOrError =
        await purchaseOrderApi.setToIssued(purchaseOrder: po, teamId: teamId, token: firstUserAccessToken);
    await Future.delayed(const Duration(seconds: 1));
    expect(poCreatedOrError.isRight(), true);

    {
      //set to received
      final now = DateTime.now();
      final po = poCreatedOrError.toIterable().first;

      await purchaseOrderApi.setToReceived(
          purchaseOrderId: po.id!, date: now, teamId: teamId, token: firstUserAccessToken);

      await Future.delayed(const Duration(seconds: 1));

      await purchaseOrderApi.get(purchaseOrderId: po.id!, teamId: teamId, token: firstUserAccessToken);
    }

    final monthlyOrderSummaryOrError = await monthlyOrderSummaryApi.get(teamId: teamId, token: firstUserAccessToken);
    expect(monthlyOrderSummaryOrError.isRight(), true);
    final monthlyOrderSummary = monthlyOrderSummaryOrError.toIterable().first;
    expect(monthlyOrderSummary.purchaseOrderCount, 1);
    final poCreated = poCreatedOrError.toIterable().first;
    final amount = poCreated.lineItems
        .map((e) => e.rate * e.quantity)
        .fold(0.0, (previousValue, element) => previousValue + element);
    expect(monthlyOrderSummary.purchaseOrderAmount, amount / 1000);
  });

  test('monthly order summary will be decrease for PO when a po is deleted', () async {
    final po = PurchaseOrder.create(
        accountId: billAccountId,
        date: DateTime.now(),
        currencyCode: CurrencyCode.AUD,
        lineItems: getLineItems(items: [Tuple2(5, shirtItemVariations), Tuple2(10, jeanItemVariations)]),
        subTotal: 10,
        purchaseOrderNumber: "PO-0001",
        total: 20);

    final poCreatedOrError =
        await purchaseOrderApi.setToIssued(purchaseOrder: po, teamId: teamId, token: firstUserAccessToken);
    await Future.delayed(const Duration(seconds: 1));
    expect(poCreatedOrError.isRight(), true);

    {
      final now = DateTime.now();
      final po = poCreatedOrError.toIterable().first;

      await purchaseOrderApi.setToReceived(
          purchaseOrderId: po.id!, date: now, teamId: teamId, token: firstUserAccessToken);

      await Future.delayed(const Duration(seconds: 1));

      await purchaseOrderApi.get(purchaseOrderId: po.id!, teamId: teamId, token: firstUserAccessToken);
    }
    {
      final monthlyOrderSummaryOrError = await monthlyOrderSummaryApi.get(teamId: teamId, token: firstUserAccessToken);
      expect(monthlyOrderSummaryOrError.isRight(), true);
      final monthlyOrderSummary = monthlyOrderSummaryOrError.toIterable().first;
      expect(monthlyOrderSummary.purchaseOrderCount, 1);
      final poCreated = poCreatedOrError.toIterable().first;
      final amount = poCreated.lineItems
          .map((e) => e.rate * e.quantity)
          .fold(0.0, (previousValue, element) => previousValue + element);
      expect(monthlyOrderSummary.purchaseOrderAmount, amount / 1000);
    }
    {
      final po = poCreatedOrError.toIterable().first;
      await purchaseOrderApi.delete(purchaseOrderId: po.id!, teamId: teamId, token: firstUserAccessToken);
      await Future.delayed(const Duration(seconds: 1));
      final monthlyOrderSummaryOrError = await monthlyOrderSummaryApi.get(teamId: teamId, token: firstUserAccessToken);
      final monthlyOrderSummary = monthlyOrderSummaryOrError.toIterable().first;

      expect(monthlyOrderSummary.purchaseOrderAmount, 0);
      expect(monthlyOrderSummary.purchaseOrderCount, 0);
    }
  });
  test('monthly order summary count will be increased for SO when a So is issued', () async {
    final so = SaleOrder.create(
        accountId: billAccountId,
        date: DateTime.now(),
        currencyCode: CurrencyCode.AUD,
        lineItems: getLineItems(items: [Tuple2(5, shirtItemVariations), Tuple2(10, jeanItemVariations)]),
        subTotal: 10,
        saleOrderNumber: "SO-0001",
        total: 20);

    final soCreatedOrError = await saleOrderApi.create(saleOrder: so, teamId: teamId, token: firstUserAccessToken);
    await Future.delayed(const Duration(seconds: 1));
    expect(soCreatedOrError.isRight(), true);
    final monthlyOrderSummaryOrError = await monthlyOrderSummaryApi.get(teamId: teamId, token: firstUserAccessToken);
    expect(monthlyOrderSummaryOrError.isRight(), true);
    final monthlyOrderSummary = monthlyOrderSummaryOrError.toIterable().first;
    expect(monthlyOrderSummary.saleOrderCount, 1);
    expect(monthlyOrderSummary.saleOrderAmount, 0);
    expect(monthlyOrderSummary.purchaseOrderAmount, 0);
    expect(monthlyOrderSummary.purchaseOrderCount, 0);
  });
  test('monthly order summary amount will be increased for SO when a So is delivered', () async {
    final so = SaleOrder.create(
        accountId: billAccountId,
        date: DateTime.now(),
        currencyCode: CurrencyCode.AUD,
        lineItems: getLineItems(items: [Tuple2(5, shirtItemVariations), Tuple2(10, jeanItemVariations)]),
        subTotal: 10,
        saleOrderNumber: "SO-0001",
        total: 20);

    final soCreatedOrError = await saleOrderApi.create(saleOrder: so, teamId: teamId, token: firstUserAccessToken);
    await Future.delayed(const Duration(seconds: 1));
    expect(soCreatedOrError.isRight(), true);

    {
      final now = DateTime.now();
      final so = soCreatedOrError.toIterable().first;

      await saleOrderApi.setToDelivered(saleOrderId: so.id!, date: now, teamId: teamId, token: firstUserAccessToken);

      await Future.delayed(const Duration(seconds: 1));

      await saleOrderApi.get(saleOrderId: so.id!, teamId: teamId, token: firstUserAccessToken);
    }

    final monthlyOrderSummaryOrError = await monthlyOrderSummaryApi.get(teamId: teamId, token: firstUserAccessToken);
    expect(monthlyOrderSummaryOrError.isRight(), true);
    final monthlyOrderSummary = monthlyOrderSummaryOrError.toIterable().first;
    expect(monthlyOrderSummary.saleOrderCount, 1);
    final poCreated = soCreatedOrError.toIterable().first;
    final amount = poCreated.lineItems
        .map((e) => e.rate * e.quantity)
        .fold(0.0, (previousValue, element) => previousValue + element);
    expect(monthlyOrderSummary.saleOrderAmount, amount / 1000);
    expect(monthlyOrderSummary.purchaseOrderAmount, 0);
    expect(monthlyOrderSummary.purchaseOrderCount, 0);
  });

  test('monthly order summary will be decrease for SO when a so is deleted', () async {
    final so = SaleOrder.create(
        accountId: billAccountId,
        date: DateTime.now(),
        currencyCode: CurrencyCode.AUD,
        lineItems: getLineItems(items: [Tuple2(5, shirtItemVariations), Tuple2(10, jeanItemVariations)]),
        subTotal: 10,
        saleOrderNumber: "PO-0001",
        total: 20);

    final soCreatedOrError = await saleOrderApi.create(saleOrder: so, teamId: teamId, token: firstUserAccessToken);
    await Future.delayed(const Duration(seconds: 1));
    expect(soCreatedOrError.isRight(), true);

    {
      final now = DateTime.now();
      final so = soCreatedOrError.toIterable().first;

      await saleOrderApi.setToDelivered(saleOrderId: so.id!, date: now, teamId: teamId, token: firstUserAccessToken);

      await Future.delayed(const Duration(seconds: 1));

      await saleOrderApi.get(saleOrderId: so.id!, teamId: teamId, token: firstUserAccessToken);
    }
    {
      final monthlyOrderSummaryOrError = await monthlyOrderSummaryApi.get(teamId: teamId, token: firstUserAccessToken);
      expect(monthlyOrderSummaryOrError.isRight(), true);
      final monthlyOrderSummary = monthlyOrderSummaryOrError.toIterable().first;
      expect(monthlyOrderSummary.saleOrderCount, 1);
      final poCreated = soCreatedOrError.toIterable().first;
      final amount = poCreated.lineItems
          .map((e) => e.rate * e.quantity)
          .fold(0.0, (previousValue, element) => previousValue + element);
      expect(monthlyOrderSummary.saleOrderAmount, amount / 1000);
    }
    {
      final so = soCreatedOrError.toIterable().first;
      await saleOrderApi.delete(saleOrderId: so.id!, teamId: teamId, token: firstUserAccessToken);
      await Future.delayed(const Duration(seconds: 1));
      final monthlyOrderSummaryOrError = await monthlyOrderSummaryApi.get(teamId: teamId, token: firstUserAccessToken);
      final monthlyOrderSummary = monthlyOrderSummaryOrError.toIterable().first;

      expect(monthlyOrderSummary.saleOrderAmount, 0);
      expect(monthlyOrderSummary.saleOrderCount, 0);
    }
  });
}
