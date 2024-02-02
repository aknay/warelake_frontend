import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:inventory_frontend/data/bill.account/bill.account.repository.dart';
import 'package:inventory_frontend/data/currency.code/valueobject.dart';
import 'package:inventory_frontend/data/item/item.repository.dart';
import 'package:inventory_frontend/data/sale.order/sale.order.repository.dart';
import 'package:inventory_frontend/data/team/team.repository.dart';
import 'package:inventory_frontend/domain/item/entities.dart';
import 'package:inventory_frontend/domain/purchase.order/entities.dart';
import 'package:inventory_frontend/domain/sale.order/entities.dart';
import 'package:inventory_frontend/domain/sale.order/search.field.dart';
import 'package:inventory_frontend/domain/team/entities.dart';

import 'helpers/sign.in.response.dart';
import 'helpers/test.helper.dart';

void main() async {
  final teamApi = TeamRepository();
  final itemApi = ItemRepository();
  final saleOrderApi = SaleOrderRepository();
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
            itemVariation: e, rate: e.salePriceMoney.amountInDouble, quantity: Random().nextInt(1) + 5, unit: "pcs"))
        .toList();

    final jean = getJean();
    final jeanCreated = await itemApi.createItem(item: jean, teamId: teamId, token: firstUserAccessToken);
    expect(jeanCreated.isRight(), true);
    final jeanLineItems = jeanCreated
        .toIterable()
        .first
        .variations
        .map((e) => LineItem.create(
            itemVariation: e, rate: e.salePriceMoney.amountInDouble, quantity: Random().nextInt(1) + 5, unit: "pcs"))
        .toList();
    return shirtLineItems + jeanLineItems;
  }

  test('creating so should be successful', () async {
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

    final lineItem = LineItem.create(itemVariation: retrievedWhiteShirt, rate: 2, quantity: 5, unit: 'cm');

    final accountListOrError = await billAccountApi.list(teamId: team.id!, token: firstUserAccessToken);
    expect(accountListOrError.isRight(), true);
    expect(accountListOrError.toIterable().first.data.length == 1, true);
    final account = accountListOrError.toIterable().first.data.first;

    final po = SaleOrder.create(
        accountId: account.id!,
        date: DateTime.now(),
        currencyCode: CurrencyCode.AUD,
        lineItems: [lineItem],
        subTotal: 10,
        total: 20,
        saleOrderNumber: "S0-00001");
    final poCreatedOrError = await saleOrderApi.issued(saleOrder: po, teamId: team.id!, token: firstUserAccessToken);

    expect(poCreatedOrError.isRight(), true);
    final createdPo = poCreatedOrError.toIterable().first;
    expect(createdPo.status, 'processing');
    expect(createdPo.lineItems.first.quantity, 5);
    expect(createdPo.lineItems.first.rateInDouble, 2);
    expect(createdPo.saleOrderNumber, "S0-00001");

    {
      final saleOrderListOrError = await saleOrderApi.list(teamId: team.id!, token: firstUserAccessToken);

      expect(saleOrderListOrError.toIterable().first.data.isNotEmpty, true);
    }
  });

  test('you can get back so', () async {
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

    final lineItem = LineItem.create(itemVariation: retrievedWhiteShirt, rate: 2, quantity: 5, unit: 'cm');

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
    final soCreatedOrError = await saleOrderApi.issued(saleOrder: so, teamId: team.id!, token: firstUserAccessToken);

    expect(soCreatedOrError.isRight(), true);

    {
      final createdSo = soCreatedOrError.toIterable().first;

      final soOrError =
          await saleOrderApi.get(saleOrderId: createdSo.id!, teamId: team.id!, token: firstUserAccessToken);
      expect(soOrError.isRight(), true);
    }
  });

  test('you can change to delivered for so', () async {
    final newTeam = Team.create(name: 'Power Ranger', timeZone: "Africa/Abidjan", currencyCode: CurrencyCode.AUD);
    final createdOrError = await teamApi.create(team: newTeam, token: firstUserAccessToken);
    expect(createdOrError.isRight(), true);
    final team = createdOrError.toIterable().first;

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

    final itemCreated = await itemApi.createItem(item: shirt, teamId: team.id!, token: firstUserAccessToken);
    expect(itemCreated.isRight(), true);

    final shirt1 = itemCreated.toIterable().first.variations[0];
    final shirt2 = itemCreated.toIterable().first.variations[1];

    final lineItem1 = LineItem.create(itemVariation: shirt1, rate: 3.5, quantity: 5, unit: 'cm');
    final lineItem2 = LineItem.create(itemVariation: shirt2, rate: 2.7, quantity: 4, unit: 'cm');

    // final lineItem = LineItem.create(itemVariation: retrievedWhiteShirt, rate: 2.7, quantity: 5, unit: 'cm');

    final accountListOrError = await billAccountApi.list(teamId: team.id!, token: firstUserAccessToken);
    expect(accountListOrError.isRight(), true);
    expect(accountListOrError.toIterable().first.data.length == 1, true);
    final account = accountListOrError.toIterable().first.data.first;

    final date = DateTime.now();

    final po = SaleOrder.create(
        accountId: account.id!,
        date: date,
        currencyCode: CurrencyCode.AUD,
        lineItems: [lineItem1, lineItem2],
        subTotal: 10,
        total: 20,
        saleOrderNumber: "S0-00001");
    final poCreatedOrError = await saleOrderApi.issued(saleOrder: po, teamId: team.id!, token: firstUserAccessToken);

    expect(poCreatedOrError.isRight(), true);
    final createdSo = poCreatedOrError.toIterable().first;
    expect(createdSo.status, 'processing');

    // testing receiving items

    final poItemsReceivedOrError = await saleOrderApi.deliveredItems(
        saleOrderId: createdSo.id!, date: date, teamId: team.id!, token: firstUserAccessToken);
    expect(poItemsReceivedOrError.isRight(), true);
    //sleep a while to update correctly
    await Future.delayed(const Duration(seconds: 2));

    {
      //test delivered date
      final soOrError = await saleOrderApi.get(
        saleOrderId: createdSo.id!,
        teamId: team.id!,
        token: firstUserAccessToken,
      );
      final so = soOrError.toIterable().first;
      expect(so.deliveredAt, DateFormat('yyyy-MM-dd').format(date));
    }

    {
      //test item increased after received
      final retrievedItemOrError = await itemApi.getItem(
          itemId: itemCreated.toIterable().first.id!, teamId: team.id!, token: firstUserAccessToken);
      final item = retrievedItemOrError.toIterable().first;
      expect(item.variations[0].itemCount, -5);
      expect(item.variations[1].itemCount, -4);
    }

    {
      //check primary account is increased
      final accountListOrError = await billAccountApi.list(teamId: team.id!, token: firstUserAccessToken);
      expect(accountListOrError.isRight(), true);
      expect(accountListOrError.toIterable().first.data.length == 1, true);
      final account = accountListOrError.toIterable().first.data.first;
      expect(account.balance, 28.3);
    }
  });

  test('you can delete the so with processig status', () async {
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

    final lineItem = LineItem.create(itemVariation: retrievedWhiteShirt, rate: 2, quantity: 5, unit: 'cm');

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
    final soCreatedOrError = await saleOrderApi.issued(saleOrder: so, teamId: team.id!, token: firstUserAccessToken);

    expect(soCreatedOrError.isRight(), true);

    {
      final createdSo = soCreatedOrError.toIterable().first;

      final deletedOrError =
          await saleOrderApi.delete(saleOrderId: createdSo.id!, teamId: team.id!, token: firstUserAccessToken);
      expect(deletedOrError.isRight(), true);
    }

    {
      final createdSo = soCreatedOrError.toIterable().first;

      final soOrError =
          await saleOrderApi.get(saleOrderId: createdSo.id!, teamId: team.id!, token: firstUserAccessToken);
      expect(soOrError.isRight(), false);
    }
  });

  test('you can delete the so with delivered status', () async {
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

    final lineItem = LineItem.create(itemVariation: retrievedWhiteShirt, rate: 2, quantity: 5, unit: 'cm');

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
    final soCreatedOrError = await saleOrderApi.issued(saleOrder: so, teamId: team.id!, token: firstUserAccessToken);

    expect(soCreatedOrError.isRight(), true);

    final createdSo = soCreatedOrError.toIterable().first;
    final poItemsReceivedOrError = await saleOrderApi.deliveredItems(
        saleOrderId: createdSo.id!, date: DateTime.now(), teamId: team.id!, token: firstUserAccessToken);
    expect(poItemsReceivedOrError.isRight(), true);
    //sleep a while to update correctly
    await Future.delayed(const Duration(seconds: 2));

    {
      //test item increased after received
      final retrievedItemOrError = await itemApi.getItem(
          itemId: itemCreated.toIterable().first.id!, teamId: team.id!, token: firstUserAccessToken);
      final item = retrievedItemOrError.toIterable().first;
      expect(item.variations.first.itemCount, -5);
    }

    {
      //check primary account is increased
      final accountListOrError = await billAccountApi.list(teamId: team.id!, token: firstUserAccessToken);
      expect(accountListOrError.isRight(), true);
      expect(accountListOrError.toIterable().first.data.length == 1, true);
      final account = accountListOrError.toIterable().first.data.first;
      expect(account.balance, 10);
    }

    {
      final deletedOrError =
          await saleOrderApi.delete(saleOrderId: createdSo.id!, teamId: team.id!, token: firstUserAccessToken);
      expect(deletedOrError.isRight(), true);
    }

    {
      //test item count is back to zero
      final retrievedItemOrError = await itemApi.getItem(
          itemId: itemCreated.toIterable().first.id!, teamId: team.id!, token: firstUserAccessToken);
      final item = retrievedItemOrError.toIterable().first;
      expect(item.variations.first.itemCount, 0);
    }

    {
      //check primary account balance is back to zero
      final accountListOrError = await billAccountApi.list(teamId: team.id!, token: firstUserAccessToken);
      expect(accountListOrError.isRight(), true);
      expect(accountListOrError.toIterable().first.data.length == 1, true);
      final account = accountListOrError.toIterable().first.data.first;
      expect(account.balance, 0);
    }
  });

  test('you can list so with search', () async {
    final newTeam = Team.create(name: 'Power Ranger', timeZone: "Africa/Abidjan", currencyCode: CurrencyCode.AUD);
    final createdOrError = await teamApi.create(team: newTeam, token: firstUserAccessToken);
    expect(createdOrError.isRight(), true);
    final team = createdOrError.toIterable().first;

    final lineItems = await getLineItem(teamId: team.id!);

    final accountListOrError = await billAccountApi.list(teamId: team.id!, token: firstUserAccessToken);
    expect(accountListOrError.isRight(), true);
    final account = accountListOrError.toIterable().first.data.first;

    final so = SaleOrder.create(
      accountId: account.id!,
      date: DateTime.now(),
      currencyCode: CurrencyCode.AUD,
      lineItems: lineItems,
      subTotal: 10,
      total: 20,
      saleOrderNumber: "SO-0001",
    );
    final soCreatedOrError = await saleOrderApi.issued(saleOrder: so, teamId: team.id!, token: firstUserAccessToken);

    expect(soCreatedOrError.isRight(), true);

    {
      // for issued, we have a list with one po
      final searchField = SaleOrderSearchField(status: SaleOrderStatus.processing);
      final soListOrError =
          await saleOrderApi.list(teamId: team.id!, token: firstUserAccessToken, searchField: searchField);
      expect(soListOrError.isRight(), true);
      expect(soListOrError.toIterable().first.data.length, 1);
    }
    {
      // for received, we have a empty list
      final searchField = SaleOrderSearchField(status: SaleOrderStatus.delivered);
      final soListOrError =
          await saleOrderApi.list(teamId: team.id!, token: firstUserAccessToken, searchField: searchField);
      expect(soListOrError.isRight(), true);
      expect(soListOrError.toIterable().first.data.isEmpty, true);
    }

    {
      // receiving items
      final now = DateTime.now();
      await saleOrderApi.deliveredItems(
          date: now,
          saleOrderId: soCreatedOrError.toIterable().first.id!,
          teamId: team.id!,
          token: firstUserAccessToken);

      await Future.delayed(const Duration(seconds: 1));
    }
    {
      // for issued, we have a empty list
      final searchField = SaleOrderSearchField(status: SaleOrderStatus.processing);
      final soListOrError =
          await saleOrderApi.list(teamId: team.id!, token: firstUserAccessToken, searchField: searchField);
      expect(soListOrError.isRight(), true);
      expect(soListOrError.toIterable().first.data.isEmpty, true);
    }
    {
      // for received, we have a list with one po
      final searchField = SaleOrderSearchField(status: SaleOrderStatus.delivered);
      final soListOrError =
          await saleOrderApi.list(teamId: team.id!, token: firstUserAccessToken, searchField: searchField);
      expect(soListOrError.isRight(), true);
      expect(soListOrError.toIterable().first.data.length, 1);
    }
  });
}
