import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:inventory_frontend/data/bill.account/bill.account.repository.dart';
import 'package:inventory_frontend/data/currency.code/valueobject.dart';
import 'package:inventory_frontend/data/item/item.repository.dart';
import 'package:inventory_frontend/data/purchase.order/purchase.order.repository.dart';
import 'package:inventory_frontend/data/sale.order/sale.order.repository.dart';
import 'package:inventory_frontend/data/stock.transaction/stock.transaction.repository.dart';
import 'package:inventory_frontend/data/team/rest.api.dart';
import 'package:inventory_frontend/domain/item/entities.dart';
import 'package:inventory_frontend/domain/purchase.order/entities.dart';
import 'package:inventory_frontend/domain/sale.order/entities.dart';
import 'package:inventory_frontend/domain/stock.transaction/entities.dart';
import 'package:inventory_frontend/domain/team/entities.dart';

import 'helpers/sign.in.response.dart';

void main() async {
  final teamApi = TeamRestApi();
  final itemApi = ItemRepository();
  final stockTransactionRepo = StockTransactionRepository();
  final billAccountApi = BillAccountRepository();
  final saleOrderApi = SaleOrderRepository();
  final purchaseOrderApi = PurchaseOrderRepository();
  late String firstUserAccessToken;

  setUpAll(() async {
    const email = "abc@someemail.com";
    const password = "M1ndSp@rk";

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

  List<ItemVariation> getItemVariationList(List<ItemVariation> objectList, int numberOfObjects) {
    Random random = Random();
    List<ItemVariation> result = [];

    for (int i = 0; i < numberOfObjects; i++) {
      int randomIndex = random.nextInt(objectList.length);
      result.add(objectList[randomIndex]);
    }

    return result;
  }

  test('populate data', () async {
    final newTeam = Team.create(name: 'Power Ranger', timeZone: "Africa/Abidjan", currencyCode: CurrencyCode.AUD);
    final createdOrError = await teamApi.create(team: newTeam, token: firstUserAccessToken);
    expect(createdOrError.isRight(), true);
    final team = createdOrError.toIterable().first;

    List<String> fruitList = [
      'Apple', 'Banana', 'Orange', 'Grapes', 'Watermelon',
      'Strawberry', 'Mango', 'Pineapple', 'Kiwi', 'Cherry',
      'Peach', 'Plum', 'Pear', 'Apricot', 'Coconut',
      'Blueberry', 'Raspberry', 'Blackberry', 'Avocado', 'Pomegranate'
      // Add more fruit names as needed
    ];

    List<String> fruitAttrs = [
      'Dry',
      'Green',
      'Fresh',
      'Big',
      'Small',
      'Expensive',
      'Cheap',
      'Exotic',
      'Light',
      'Heavy',
      'Air Flown'
    ];
    Random random = Random();
    List<ItemVariation> retrievedItemVariationList = [];
    for (var fruit in fruitList) {
      List<ItemVariation> itemVariationList = [];
      for (var attr in fruitAttrs) {
        double min = 5.0; // Minimum value (inclusive)
        double max = 10.0; // Maximum value (exclusive)

        double randomPriceForSale = min + random.nextDouble() * (max - min);
        double randomPriceForPurchase = min + random.nextDouble() * (max - min);

        final salePriceMoney = PriceMoney.from(amount: randomPriceForSale, currencyCode: CurrencyCode.AUD);
        final purchasePriceMoney = PriceMoney.from(amount: randomPriceForPurchase, currencyCode: CurrencyCode.AUD);

        final whiteShrt = ItemVariation.create(
            name: "$attr $fruit",
            stockable: true,
            sku: 'sku 123',
            salePriceMoney: salePriceMoney,
            purchasePriceMoney: purchasePriceMoney);
        itemVariationList.add(whiteShrt);
      }
      final shirt = Item.create(name: fruit, variations: itemVariationList, unit: 'kg');

      final itemOrError = await itemApi.createItem(item: shirt, teamId: team.id!, token: firstUserAccessToken);
      final item = itemOrError.toIterable().first;
      retrievedItemVariationList.addAll(item.variations);

      await Future.delayed(const Duration(milliseconds: 1000));
    }

    for (int i = 0; i < 10; i++) {
      List<StockLineItem> lineItemList = [];
      getItemVariationList(retrievedItemVariationList, 4).forEach((element) {
        final lineItem = StockLineItem.create(itemVariation: element, quantity: random.nextInt(100) + 50);
        lineItemList.add(lineItem);
      });

      final rawTx = StockTransaction.create(
        date: DateTime.now(),
        lineItems: lineItemList,
        stockMovement: StockMovement.stockIn,
      );

      await stockTransactionRepo.create(stockTransaction: rawTx, teamId: team.id!, token: firstUserAccessToken);
      await Future.delayed(const Duration(milliseconds: 1000));
    }

    for (int i = 0; i < 10; i++) {
      List<StockLineItem> lineItemList = [];
      getItemVariationList(retrievedItemVariationList, 4).forEach((element) {
        final lineItem = StockLineItem.create(itemVariation: element, quantity: random.nextInt(100) + 50);
        lineItemList.add(lineItem);
      });

      final rawTx = StockTransaction.create(
        date: DateTime.now(),
        lineItems: lineItemList,
        stockMovement: StockMovement.stockAdjust,
      );
      final stCreatedOrError =
          await stockTransactionRepo.create(stockTransaction: rawTx, teamId: team.id!, token: firstUserAccessToken);
      expect(stCreatedOrError.isRight(), true);
      await Future.delayed(const Duration(milliseconds: 1000));
    }

    for (int i = 0; i < 10; i++) {
      List<StockLineItem> lineItemList = [];
      getItemVariationList(retrievedItemVariationList, 4).forEach((element) {
        final lineItem = StockLineItem.create(itemVariation: element, quantity: random.nextInt(10) + 2);
        lineItemList.add(lineItem);
      });

      final rawTx = StockTransaction.create(
        date: DateTime.now(),
        lineItems: lineItemList,
        stockMovement: StockMovement.stockOut,
      );
      await stockTransactionRepo.create(stockTransaction: rawTx, teamId: team.id!, token: firstUserAccessToken);
      await Future.delayed(const Duration(milliseconds: 1000));
    }

    //add orders

    final accountListOrError = await billAccountApi.list(teamId: team.id!, token: firstUserAccessToken);
    expect(accountListOrError.isRight(), true);
    expect(accountListOrError.toIterable().first.data.length == 1, true);
    final account = accountListOrError.toIterable().first.data.first;

    //add sale orders
    List<String> saleOrderIdList = [];
    for (int i = 0; i < 30; i++) {
      final lineItems = getItemVariationList(retrievedItemVariationList, random.nextInt(5) + 1)
          .map(
            (e) => LineItem.create(
                itemVariation: e, quantity: random.nextInt(10) + 2, rate: e.salePriceMoney.amountInDouble, unit: 'kg'),
          )
          .toList();

      final so = SaleOrder.create(
          accountId: account.id!,
          date: DateTime.now(),
          currencyCode: CurrencyCode.AUD,
          lineItems: lineItems,
          subTotal: 10,
          total: 20,
          saleOrderNumber: "S0-0000$i");
      final soCreatedOrError = await saleOrderApi.issued(saleOrder: so, teamId: team.id!, token: firstUserAccessToken);
      await Future.delayed(const Duration(milliseconds: 1000));
      saleOrderIdList.add(soCreatedOrError.toIterable().first.id!);
    }

    {
      //delivered sale order
      final soIdList = saleOrderIdList.take(random.nextInt(10) + 3);

      for (var element in soIdList) {
        await saleOrderApi.deliveredItems(
            saleOrderId: element, date: DateTime.now(), teamId: team.id!, token: firstUserAccessToken);
        await Future.delayed(const Duration(milliseconds: 1000));
      }
    }

    //add purchase order
    List<String> purchaseOrderIdList = [];
    for (int i = 0; i < 30; i++) {
      final lineItems = getItemVariationList(retrievedItemVariationList, random.nextInt(5) + 1)
          .map(
            (e) => LineItem.create(
                itemVariation: e, quantity: random.nextInt(10) + 2, rate: e.salePriceMoney.amountInDouble, unit: 'kg'),
          )
          .toList();

      final po = PurchaseOrder.create(
          accountId: account.id!,
          date: DateTime.now(),
          currencyCode: CurrencyCode.AUD,
          lineItems: lineItems,
          subTotal: 10,
          total: 20,
          purchaseOrderNumber: "P0-0000$i");
      final poCreatedOrError =
          await purchaseOrderApi.issuedPurchaseOrder(purchaseOrder: po, teamId: team.id!, token: firstUserAccessToken);
      purchaseOrderIdList.add(poCreatedOrError.toIterable().first.id!);
      await Future.delayed(const Duration(milliseconds: 1000));
    }
    {
      //delivered sale order
      final poIdList = purchaseOrderIdList.take(random.nextInt(10) + 3);

      for (var element in poIdList) {
        await purchaseOrderApi.receivedItems(
            purchaseOrderId: element, date: DateTime.now(), teamId: team.id!, token: firstUserAccessToken);
        await Future.delayed(const Duration(milliseconds: 1000));
      }
    }
  }, timeout: const Timeout(Duration(minutes: 10)));
}
