import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:inventory_frontend/data/bill.account/bill.account.repository.dart';
import 'package:inventory_frontend/data/currency.code/valueobject.dart';
import 'package:inventory_frontend/data/item/item.repository.dart';
import 'package:inventory_frontend/data/monthly.summary/monthly.summary.repository.dart';
import 'package:inventory_frontend/data/purchase.order/purchase.order.repository.dart';
import 'package:inventory_frontend/data/sale.order/sale.order.repository.dart';
import 'package:inventory_frontend/data/team/rest.api.dart';
import 'package:inventory_frontend/domain/item/entities.dart';
import 'package:inventory_frontend/domain/purchase.order/entities.dart';
import 'package:inventory_frontend/domain/sale.order/entities.dart';
import 'package:inventory_frontend/domain/team/entities.dart';

import 'helpers/sign.in.response.dart';

void main() async {
  final teamApi = TeamRestApi();
  final itemApi = ItemRepository();
  final purchaseOrderApi = PurchaseOrderRepository();
  final billAccountApi = BillAccountRepository();
  final monthlySummaryRepository = MonthlySummaryRepository();
  final saleOrderRepo = SaleOrderRepository();
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

  test('you can get monthly summary for po', () async {
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

    final lineItem = LineItem.create(itemVariation: retrievedWhiteShirt, rate: 2.5, quantity: 5, unit: 'cm');

    final accountListOrError = await billAccountApi.list(teamId: team.id!, token: firstUserAccessToken);
    expect(accountListOrError.isRight(), true);
    final account = accountListOrError.toIterable().first.data.first;
    final now = DateTime.now();
    final po = PurchaseOrder.create(
        purchaseOrderNumber: "PO-0001",
        accountId: account.id!,
        date: now,
        currencyCode: CurrencyCode.AUD,
        lineItems: [lineItem],
        subTotal: 10,
        total: 20);
    final poCreatedOrError =
        await purchaseOrderApi.issuedPurchaseOrder(purchaseOrder: po, teamId: team.id!, token: firstUserAccessToken);

    expect(poCreatedOrError.isRight(), true);
    final createdPo = poCreatedOrError.toIterable().first;
    expect(createdPo.status, 'issued');

    {
      // test monthly inventory// it should be emtpy as we havent receive the order yet
      final monthlySummaryListOrError = await monthlySummaryRepository.list(
          teamId: team.id!, billAccountId: account.id!, token: firstUserAccessToken);
      expect(monthlySummaryListOrError.isRight(), true);
      expect(monthlySummaryListOrError.toIterable().first.isEmpty, true);
    }

    // // testing receiving items

    final poItemsReceivedOrError = await purchaseOrderApi.receivedItems(
        purchaseOrderId: createdPo.id!, teamId: team.id!, token: firstUserAccessToken);
    expect(poItemsReceivedOrError.isRight(), true);
    //sleep a while to update correctly
    await Future.delayed(const Duration(seconds: 2));

    {
      // test monthly inventory// we should get first monthly summary
      final monthlySummaryListOrError = await monthlySummaryRepository.list(
          teamId: team.id!, billAccountId: account.id!, token: firstUserAccessToken);
      expect(monthlySummaryListOrError.isRight(), true);
      expect(monthlySummaryListOrError.toIterable().first.isNotEmpty, true);
      final monthlySummary = monthlySummaryListOrError.toIterable().first.first;
      expect(monthlySummary.incomingAmount, 0);

      DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
      String formattedDate = DateFormat('yyyy-MM-dd').format(firstDayOfMonth);
      expect(monthlySummary.monthYear, formattedDate);
      expect(monthlySummary.outgoingAmount, 12.5);
    }
    {
      //create second po
      final po = PurchaseOrder.create(
          purchaseOrderNumber: "PO-0002",
          accountId: account.id!,
          date: now,
          currencyCode: CurrencyCode.AUD,
          lineItems: [lineItem],
          subTotal: 10,
          total: 20);

      await purchaseOrderApi.issuedPurchaseOrder(purchaseOrder: po, teamId: team.id!, token: firstUserAccessToken);
      await purchaseOrderApi.receivedItems(
          purchaseOrderId: createdPo.id!, teamId: team.id!, token: firstUserAccessToken);
    }
    {
      //sleep a while to update correctly
      await Future.delayed(const Duration(seconds: 2));
      // check outgoing amount is accumulated
      final monthlySummaryListOrError = await monthlySummaryRepository.list(
          teamId: team.id!, billAccountId: account.id!, token: firstUserAccessToken);
      expect(monthlySummaryListOrError.isRight(), true);
      expect(monthlySummaryListOrError.toIterable().first.length, 1);
      final monthlySummary = monthlySummaryListOrError.toIterable().first.first;
      expect(monthlySummary.incomingAmount, 0);
      expect(monthlySummary.outgoingAmount, 25.0);
    }
  });

  test('you can get monthly summary for so', () async {
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

    final lineItem = LineItem.create(itemVariation: retrievedWhiteShirt, rate: 2.7, quantity: 5, unit: 'cm');

    final accountListOrError = await billAccountApi.list(teamId: team.id!, token: firstUserAccessToken);
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
    final poCreatedOrError =
        await saleOrderRepo.issuedSaleOrder(saleOrder: so, teamId: team.id!, token: firstUserAccessToken);

    expect(poCreatedOrError.isRight(), true);
    final createdSo = poCreatedOrError.toIterable().first;
    expect(createdSo.status, 'processing');

    {
      // test monthly inventory// it should be emtpy as we havent receive the order yet
      final monthlySummaryListOrError = await monthlySummaryRepository.list(
          teamId: team.id!, billAccountId: account.id!, token: firstUserAccessToken);
      expect(monthlySummaryListOrError.isRight(), true);
      expect(monthlySummaryListOrError.toIterable().first.isEmpty, true);
    }

    // // testing receiving items

    final soReceivedOrError =
        await saleOrderRepo.deliveredItems(saleOrderId: createdSo.id!, teamId: team.id!, token: firstUserAccessToken);
    expect(soReceivedOrError.isRight(), true);
    //sleep a while to update correctly
    await Future.delayed(const Duration(seconds: 2));

    {
      // test monthly inventory// we should get first monthly summary
      final monthlySummaryListOrError = await monthlySummaryRepository.list(
          teamId: team.id!, billAccountId: account.id!, token: firstUserAccessToken);
      expect(monthlySummaryListOrError.isRight(), true);
      expect(monthlySummaryListOrError.toIterable().first.isNotEmpty, true);
      final monthlySummary = monthlySummaryListOrError.toIterable().first.first;
      expect(monthlySummary.incomingAmount, 13.5);
      expect(monthlySummary.outgoingAmount, 0);
    }
    {
      // create second so
      final so = SaleOrder.create(
          accountId: account.id!,
          date: DateTime.now(),
          currencyCode: CurrencyCode.AUD,
          lineItems: [lineItem],
          subTotal: 10,
          total: 20,
          saleOrderNumber: "S0-00002");

      await saleOrderRepo.issuedSaleOrder(saleOrder: so, teamId: team.id!, token: firstUserAccessToken);
      await saleOrderRepo.deliveredItems(saleOrderId: createdSo.id!, teamId: team.id!, token: firstUserAccessToken);
    }

    {
      //sleep a while to update correctly
      await Future.delayed(const Duration(seconds: 2));
      // test monthly inventory// we should get first monthly summary
      final monthlySummaryListOrError = await monthlySummaryRepository.list(
          teamId: team.id!, billAccountId: account.id!, token: firstUserAccessToken);
      expect(monthlySummaryListOrError.isRight(), true);
      expect(monthlySummaryListOrError.toIterable().first.length, 1);
      final monthlySummary = monthlySummaryListOrError.toIterable().first.first;
      expect(monthlySummary.incomingAmount, 27.0);
      expect(monthlySummary.outgoingAmount, 0);
    }
  });
}
