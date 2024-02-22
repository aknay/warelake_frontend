import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:warelake/data/bill.account/bill.account.repository.dart';
import 'package:warelake/data/currency.code/valueobject.dart';
import 'package:warelake/data/item/item.repository.dart';
import 'package:warelake/data/team/team.repository.dart';
import 'package:warelake/domain/item/entities.dart';
import 'package:warelake/domain/item/requests.dart';
import 'package:warelake/domain/team/entities.dart';

import 'helpers/sign.in.response.dart';
import 'helpers/test.helper.dart';

void main() async {
  final teamApi = TeamRepository();
  final itemRepo = ItemRepository();
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

  // we skip this test for now
  test('you can crate image for an item', () async {
    final salePriceMoney = PriceMoney(amount: 10, currency: "SGD");
    final purchasePriceMoney = PriceMoney(amount: 5, currency: "SGD");

    final whiteShrt = ItemVariation.create(
        name: "White shirt",
        stockable: true,
        sku: 'sku 123',
        salePriceMoney: salePriceMoney,
        purchasePriceMoney: purchasePriceMoney);
    final shirt = Item.create(name: "shirt", variations: [whiteShrt], unit: 'kg');

    final itemCreated = await itemRepo.createItem(item: shirt, teamId: teamId, token: firstUserAccessToken);
    expect(itemCreated.isRight(), true);

    final retrievedItemOrError =
        await itemRepo.getItem(itemId: itemCreated.toIterable().first.id!, teamId: teamId, token: firstUserAccessToken);
    expect(retrievedItemOrError.isRight(), true);
    final item = retrievedItemOrError.toIterable().first;

//create image
    {
      String currentDirectory = Directory.current.path;

      // Construct the path to the image file in the same directory as the test file
      final String imagePath = '$currentDirectory/test/gc.png'; // Adjust the image file name

      final request = ItemImageRequest(itemId: item.id!, imagePath: File(imagePath), teamId: teamId);

      final createdImageOrError = await itemRepo.createItemImage(request: request, token: firstUserAccessToken);

      expect(createdImageOrError.isRight(), true);
    }
    {
      //check image url is updated in item
      final retrievedItemOrError = await itemRepo.getItem(
          itemId: itemCreated.toIterable().first.id!, teamId: teamId, token: firstUserAccessToken);
      expect(retrievedItemOrError.isRight(), true);
      final item = retrievedItemOrError.toIterable().first;
      expect(item.imageUrl != null, true);
      expect(item.imageUrl?.contains(teamId), true);
    }
  });
}
