import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:warelake/data/bill.account/bill.account.repository.dart';
import 'package:warelake/data/currency.code/valueobject.dart';
import 'package:warelake/data/item.variation/item.variation.repository.dart';
import 'package:warelake/data/item/item.repository.dart';
import 'package:warelake/data/team/team.repository.dart';
import 'package:warelake/domain/common/entities.dart';
import 'package:warelake/domain/item.utilization/entities.dart';
import 'package:warelake/domain/item/entities.dart';
import 'package:warelake/domain/item/payloads.dart';
import 'package:warelake/domain/item/requests.dart';
import 'package:warelake/domain/team/entities.dart';

import '../helpers/sign.in.response.dart';
import '../helpers/test.helper.dart';

void main() async {
  final teamApi = TeamRepository();
  final itemRepo = ItemRepository();
  final itemVariationRepo = ItemVariationRepository();
  final billAccountApi = BillAccountRepository();
  late String firstUserAccessToken;
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
  });

  test('you can create item with barcode', () async {
    final salePriceMoney = PriceMoney(amount: Random().nextInt(1000) + 1000, currency: "SGD");
    final purchasePriceMoney = PriceMoney(amount: Random().nextInt(1000) + 1000, currency: "SGD");

    final f = Barcode.ean13();

    // Generate the barcode string (12 digits, excluding the checksum)
    String barcodeData = '123456789012'; // Example barcode data

    // Add the checksum digit to complete the EAN-13 number
    final isValid = f.isValid(barcodeData);
    dev.log('isvalid $isValid');

    // Print the generated EAN-13 number

    final whiteShirt = ItemVariation.create(
        name: "White Shirt",
        stockable: true,
        sku: 'sku 123',
        salePriceMoney: salePriceMoney,
        purchasePriceMoney: purchasePriceMoney,
        barcode: barcodeData);
    final shirt = Item.create(name: "shirt", unit: 'kg');
    final request = CreateItemRequest(item: shirt, itemVariations: [whiteShirt]);
    final itemCreated = await itemRepo.createItemRequest(request: request, teamId: teamId, token: firstUserAccessToken);
    expect(itemCreated.isRight(), true);
    // final item = itemCreated.toIterable().first;
    final itemVarationListOrError = await itemVariationRepo.getItemVariationList(teamId: teamId, token: firstUserAccessToken);
    final itemVariationList = itemVarationListOrError.toIterable().first.data;

    final itemVariationOrError = await itemVariationRepo.getItemVariation(
        itemId: itemVariationList.first.itemId!,
        itemVariationId: itemVariationList.first.id!,
        teamId: teamId,
        token: firstUserAccessToken);

    final itemVariation = itemVariationOrError.toIterable().first;
    expect(itemVariation.barcode, barcodeData);
  });

  test('you can update the barcode of the item variation', () async {
    final salePriceMoney = PriceMoney(amount: 10, currency: "SGD");
    final purchasePriceMoney = PriceMoney(amount: 5, currency: "SGD");

    final whiteShrt = ItemVariation.create(
        name: "White shirt",
        stockable: true,
        sku: 'sku 123',
        salePriceMoney: salePriceMoney,
        purchasePriceMoney: purchasePriceMoney,
        barcode: '1234');
    final shirt = Item.create(name: "shirt", unit: 'kg');
    final request = CreateItemRequest(item: shirt, itemVariations: [whiteShrt]);
    final itemCreatedOrError =
        await itemRepo.createItemRequest(request: request, teamId: teamId, token: firstUserAccessToken);
    expect(itemCreatedOrError.isRight(), true);
    final payload = ItemVariationPayload(barcode: '67890');
    final item = itemCreatedOrError.toIterable().first;

    final itemVarationListOrError = await itemVariationRepo.getItemVariationList(teamId: teamId, token: firstUserAccessToken);
    final itemVariationList = itemVarationListOrError.toIterable().first.data;

    final itemVariationOrError = await itemVariationRepo.getItemVariation(
        itemId: itemVariationList.first.itemId!,
        itemVariationId: itemVariationList.first.id!,
        teamId: teamId,
        token: firstUserAccessToken);

    final itemVariation = itemVariationOrError.toIterable().first;

    final updatedOrError = await itemVariationRepo.updateItemVariation(
        payload: payload,
        itemId: item.id!,
        itemVariationId: itemVariation.id!,
        teamId: teamId,
        token: firstUserAccessToken);

    expect(updatedOrError.isRight(), true);

    {
      //get back the updated item
      final itemVariationOrError = await itemVariationRepo.getItemVariation(
          itemId: itemVariationList.first.itemId!,
          itemVariationId: itemVariationList.first.id!,
          teamId: teamId,
          token: firstUserAccessToken);

      final itemVariation = itemVariationOrError.toIterable().first;
      expect(itemVariation.barcode, "67890");
    }
  });
}
