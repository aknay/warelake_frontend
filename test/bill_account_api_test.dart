import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:warelake/data/bill.account/bill.account.repository.dart';
import 'package:warelake/data/currency.code/valueobject.dart';
import 'package:warelake/data/item/item.repository.dart';
import 'package:warelake/data/purchase.order/purchase.order.repository.dart';
import 'package:warelake/data/team/team.repository.dart';
import 'package:warelake/domain/bill.account/entities.dart';
import 'package:warelake/domain/item/entities.dart';
import 'package:warelake/domain/purchase.order/entities.dart';
import 'package:warelake/domain/team/entities.dart';

import 'helpers/sign.in.response.dart';
import 'helpers/test.helper.dart';

void main() async {
  final teamApi = TeamRepository();
  final billAccountApi = BillAccountRepository();
  final itemApi = ItemRepository();
  final purchaseOrderApi = PurchaseOrderRepository();
  late String firstUserAccessToken;
  late Item shirtItem;
  late Item jeanItem;
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
    final team = createdOrError.toIterable().first;
    teamId = team.id!;
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

  test('populate', () async {
    // Get all time zones available in the timezone package
    tz.initializeTimeZones();
    var locations = tz.timeZoneDatabase.locations;
    log("${locations.length}"); // => 429
    log(locations.keys.first); // => "Africa/Abidjan"
    log(locations.keys.last); //
  });

  test('account is created during team creation successful', () async {
    final newTeam = Team.create(name: 'Power Ranger', timeZone: "Africa/Abidjan", currencyCode: CurrencyCode.AUD);
    final createdOrError = await teamApi.create(team: newTeam, token: firstUserAccessToken);
    expect(createdOrError.isRight(), true);
    final team = createdOrError.toIterable().first;
    expect(team.name, 'Power Ranger');
    expect(team.timeZone, "Africa/Abidjan");
    expect(team.currencyCode, CurrencyCode.AUD);

    {
      //check primary account is created
      final accountListOrError = await billAccountApi.list(teamId: team.id!, token: firstUserAccessToken);
      expect(accountListOrError.isRight(), true);
      expect(accountListOrError.toIterable().first.data.length == 1, true);
      final account = accountListOrError.toIterable().first.data.first;
      expect(account.balance, 0);
    }
  });

  test('you can get list and get the account', () async {
    final newTeam = Team.create(name: 'Power Ranger', timeZone: "Africa/Abidjan", currencyCode: CurrencyCode.AUD);
    final createdOrError = await teamApi.create(team: newTeam, token: firstUserAccessToken);
    expect(createdOrError.isRight(), true);
    final team = createdOrError.toIterable().first;
    {
      final accountListOrError = await billAccountApi.list(teamId: team.id!, token: firstUserAccessToken);
      expect(accountListOrError.isRight(), true);
      expect(accountListOrError.toIterable().first.data.length == 1, true);
      final account = accountListOrError.toIterable().first.data.first;

      //you can get account back
      final accountOrError =
          await billAccountApi.get(billAccountId: account.id!, teamId: team.id!, token: firstUserAccessToken);
      expect(accountOrError.toIterable().first.balance, 0);
    }
  });

  test('bill account will be in negative after po is received', () async {
    final int total;
    {
      final lineItems = getLineItems(items: [Tuple2(5, shirtItem), Tuple2(10, jeanItem)]);
      total = lineItems
          .map((e) => e.itemVariation.purchasePriceMoney.amount * e.quantity)
          .fold(0, (previousValue, element) => previousValue + element);
      final po = PurchaseOrder.create(
          purchaseOrderNumber: "PO-0001",
          accountId: billAccount.id!,
          date: DateTime.now(),
          currencyCode: CurrencyCode.AUD,
          lineItems: lineItems,
          subTotal: total,
          total: total);
      final poCreatedOrError =
          await purchaseOrderApi.setToIssued(purchaseOrder: po, teamId: teamId, token: firstUserAccessToken);
      //sleep a while to update correctly
      await Future.delayed(const Duration(seconds: 1));

      expect(poCreatedOrError.isRight(), true);
      final createdPo = poCreatedOrError.toIterable().first;

      final poItemsReceivedOrError = await purchaseOrderApi.setToReceived(
          purchaseOrderId: createdPo.id!, date: DateTime.now(), teamId: teamId, token: firstUserAccessToken);
      expect(poItemsReceivedOrError.isRight(), true);

      //sleep a while to update correctly
      await Future.delayed(const Duration(seconds: 1));
    }

    {
      //check primary account balance is correct
      final accountListOrError = await billAccountApi.list(teamId: teamId, token: firstUserAccessToken);
      expect(accountListOrError.isRight(), true);
      expect(accountListOrError.toIterable().first.data.length == 1, true);
      final account = accountListOrError.toIterable().first.data.first;
      expect(account.balance, -total / 1000);
    }
  });

  test('bill account will be zeo after received po is deleted', () async {
    final int total;
    {
      final lineItems = getLineItems(items: [Tuple2(5, shirtItem), Tuple2(10, jeanItem)]);
      total = lineItems
          .map((e) => e.itemVariation.purchasePriceMoney.amount * e.quantity)
          .fold(0, (previousValue, element) => previousValue + element);
      final po = PurchaseOrder.create(
          purchaseOrderNumber: "PO-0001",
          accountId: billAccount.id!,
          date: DateTime.now(),
          currencyCode: CurrencyCode.AUD,
          lineItems: lineItems,
          subTotal: total,
          total: total);
      final poCreatedOrError =
          await purchaseOrderApi.setToIssued(purchaseOrder: po, teamId: teamId, token: firstUserAccessToken);
      //sleep a while to update correctly
      await Future.delayed(const Duration(seconds: 1));

      expect(poCreatedOrError.isRight(), true);
      final createdPo = poCreatedOrError.toIterable().first;

      final poItemsReceivedOrError = await purchaseOrderApi.setToReceived(
          purchaseOrderId: createdPo.id!, date: DateTime.now(), teamId: teamId, token: firstUserAccessToken);
      expect(poItemsReceivedOrError.isRight(), true);

      //sleep a while to update correctly
      await Future.delayed(const Duration(seconds: 1));

      final poDeletedOrError =
          await purchaseOrderApi.delete(purchaseOrderId: createdPo.id!, teamId: teamId, token: firstUserAccessToken);
      await Future.delayed(const Duration(seconds: 1));
      expect(poDeletedOrError.isRight(), true);
    }

    {
      //check primary account balance is correct
      final accountListOrError = await billAccountApi.list(teamId: teamId, token: firstUserAccessToken);
      expect(accountListOrError.isRight(), true);
      expect(accountListOrError.toIterable().first.data.length == 1, true);
      final account = accountListOrError.toIterable().first.data.first;
      expect(account.balance, 0);
    }
  });
}
