import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:warelake/data/bill.account/bill.account.repository.dart';
import 'package:warelake/data/currency.code/valueobject.dart';
import 'package:warelake/data/item.variation/item.variation.repository.dart';
import 'package:warelake/data/item/item.repository.dart';
import 'package:warelake/data/team/team.repository.dart';
import 'package:warelake/domain/item.variation/payloads.dart';
import 'package:warelake/domain/team/entities.dart';

import '../../helpers/sign.in.response.dart';
import '../../helpers/test.helper.dart';

void main() async {
  final teamApi = TeamRepository();
  final itemRepo = ItemRepository();
  final itemVariationRepo = ItemVariationRepository();
  final billAccountApi = BillAccountRepository();
  late String firstUserAccessToken;
  late String teamId;

  setUpAll(() async {
    final email = generateRandomEmail();
    final password = generateRandomPassword();

    Map<String, dynamic> signUpData = {};
    signUpData["email"] = email;
    signUpData["password"] = password;

    await http.post(
        Uri.parse(
            "http://localhost:9099/identitytoolkit.googleapis.com/v1/accounts:signUp?key=abcdefg"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(signUpData));

    Map<String, dynamic> data = {};
    data["email"] = email;
    data["password"] = password;
    data["returnSecureToken"] = true;

    final response = await http.post(
        Uri.parse(
            "http://localhost:9099/identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=abcdefg"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data));

    final signInResponse = SignInResponse.fromJson(jsonDecode(response.body));

    firstUserAccessToken = signInResponse.idToken!;
  });

  setUp(() async {
    final newTeam = Team.create(
        name: 'Power Ranger',
        timeZone: "Africa/Abidjan",
        currencyCode: CurrencyCode.AUD);
    final createdOrError =
        await teamApi.create(team: newTeam, token: firstUserAccessToken);
    expect(createdOrError.isRight(), true);
    teamId = createdOrError.toIterable().first.id!;
    final accountListOrError =
        await billAccountApi.list(teamId: teamId, token: firstUserAccessToken);
    expect(accountListOrError.isRight(), true);
  });

  test('creating item with expired date should be successful', () async {
    DateTime today = DateTime.now();
    DateTime twoWeeksLater = today.add(const Duration(days: 14));

    final request = getShirtItemRequest(expiryDate: twoWeeksLater);
    {
      final itemCreated = await itemRepo.createItemRequest(
          request: request, teamId: teamId, token: firstUserAccessToken);
      final item = itemCreated.toIterable().first;
      final shirtVariationsOrError = await itemVariationRepo.getItemVariations(
          itemId: item.id!, teamId: teamId, token: firstUserAccessToken);
      final shirts = shirtVariationsOrError.toIterable().first;
      expect(shirts[0].expiryDate, Some(twoWeeksLater));
    }
  });

  test('updating expired date should be successful', () async {
    DateTime today = DateTime.now();
    DateTime twoWeeksLater = today.add(const Duration(days: 14));

    final request = getShirtItemRequest(expiryDate: twoWeeksLater);

    final itemCreated = await itemRepo.createItemRequest(
        request: request, teamId: teamId, token: firstUserAccessToken);
    final item = itemCreated.toIterable().first;

    final shirtVariationsOrError = await itemVariationRepo.getItemVariations(
        itemId: item.id!, teamId: teamId, token: firstUserAccessToken);
    final shirts = shirtVariationsOrError.toIterable().first;
    final firstShirt = shirts[0];
    expect(firstShirt.expiryDate, Some(twoWeeksLater));

    {
      final updatedOrError = await itemVariationRepo.updateItemVariation(
          payload: ItemVariationPayload(
              expiryDateOrDisable:
                  Some(ExpiryDateOrDisable.updateExpiryDate(today))),
          itemId: item.id!,
          itemVariationId: firstShirt.id!,
          teamId: teamId,
          token: firstUserAccessToken);
      expect(updatedOrError.isRight(), true);
    }
    {
      final shirtVariationsOrError = await itemVariationRepo.getItemVariations(
          itemId: item.id!, teamId: teamId, token: firstUserAccessToken);
      final shirts = shirtVariationsOrError.toIterable().first;
      final firstShirt = shirts[0];
      expect(firstShirt.expiryDate, Some(today));
    }
  });

  test('disabling expired date should be successful', () async {
    DateTime today = DateTime.now();
    DateTime twoWeeksLater = today.add(const Duration(days: 14));

    final request = getShirtItemRequest(expiryDate: twoWeeksLater);

    final itemCreated = await itemRepo.createItemRequest(
        request: request, teamId: teamId, token: firstUserAccessToken);
    final item = itemCreated.toIterable().first;

    final shirtVariationsOrError = await itemVariationRepo.getItemVariations(
        itemId: item.id!, teamId: teamId, token: firstUserAccessToken);
    final shirts = shirtVariationsOrError.toIterable().first;
    final firstShirt = shirts[0];
    expect(firstShirt.expiryDate, Some(twoWeeksLater));

    {
      final updatedOrError = await itemVariationRepo.updateItemVariation(
          payload: ItemVariationPayload(
              expiryDateOrDisable:
                  Some(ExpiryDateOrDisable.disableExpiryDate())),
          itemId: item.id!,
          itemVariationId: firstShirt.id!,
          teamId: teamId,
          token: firstUserAccessToken);
      expect(updatedOrError.isRight(), true);
    }
    {
      final shirtVariationsOrError = await itemVariationRepo.getItemVariations(
          itemId: item.id!, teamId: teamId, token: firstUserAccessToken);
      final shirts = shirtVariationsOrError.toIterable().first;
      final firstShirt = shirts[0];
      expect(firstShirt.expiryDate.isNone(), true);
    }
  });

  test('we can list item variation based on expired date', () async {
    DateTime today = DateTime.now();
    DateTime oneWeeksLater = today.add(const Duration(days: 7));
    DateTime twoWeeksLater = today.add(const Duration(days: 14));
    DateTime threeWeeksLater = today.add(const Duration(days: 21));

    final request = getShirtItemRequest(expiryDate: twoWeeksLater);

    final itemCreated = await itemRepo.createItemRequest(
        request: request, teamId: teamId, token: firstUserAccessToken);
    final item = itemCreated.toIterable().first;

    final shirtVariationsOrError = await itemVariationRepo.getItemVariations(
        itemId: item.id!, teamId: teamId, token: firstUserAccessToken);
    final shirts = shirtVariationsOrError.toIterable().first;
    final firstShirt = shirts[0];
    expect(firstShirt.expiryDate, Some(twoWeeksLater));

    {
      final expiredItemOrError =
          await itemVariationRepo.getExpiringItemVariations(
              teamId: teamId,
              token: firstUserAccessToken,
              expiryDate: threeWeeksLater);

      expect(expiredItemOrError.isRight(), true);
      expect(expiredItemOrError.toIterable().first.data.length, 2);
    }

    {
      final expiredItemOrError =
          await itemVariationRepo.getExpiringItemVariations(
              teamId: teamId,
              token: firstUserAccessToken,
              expiryDate: oneWeeksLater);

      expect(expiredItemOrError.isRight(), true);
      expect(expiredItemOrError.toIterable().first.data.isEmpty, true);
    }
  });

  test('we can paginate item variation based on expired date ', () async {
    DateTime today = DateTime.now();
    DateTime twoWeeksLater = today.add(const Duration(days: 14));
    DateTime threeWeeksLater = today.add(const Duration(days: 21));

    for (var i = 0; i < 6; i++) {
      final request = getShirtItemRequest(
          expiryDate: twoWeeksLater,
          nameList: ['white shirt $i', 'black shirt $i']);
      final itemCreated = await itemRepo.createItemRequest(
          request: request, teamId: teamId, token: firstUserAccessToken);
      expect(itemCreated.isRight(), true);
      await Future.delayed(const Duration(seconds: 1));
    }

    {
      final expiredItemOrError =
          await itemVariationRepo.getExpiringItemVariations(
              teamId: teamId,
              token: firstUserAccessToken,
              expiryDate: threeWeeksLater);

      expect(expiredItemOrError.isRight(), true);
      expect(expiredItemOrError.toIterable().first.data.length, 10);

      final lastItem = expiredItemOrError.toIterable().first.data.last;

      {
        final expiredItemOrError =
            await itemVariationRepo.getExpiringItemVariations(
                teamId: teamId,
                token: firstUserAccessToken,
                expiryDate: threeWeeksLater,
                startingAfterId: Some(lastItem.id!));

        expect(expiredItemOrError.isRight(), true);

        expect(expiredItemOrError.toIterable().first.data.length, 2);
      }
    }
  });
}
