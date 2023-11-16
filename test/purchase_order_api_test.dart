import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:inventory_frontend/data/currency.code/valueobject.dart';
import 'package:inventory_frontend/data/item/rest.api.dart';
import 'package:inventory_frontend/data/purchase.order/rest.api.dart';
import 'package:inventory_frontend/data/team/rest.api.dart';
import 'package:inventory_frontend/domain/item/entities.dart';
import 'package:inventory_frontend/domain/purchase.order/entities.dart';
import 'package:inventory_frontend/domain/team/entities.dart';

import 'helpers/sign.in.response.dart';

void main() async {
  final teamApi = TeamRestApi();
  final itemApi = ItemRestApi();
  final purchaseOrderApi = PurchaseOrderRestApi();
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

  test('creating po should be successful', () async {
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

    final lineItem =
        LineItem.create(itemVariation: retrievedWhiteShirt, purchaseRate: 2, purchaseQuantity: 5, unit: 'cm');

    final po = PurchaseOrder.create(
        date: DateTime.now(), currencyCode: CurrencyCode.AUD, lineItems: [lineItem], subTotal: 10, total: 20);
    final poCreatedOrError =
        await purchaseOrderApi.issuedPurchaseOrder(purchaseOrder: po, teamId: team.id!, token: firstUserAccessToken);

    expect(poCreatedOrError.isRight(), true);
    final createdPo = poCreatedOrError.toIterable().first;
    expect(createdPo.status, 'issued');
  });

  test('you can received item from po', () async {
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

    final lineItem =
        LineItem.create(itemVariation: retrievedWhiteShirt, purchaseRate: 2, purchaseQuantity: 5, unit: 'cm');

    final po = PurchaseOrder.create(
        date: DateTime.now(), currencyCode: CurrencyCode.AUD, lineItems: [lineItem], subTotal: 10, total: 20);
    final poCreatedOrError =
        await purchaseOrderApi.issuedPurchaseOrder(purchaseOrder: po, teamId: team.id!, token: firstUserAccessToken);

    expect(poCreatedOrError.isRight(), true);
    final createdPo = poCreatedOrError.toIterable().first;
    expect(createdPo.status, 'issued');

    // testing receiving items

    final poItemsReceivedOrError =
        await purchaseOrderApi.receivedItems(purchaseOrder: createdPo, teamId: team.id!, token: firstUserAccessToken);
    expect(poItemsReceivedOrError.isRight(), true);
  });
}
