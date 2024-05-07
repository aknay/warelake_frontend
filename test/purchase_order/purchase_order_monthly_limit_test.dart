import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:warelake/data/bill.account/bill.account.repository.dart';
import 'package:warelake/data/currency.code/valueobject.dart';
import 'package:warelake/data/item/item.repository.dart';
import 'package:warelake/data/purchase.order/purchase.order.repository.dart';
import 'package:warelake/data/team/team.repository.dart';
import 'package:warelake/domain/bill.account/entities.dart';
import 'package:warelake/domain/item/entities.dart';
import 'package:warelake/domain/purchase.order/entities.dart';
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

  test(
    'creating po should be successful up to 50 orders but will fail on next order',
    () async {
      for (int i = 0; i < 50; i++) {
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
        await Future.delayed(const Duration(seconds: 1));
        expect(poCreatedOrError.isRight(), true);
      }
      {
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
        expect(poCreatedOrError.isRight(), false);
      }
    },
    timeout: const Timeout(Duration(minutes: 20)),
  );
}
