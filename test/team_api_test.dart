import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:inventory_frontend/data/bill.account/rest.api.dart';
import 'package:inventory_frontend/data/currency.code/valueobject.dart';
import 'package:inventory_frontend/data/role/rest.api.dart';
import 'package:inventory_frontend/data/team/rest.api.dart';
import 'package:inventory_frontend/data/user/rest.api.dart';
import 'package:inventory_frontend/domain/team/entities.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'helpers/sign.in.response.dart';
import 'helpers/test.helper.dart';

void main() async {
  final teamApi = TeamRestApi();
  final roleApi = RoleRestApi();
  final userApi = UserRestApi();
  final billAccountApi = BillAccountRestApi();
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

  test('populate', () async {
    // Get all time zones available in the timezone package
    tz.initializeTimeZones();
    var locations = tz.timeZoneDatabase.locations;
    print(locations.length); // => 429
    print(locations.keys.first); // => "Africa/Abidjan"
    print(locations.keys.last); //
  });

  test('creating team should be succeful', () async {
    final newTeam = Team.create(name: 'Power Ranger', timeZone: "Africa/Abidjan", currencyCode: CurrencyCode.AUD);
    final createdOrError = await teamApi.create(team: newTeam, token: firstUserAccessToken);
    expect(createdOrError.isRight(), true);
    final team = createdOrError.toIterable().first;
    expect(team.name, 'Power Ranger');
    expect(team.timeZone, "Africa/Abidjan");
    expect(team.currencyCode, "AUD");

    // admin role will be created when creating a team
    final roleListOrError = await roleApi.getRoleList(teamId: team.id!, token: firstUserAccessToken);
    expect(roleListOrError.isRight(), true);
    expect(roleListOrError.toIterable().first.data.length == 1, true);
    final adminRole = roleListOrError.toIterable().first.data.first;
    expect(adminRole.roleName, 'admin');

    //check admin user is created
    final userListOrError = await userApi.getUserList(team: team, token: firstUserAccessToken);
    expect(userListOrError.isRight(), true);
    expect(userListOrError.toIterable().first.data.length == 1, true);
    final adminUser = userListOrError.toIterable().first.data.first;
    expect(adminUser.isTeamOwner, true);

    {
      //check primary account is created
      final accountListOrError = await billAccountApi.list(teamId: team.id!, token: firstUserAccessToken);
      expect(accountListOrError.isRight(), true);
      expect(accountListOrError.toIterable().first.data.length == 1, true);
      final account = accountListOrError.toIterable().first.data.first;
      expect(account.balance, 0);
    }
  });

  test('getting back team should be successful', () async {
    final newTeam = Team.create(name: 'Power Ranger', timeZone: "Africa/Abidjan", currencyCode: CurrencyCode.AUD);
    final createdOrError = await teamApi.create(team: newTeam, token: firstUserAccessToken);
    final team = createdOrError.toIterable().first;

    final retrievedTeamOrError = await teamApi.get(teamId: team.id!, token: firstUserAccessToken);
    expect(retrievedTeamOrError.isRight(), true);
  });

  test('you can list team', () async {
    final newTeam = Team.create(name: 'Power Ranger', timeZone: "Africa/Abidjan", currencyCode: CurrencyCode.AUD);
    await teamApi.create(team: newTeam, token: firstUserAccessToken);
    final teamListOrError = await teamApi.list(token: firstUserAccessToken);
    expect(teamListOrError.isRight(), true);
    expect(teamListOrError.toIterable().first.data.length, 1);
  });
}
