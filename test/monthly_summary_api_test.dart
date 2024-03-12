import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:warelake/data/bill.account/bill.account.repository.dart';
import 'package:warelake/data/currency.code/valueobject.dart';
import 'package:warelake/data/item/item.repository.dart';
import 'package:warelake/data/monthly.summary/monthly.summary.repository.dart';
import 'package:warelake/data/purchase.order/purchase.order.repository.dart';
import 'package:warelake/data/sale.order/sale.order.repository.dart';
import 'package:warelake/data/team/team.repository.dart';
import 'package:warelake/domain/item/entities.dart';
import 'package:warelake/domain/purchase.order/entities.dart';
import 'package:warelake/domain/sale.order/entities.dart';
import 'package:warelake/domain/team/entities.dart';

import 'helpers/sign.in.response.dart';

void main() async {
  final teamApi = TeamRepository();
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
        await purchaseOrderApi.setToIssued(purchaseOrder: po, teamId: team.id!, token: firstUserAccessToken);

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
    final poItemsReceivedOrError = await purchaseOrderApi.setToReceived(
        date: DateTime.now(), purchaseOrderId: createdPo.id!, teamId: team.id!, token: firstUserAccessToken);
    expect(poItemsReceivedOrError.isRight(), true);
    //sleep a while to update correctly
    await Future.delayed(const Duration(seconds: 1));

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

      final poOrError =
          await purchaseOrderApi.setToIssued(purchaseOrder: po, teamId: team.id!, token: firstUserAccessToken);
      final createdPo = poOrError.toIterable().first;
      await purchaseOrderApi.setToReceived(
          date: DateTime.now(), purchaseOrderId: createdPo.id!, teamId: team.id!, token: firstUserAccessToken);
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

    {
      //create third po
      final now = DateTime.now();
      final po = PurchaseOrder.create(
          purchaseOrderNumber: "PO-0003",
          accountId: account.id!,
          date: now,
          currencyCode: CurrencyCode.AUD,
          lineItems: [lineItem],
          subTotal: 10,
          total: 20);

      final poOrError =
          await purchaseOrderApi.setToIssued(purchaseOrder: po, teamId: team.id!, token: firstUserAccessToken);
      final createdPo = poOrError.toIterable().first;
      await purchaseOrderApi.setToReceived(
          date: DateTime.now(), purchaseOrderId: createdPo.id!, teamId: team.id!, token: firstUserAccessToken);

      DateTime previousMonth = DateTime(now.year, now.month - 1, now.day);

      // Handling edge case for January
      if (now.month == 1) {
        previousMonth = DateTime(now.year - 1, 12, now.day);
      }

      await purchaseOrderApi.setToReceived(
          date: previousMonth, purchaseOrderId: createdPo.id!, teamId: team.id!, token: firstUserAccessToken);

      DateTime firstDayOfMonth = DateTime(previousMonth.year, previousMonth.month, 1);

      // Using intl package to format the date
      String formattedDate = DateFormat('yyyy-MM-dd').format(firstDayOfMonth);

      //sleep a while to update correctly
      await Future.delayed(const Duration(seconds: 1));
      // check outgoing amount is accumulated
      final monthlySummaryListOrError = await monthlySummaryRepository.list(
          teamId: team.id!, billAccountId: account.id!, token: firstUserAccessToken);
      expect(monthlySummaryListOrError.isRight(), true);
      expect(monthlySummaryListOrError.toIterable().first.length, 2);
      final monthlySummaryList = monthlySummaryListOrError.toIterable().first;

      final monthlySummary = monthlySummaryList.where((element) => element.monthYear == formattedDate).first;

      expect(monthlySummary.incomingAmount, 0);
      expect(monthlySummary.outgoingAmount, 12.5);
    }
  });

  test('you can get updated monthly summary after deleting a  po', () async {
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
        await purchaseOrderApi.setToIssued(purchaseOrder: po, teamId: team.id!, token: firstUserAccessToken);
    final firstPo = poCreatedOrError.toIterable().first;
    {
      // test monthly inventory// it should be emtpy as we havent receive the order yet
      final monthlySummaryListOrError = await monthlySummaryRepository.list(
          teamId: team.id!, billAccountId: account.id!, token: firstUserAccessToken);
      expect(monthlySummaryListOrError.isRight(), true);
      expect(monthlySummaryListOrError.toIterable().first.isEmpty, true);
    }

    // // testing receiving items
    final poItemsReceivedOrError = await purchaseOrderApi.setToReceived(
        date: DateTime.now(), purchaseOrderId: firstPo.id!, teamId: team.id!, token: firstUserAccessToken);
    expect(poItemsReceivedOrError.isRight(), true);
    //sleep a while to update correctly
    await Future.delayed(const Duration(seconds: 1));

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
    PurchaseOrder secondPo;
    {
      final lineItem = LineItem.create(itemVariation: retrievedWhiteShirt, rate: 3.5, quantity: 6, unit: 'cm');
      //create second po
      final po = PurchaseOrder.create(
          purchaseOrderNumber: "PO-0002",
          accountId: account.id!,
          date: now,
          currencyCode: CurrencyCode.AUD,
          lineItems: [lineItem],
          subTotal: 10,
          total: 20);

      final poOrError =
          await purchaseOrderApi.setToIssued(purchaseOrder: po, teamId: team.id!, token: firstUserAccessToken);
      secondPo = poOrError.toIterable().first;
      await purchaseOrderApi.setToReceived(
          date: DateTime.now(), purchaseOrderId: secondPo.id!, teamId: team.id!, token: firstUserAccessToken);
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
      expect(monthlySummary.outgoingAmount, 33.5);
    }

    {
      //delete first po
      await purchaseOrderApi.delete(purchaseOrderId: firstPo.id!, teamId: team.id!, token: firstUserAccessToken);
      await Future.delayed(const Duration(seconds: 1));

      // check outgoing amount is reduced
      final monthlySummaryListOrError = await monthlySummaryRepository.list(
          teamId: team.id!, billAccountId: account.id!, token: firstUserAccessToken);
      expect(monthlySummaryListOrError.isRight(), true);
      expect(monthlySummaryListOrError.toIterable().first.length, 1);
      final monthlySummary = monthlySummaryListOrError.toIterable().first.first;
      expect(monthlySummary.incomingAmount, 0);
      expect(monthlySummary.outgoingAmount, 21.0);
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
    final poCreatedOrError = await saleOrderRepo.create(saleOrder: so, teamId: team.id!, token: firstUserAccessToken);

    expect(poCreatedOrError.isRight(), true);
    final createdSo = poCreatedOrError.toIterable().first;
    expect(createdSo.status, 'issued');

    {
      // test monthly inventory// it should be emtpy as we havent receive the order yet
      final monthlySummaryListOrError = await monthlySummaryRepository.list(
          teamId: team.id!, billAccountId: account.id!, token: firstUserAccessToken);
      expect(monthlySummaryListOrError.isRight(), true);
      expect(monthlySummaryListOrError.toIterable().first.isEmpty, true);
    }

    // // testing receiving items

    final soReceivedOrError = await saleOrderRepo.setToDelivered(
        saleOrderId: createdSo.id!, date: DateTime.now(), teamId: team.id!, token: firstUserAccessToken);
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
      final rawSo = SaleOrder.create(
          accountId: account.id!,
          date: DateTime.now(),
          currencyCode: CurrencyCode.AUD,
          lineItems: [lineItem],
          subTotal: 10,
          total: 20,
          saleOrderNumber: "S0-00002");

      final soOrError = await saleOrderRepo.create(saleOrder: rawSo, teamId: team.id!, token: firstUserAccessToken);
      final so = soOrError.toIterable().first;
      await saleOrderRepo.setToDelivered(
        saleOrderId: so.id!,
        date: DateTime.now(),
        teamId: team.id!,
        token: firstUserAccessToken,
      );
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

    {
      final now = DateTime.now();
      DateTime previousMonth = DateTime(now.year, now.month - 1, now.day);

      // Handling edge case for January
      if (now.month == 1) {
        previousMonth = DateTime(now.year - 1, 12, now.day);
      }

      // create third so
      final rawSo = SaleOrder.create(
          accountId: account.id!,
          date: previousMonth,
          currencyCode: CurrencyCode.AUD,
          lineItems: [lineItem],
          subTotal: 10,
          total: 20,
          saleOrderNumber: "S0-00003");

      final soOrError = await saleOrderRepo.create(saleOrder: rawSo, teamId: team.id!, token: firstUserAccessToken);
      final so = soOrError.toIterable().first;
      await saleOrderRepo.setToDelivered(
        saleOrderId: so.id!,
        date: DateTime.now(),
        teamId: team.id!,
        token: firstUserAccessToken,
      );

      DateTime firstDayOfMonth = DateTime(previousMonth.year, previousMonth.month, 1);
      String formattedDate = DateFormat('yyyy-MM-dd').format(firstDayOfMonth);

      //sleep a while to update correctly
      await Future.delayed(const Duration(seconds: 1));
      // test monthly inventory// we should get first monthly summary
      final monthlySummaryListOrError = await monthlySummaryRepository.list(
          teamId: team.id!, billAccountId: account.id!, token: firstUserAccessToken);
      expect(monthlySummaryListOrError.isRight(), true);
      expect(monthlySummaryListOrError.toIterable().first.length, 2);
      final monthlySummary =
          monthlySummaryListOrError.toIterable().first.where((element) => element.monthYear == formattedDate).first;
      expect(monthlySummary.incomingAmount, 13.5);
      expect(monthlySummary.outgoingAmount, 0);
    }
  });

  test('you can get updated monthly summary after deleting a so', () async {
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
    final so = SaleOrder.create(
        saleOrderNumber: "SO-0001",
        accountId: account.id!,
        date: now,
        currencyCode: CurrencyCode.AUD,
        lineItems: [lineItem],
        subTotal: 10,
        total: 20);
    final soCreatedOrError = await saleOrderRepo.create(saleOrder: so, teamId: team.id!, token: firstUserAccessToken);
    await Future.delayed(const Duration(seconds: 1));
    final firstSo = soCreatedOrError.toIterable().first;
    {
      // test monthly inventory// it should be emtpy as we havent receive the order yet
      final monthlySummaryListOrError = await monthlySummaryRepository.list(
          teamId: team.id!, billAccountId: account.id!, token: firstUserAccessToken);
      expect(monthlySummaryListOrError.isRight(), true);
      expect(monthlySummaryListOrError.toIterable().first.isEmpty, true);
    }

    // // testing receiving items
    final poItemsReceivedOrError = await saleOrderRepo.setToDelivered(
        date: DateTime.now(), saleOrderId: firstSo.id!, teamId: team.id!, token: firstUserAccessToken);
    expect(poItemsReceivedOrError.isRight(), true);
    //sleep a while to update correctly
    await Future.delayed(const Duration(seconds: 1));

    {
      // test monthly inventory// we should get first monthly summary
      final monthlySummaryListOrError = await monthlySummaryRepository.list(
          teamId: team.id!, billAccountId: account.id!, token: firstUserAccessToken);
      expect(monthlySummaryListOrError.isRight(), true);
      expect(monthlySummaryListOrError.toIterable().first.isNotEmpty, true);
      final monthlySummary = monthlySummaryListOrError.toIterable().first.first;
      expect(monthlySummary.incomingAmount, 12.5);
      expect(monthlySummary.outgoingAmount, 0);

      DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
      String formattedDate = DateFormat('yyyy-MM-dd').format(firstDayOfMonth);
      expect(monthlySummary.monthYear, formattedDate);
      expect(monthlySummary.incomingAmount, 12.5);
      expect(monthlySummary.outgoingAmount, 0);
    }
    SaleOrder secondPo;
    {
      final lineItem = LineItem.create(itemVariation: retrievedWhiteShirt, rate: 3.5, quantity: 6, unit: 'cm');
      //create second po
      final po = SaleOrder.create(
          saleOrderNumber: "SO-0002",
          accountId: account.id!,
          date: now,
          currencyCode: CurrencyCode.AUD,
          lineItems: [lineItem],
          subTotal: 10,
          total: 20);

      final soOrError = await saleOrderRepo.create(saleOrder: po, teamId: team.id!, token: firstUserAccessToken);
      secondPo = soOrError.toIterable().first;
      await saleOrderRepo.setToDelivered(
          date: DateTime.now(), saleOrderId: secondPo.id!, teamId: team.id!, token: firstUserAccessToken);
    }
    {
      //sleep a while to update correctly
      await Future.delayed(const Duration(seconds: 1));
      // check outgoing amount is accumulated
      final monthlySummaryListOrError = await monthlySummaryRepository.list(
          teamId: team.id!, billAccountId: account.id!, token: firstUserAccessToken);
      expect(monthlySummaryListOrError.isRight(), true);
      expect(monthlySummaryListOrError.toIterable().first.length, 1);
      final monthlySummary = monthlySummaryListOrError.toIterable().first.first;
      expect(monthlySummary.incomingAmount, 33.5);
      expect(monthlySummary.outgoingAmount, 0);
    }

    {
      //delete first po
      await saleOrderRepo.delete(saleOrderId: firstSo.id!, teamId: team.id!, token: firstUserAccessToken);
      await Future.delayed(const Duration(seconds: 1));

      // check outgoing amount is reduced
      final monthlySummaryListOrError = await monthlySummaryRepository.list(
          teamId: team.id!, billAccountId: account.id!, token: firstUserAccessToken);
      expect(monthlySummaryListOrError.isRight(), true);
      expect(monthlySummaryListOrError.toIterable().first.length, 1);
      final monthlySummary = monthlySummaryListOrError.toIterable().first.first;
      expect(monthlySummary.incomingAmount, 21.0);
      expect(monthlySummary.outgoingAmount, 0);
    }
  });
}
