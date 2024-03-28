import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:warelake/data/bill.account/bill.account.repository.dart';
import 'package:warelake/data/currency.code/valueobject.dart';
import 'package:warelake/data/item/item.repository.dart';
import 'package:warelake/data/sale.order/sale.order.repository.dart';
import 'package:warelake/data/team/team.repository.dart';
import 'package:warelake/domain/bill.account/entities.dart';
import 'package:warelake/domain/item/entities.dart';
import 'package:warelake/domain/sale.order/entities.dart';
import 'package:warelake/domain/sale.order/search.field.dart';
import 'package:warelake/domain/team/entities.dart';

import '../helpers/sign.in.response.dart';
import '../helpers/test.helper.dart';

void main() async {
  final teamApi = TeamRepository();
  final itemApi = ItemRepository();
  final saleOrderApi = SaleOrderRepository();
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

  test('you can list so with empty search field', () async {
    final so = SaleOrder.create(
      accountId: billAccount.id!,
      date: DateTime.now(),
      currencyCode: CurrencyCode.AUD,
      lineItems: getLineItems(items: [Tuple2(5, shirtItem), Tuple2(10, jeanItem)]),
      subTotal: 10,
      total: 20,
      saleOrderNumber: "SO-0001",
    );
    final poCreatedOrError = await saleOrderApi.create(saleOrder: so, teamId: team.id!, token: firstUserAccessToken);

    expect(poCreatedOrError.isRight(), true);

    {
      final searchField = SaleOrderSearchField();
      final poOrError =
          await saleOrderApi.list(teamId: team.id!, token: firstUserAccessToken, searchField: searchField);
      expect(poOrError.isRight(), true);
      expect(poOrError.toIterable().first.data.isNotEmpty, true);
    }
  });

  test('you can sort po by date', () async {
    final lineItems = getLineItems(items: [Tuple2(5, shirtItem), Tuple2(10, jeanItem)]);
    {
      final po = SaleOrder.create(
        accountId: billAccount.id!,
        date: DateTime(2024, 3, 1),
        currencyCode: CurrencyCode.AUD,
        lineItems: lineItems,
        subTotal: 10,
        total: 20,
        saleOrderNumber: "SO-0001",
      );
      final soCreatedOrError = await saleOrderApi.create(saleOrder: po, teamId: team.id!, token: firstUserAccessToken);

      expect(soCreatedOrError.isRight(), true);
    }

    {
      final so = SaleOrder.create(
        accountId: billAccount.id!,
        date: DateTime(2024, 1, 1),
        currencyCode: CurrencyCode.AUD,
        lineItems: lineItems,
        subTotal: 10,
        total: 20,
        saleOrderNumber: "SO-0002",
      );
      final soCreatedOrError = await saleOrderApi.create(saleOrder: so, teamId: team.id!, token: firstUserAccessToken);

      expect(soCreatedOrError.isRight(), true);
    }

    {
      final so = SaleOrder.create(
        accountId: billAccount.id!,
        date: DateTime(2024, 2, 1),
        currencyCode: CurrencyCode.AUD,
        lineItems: lineItems,
        subTotal: 10,
        total: 20,
        saleOrderNumber: "SO-0003",
      );
      final soCreatedOrError = await saleOrderApi.create(saleOrder: so, teamId: team.id!, token: firstUserAccessToken);

      expect(soCreatedOrError.isRight(), true);
    }

    {
      final soOrError = await saleOrderApi.list(teamId: team.id!, token: firstUserAccessToken);
      expect(soOrError.isRight(), true);
      expect(soOrError.toIterable().first.data.length, 3);
      expect(soOrError.toIterable().first.data[0].date, DateTime(2024, 3, 1));
      expect(soOrError.toIterable().first.data[1].date, DateTime(2024, 2, 1));
      expect(soOrError.toIterable().first.data[2].date, DateTime(2024, 1, 1));
    }
  });

  test('you can list po with last created item', () async {
    final lineItems = getLineItems(items: [Tuple2(5, shirtItem), Tuple2(10, jeanItem)]);
    SaleOrder firstPo;
    {
      final so = SaleOrder.create(
          accountId: billAccount.id!,
          date: DateTime.now(),
          currencyCode: CurrencyCode.AUD,
          lineItems: lineItems,
          subTotal: 10,
          total: 20,
          saleOrderNumber: "S0-00001");
      final soCreatedOrError = await saleOrderApi.create(saleOrder: so, teamId: team.id!, token: firstUserAccessToken);
      firstPo = soCreatedOrError.toIterable().first;
      await Future.delayed(const Duration(seconds: 1));
    }
    SaleOrder secondPo;
    {
      final so = SaleOrder.create(
          accountId: billAccount.id!,
          date: DateTime.now(),
          currencyCode: CurrencyCode.AUD,
          lineItems: lineItems,
          subTotal: 10,
          total: 20,
          saleOrderNumber: "S0-00002");
      final poCreatedOrError = await saleOrderApi.create(saleOrder: so, teamId: team.id!, token: firstUserAccessToken);
      secondPo = poCreatedOrError.toIterable().first;
      await Future.delayed(const Duration(seconds: 1));
    }

    {
      // final searchField = PurchaseOrderSearchField();
      final soListOrError = await saleOrderApi.list(teamId: team.id!, token: firstUserAccessToken);
      expect(soListOrError.isRight(), true);
      final soList = soListOrError.toIterable().first;
      expect(soList.data.length, 2);
      expect(soList.data.first.saleOrderNumber, 'S0-00002');
    }
    {
      // we will not see first PO after second PO
      final searchField = SaleOrderSearchField(startingAfterSaleOrderId: secondPo.id!);
      final soListOrError =
          await saleOrderApi.list(teamId: team.id!, token: firstUserAccessToken, searchField: searchField);
      expect(soListOrError.isRight(), true);
      final soList = soListOrError.toIterable().first;
      expect(soList.data.length, 1);
      expect(soList.data.first.saleOrderNumber, 'S0-00001');
    }

    {
      // we will not see any po after first PO
      final searchField = SaleOrderSearchField(startingAfterSaleOrderId: firstPo.id!);
      final soListOrError =
          await saleOrderApi.list(teamId: team.id!, token: firstUserAccessToken, searchField: searchField);
      expect(soListOrError.isRight(), true);
      final soList = soListOrError.toIterable().first;
      expect(soList.data.isEmpty, true);
    }
  });

  test('you can list so with search', () async {
    final so = SaleOrder.create(
      accountId: billAccount.id!,
      date: DateTime.now(),
      currencyCode: CurrencyCode.AUD,
      lineItems: getLineItems(items: [Tuple2(5, shirtItem), Tuple2(10, jeanItem)]),
      subTotal: 10,
      total: 20,
      saleOrderNumber: "SO-0001",
    );
    final soCreatedOrError = await saleOrderApi.create(saleOrder: so, teamId: team.id!, token: firstUserAccessToken);

    expect(soCreatedOrError.isRight(), true);

    {
      // for issued, we have a list with one po
      final searchField = SaleOrderSearchField(status: SaleOrderStatus.issued);
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
      await saleOrderApi.setToDelivered(
          date: now,
          saleOrderId: soCreatedOrError.toIterable().first.id!,
          teamId: team.id!,
          token: firstUserAccessToken);

      await Future.delayed(const Duration(seconds: 1));
    }
    {
      // for issued, we have a empty list
      final searchField = SaleOrderSearchField(status: SaleOrderStatus.issued);
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
