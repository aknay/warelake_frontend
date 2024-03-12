import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:warelake/data/bill.account/bill.account.repository.dart';
import 'package:warelake/data/currency.code/valueobject.dart';
import 'package:warelake/data/item/item.repository.dart';
import 'package:warelake/data/purchase.order/purchase.order.repository.dart';
import 'package:warelake/data/sale.order/sale.order.repository.dart';
import 'package:warelake/data/stock.transaction/stock.transaction.repository.dart';
import 'package:warelake/data/team/team.repository.dart';
import 'package:warelake/domain/item/entities.dart';
import 'package:warelake/domain/item/requests.dart';
import 'package:warelake/domain/purchase.order/entities.dart';
import 'package:warelake/domain/sale.order/entities.dart';
import 'package:warelake/domain/stock.transaction/entities.dart';
import 'package:warelake/domain/team/entities.dart';

import '../helpers/sign.in.response.dart';

void main() async {
  final teamApi = TeamRepository();
  final itemApi = ItemRepository();
  final stockTransactionRepo = StockTransactionRepository();
  final billAccountApi = BillAccountRepository();
  final saleOrderApi = SaleOrderRepository();
  final purchaseOrderApi = PurchaseOrderRepository();
  late String firstUserAccessToken;

  setUpAll(() async {
    const email = "wl@warelake.com";
    const password = "Warel@ke";

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

  DateTime randomDateWithinLastSixMonths(int index) {
    final Random random = Random();
    final DateTime now = DateTime.now();
    final int currentMonth = now.month;
    final int currentYear = now.year;

    // Generate a random month within the last six months
    int randomMonth = (index % 6) + currentMonth - 5;

    // If the random month is less than 1, adjust the year
    int year = currentYear;
    if (randomMonth < 1) {
      year -= 1;
      randomMonth += 12;
    }

    // Generate a random day within the generated month
    final int randomDay = random.nextInt(DateTime(year, randomMonth + 1, 0).day) + 1;

    // Construct and return the random DateTime
    return DateTime(year, randomMonth, randomDay);
  }

  DateTime randomDateTimeLast7Days() {
    final Random random = Random();
    final DateTime now = DateTime.now();
    final int randomDays = random.nextInt(7); // Random number of days between 0 and 6
    final DateTime randomDate = now.subtract(Duration(days: randomDays));
    return randomDate;
  }

  StockMovement randomStockMovement() {
    const List<StockMovement> values = StockMovement.values;
    final Random random = Random();
    return values[random.nextInt(values.length)];
  }

  double randomDoubleInRange(double min, double max) {
    Random random = Random();
    // Generate a random value between 0 and (max - min)
    double value = min + random.nextDouble() * (max - min);
    return double.parse((value).toStringAsFixed(2)); // Round to 2 decimal places
  }

  Item getElectronics() {
    final smartphone = ItemVariation.create(
        name: "Smartphone",
        stockable: true,
        sku: 'sku 123',
        salePriceMoney: PriceMoney.from(amount: 1249, currencyCode: CurrencyCode.AUD),
        purchasePriceMoney: PriceMoney.from(amount: 1105, currencyCode: CurrencyCode.AUD));

    final laptop = ItemVariation.create(
        name: "Laptop",
        stockable: true,
        sku: 'sku 123',
        salePriceMoney: PriceMoney.from(amount: 1249, currencyCode: CurrencyCode.AUD),
        purchasePriceMoney: PriceMoney.from(amount: 1105, currencyCode: CurrencyCode.AUD));

    final tablet = ItemVariation.create(
        name: "Tablet",
        stockable: true,
        sku: 'sku 123',
        salePriceMoney: PriceMoney.from(amount: 328, currencyCode: CurrencyCode.AUD),
        purchasePriceMoney: PriceMoney.from(amount: 255, currencyCode: CurrencyCode.AUD));

    final smartwatch = ItemVariation.create(
        name: "Smartwatch",
        stockable: true,
        sku: 'sku 123',
        salePriceMoney: PriceMoney.from(amount: 285, currencyCode: CurrencyCode.AUD),
        purchasePriceMoney: PriceMoney.from(amount: 368, currencyCode: CurrencyCode.AUD));

    final camera = ItemVariation.create(
        name: "camera",
        stockable: true,
        sku: 'sku 123',
        salePriceMoney: PriceMoney.from(amount: 1541, currencyCode: CurrencyCode.AUD),
        purchasePriceMoney: PriceMoney.from(amount: 1480, currencyCode: CurrencyCode.AUD));

    return Item.create(name: "Electronics", variations: [smartphone, laptop, tablet, smartwatch, camera], unit: 'pcs');
  }

  test('tiny populate data', () async {
    final newTeam = Team.create(name: 'Power Ranger', timeZone: "Africa/Abidjan", currencyCode: CurrencyCode.AUD);
    final createdOrError = await teamApi.create(team: newTeam, token: firstUserAccessToken);
    expect(createdOrError.isRight(), true);
    final team = createdOrError.toIterable().first;

    {
      //add electronics items
      final electronics = getElectronics();
      final itemOrError = await itemApi.createItem(item: electronics, teamId: team.id!, token: firstUserAccessToken);
      final item = itemOrError.toIterable().first;

      {
        //insert image
        String currentDirectory = Directory.current.path;
        final String imagePath =
            '$currentDirectory/test/images/electronics/electronics.jpeg'; // Adjust the image file name
        if (File(imagePath).existsSync()) {
          final request = ItemImageRequest(itemId: item.id!, imagePath: File(imagePath), teamId: team.id!);

          final createdImageOrError = await itemApi.createItemImage(request: request, token: firstUserAccessToken);

          expect(createdImageOrError.isRight(), true);
        }
      }
      List<StockLineItem> lineItemList = [];
      for (var variation in item.variations) {
        String currentDirectory = Directory.current.path;
        // Construct the path to the image file in the same directory as the test file
        final imageFileName = '${variation.name.toLowerCase()}.png';
        final String imagePath =
            '$currentDirectory/test/images/electronics/$imageFileName'; // Adjust the image file name
        if (File(imagePath).existsSync()) {
          final request = ItemVariationImageRequest(
              itemId: item.id!, itemVariationId: variation.id!, imagePath: File(imagePath), teamId: team.id!);

          final createdImageOrError =
              await itemApi.upsertItemVariationImage(request: request, token: firstUserAccessToken);

          expect(createdImageOrError.isRight(), true);
        }
        Random random = Random();
        final lineItem = StockLineItem.create(itemVariation: variation, quantity: random.nextInt(100) + 50);
        lineItemList.add(lineItem);
        final rawTx = StockTransaction.create(
          date: randomDateTimeLast7Days(),
          lineItems: lineItemList,
          stockMovement: randomStockMovement(),
        );

        await stockTransactionRepo.create(stockTransaction: rawTx, teamId: team.id!, token: firstUserAccessToken);
      }
    }

    List<String> fruitList = [
      'Apple', 'Banana', 'Orange', 'Grapes', 'Watermelon',
      'Strawberry', 'Mango', 'Pineapple', 'Kiwi', 'Cherry',
      'Peach', 'Plum', 'Pear', 'Apricot', 'Coconut',
      'Blueberry', 'Raspberry', 'Blackberry', 'Avocado', 'Pomegranate'
      // Add more fruit names as needed
    ];

    List<String> fruitAttrs = [
      'Dry',
      'Fresh',
      'Big',
      'Small',
    ];
    Random random = Random();
    List<ItemVariation> retrievedItemVariationList = [];
    for (var fruit in fruitList) {
      List<ItemVariation> itemVariationList = [];
      for (var attr in fruitAttrs) {
        double randomPriceForSale = randomDoubleInRange(5, 7);
        double randomPriceForPurchase = randomDoubleInRange(2, 4);

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
      final itemToBeCreated = Item.create(name: fruit, variations: itemVariationList, unit: 'kg');

      final itemOrError =
          await itemApi.createItem(item: itemToBeCreated, teamId: team.id!, token: firstUserAccessToken);
      final item = itemOrError.toIterable().first;

      {
        //insert images
        String currentDirectory = Directory.current.path;
        // Construct the path to the image file in the same directory as the test file
        final fruitImageFileName = '${fruit.toLowerCase()}.jpeg';
        final String imagePath = '$currentDirectory/test/images/$fruitImageFileName'; // Adjust the image file name
        if (File(imagePath).existsSync()) {
          final request = ItemImageRequest(itemId: item.id!, imagePath: File(imagePath), teamId: team.id!);

          final createdImageOrError = await itemApi.createItemImage(request: request, token: firstUserAccessToken);

          expect(createdImageOrError.isRight(), true);
        }
      }

      retrievedItemVariationList.addAll(item.variations);

      await Future.delayed(const Duration(milliseconds: 1000));
    }

    for (int i = 0; i < 2; i++) {
      List<StockLineItem> lineItemList = [];
      getItemVariationList(retrievedItemVariationList, 4).forEach((element) {
        final lineItem = StockLineItem.create(itemVariation: element, quantity: random.nextInt(100) + 50);
        lineItemList.add(lineItem);
      });

      final rawTx = StockTransaction.create(
        date: randomDateTimeLast7Days(),
        lineItems: lineItemList,
        stockMovement: randomStockMovement(),
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
                itemVariation: e, quantity: random.nextInt(8) + 2, rate: e.salePriceMoney.amountInDouble, unit: 'kg'),
          )
          .toList();
      final totalAmount = lineItems.map((e) => e.rate).fold(0, (previousValue, element) => previousValue + element);

      final so = SaleOrder.create(
          accountId: account.id!,
          date: randomDateWithinLastSixMonths(i),
          currencyCode: CurrencyCode.AUD,
          lineItems: lineItems,
          subTotal: totalAmount,
          total: totalAmount,
          saleOrderNumber: "S0-0000$i");
      final soCreatedOrError = await saleOrderApi.create(saleOrder: so, teamId: team.id!, token: firstUserAccessToken);
      await Future.delayed(const Duration(milliseconds: 1000));
      saleOrderIdList.add(soCreatedOrError.toIterable().first.id!);
    }

    {
      //delivered sale order
      saleOrderIdList.shuffle();
      final soIdList = saleOrderIdList.take(random.nextInt(10) + 3);
      for (var element in soIdList) {
        await saleOrderApi.setToDelivered(
            saleOrderId: element, date: DateTime.now(), teamId: team.id!, token: firstUserAccessToken);
        await Future.delayed(const Duration(milliseconds: 1000));
      }
    }

    //add purchase order
    List<String> purchaseOrderIdList = [];
    for (int i = 0; i < 40; i++) {
      final lineItems = getItemVariationList(retrievedItemVariationList, random.nextInt(5) + 1)
          .map(
            (e) => LineItem.create(
                itemVariation: e,
                quantity: random.nextInt(10) + 10,
                rate: e.purchasePriceMoney.amountInDouble,
                unit: 'kg'),
          )
          .toList();
      final totalAmount = lineItems.map((e) => e.rate).fold(0, (previousValue, element) => previousValue + element);
      final po = PurchaseOrder.create(
          accountId: account.id!,
          date: randomDateWithinLastSixMonths(i),
          currencyCode: CurrencyCode.AUD,
          lineItems: lineItems,
          subTotal: totalAmount,
          total: totalAmount,
          purchaseOrderNumber: "P0-0000$i");
      final poCreatedOrError =
          await purchaseOrderApi.setToIssued(purchaseOrder: po, teamId: team.id!, token: firstUserAccessToken);
      purchaseOrderIdList.add(poCreatedOrError.toIterable().first.id!);
      await Future.delayed(const Duration(milliseconds: 1000));
    }
    {
      //delivered sale order
      purchaseOrderIdList.shuffle();
      final poIdList = purchaseOrderIdList.take(random.nextInt(10) + 3);

      for (var element in poIdList) {
        await purchaseOrderApi.setToReceived(
            purchaseOrderId: element, date: DateTime.now(), teamId: team.id!, token: firstUserAccessToken);
        await Future.delayed(const Duration(milliseconds: 1000));
      }
    }
  }, timeout: const Timeout(Duration(minutes: 20)), skip: false);
}
