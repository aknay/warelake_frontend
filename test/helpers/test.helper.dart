import 'dart:math';

import 'package:collection/collection.dart';
import 'package:dartz/dartz.dart';
import 'package:inventory_frontend/domain/item/entities.dart';
import 'package:inventory_frontend/domain/purchase.order/entities.dart';
import 'package:inventory_frontend/domain/stock.transaction/entities.dart';

final random = Random();

String generateRandomEmail() {
  const String domain = 'example.com'; // Change to your desired email domain
  const String characters = 'abcdefghijklmnopqrstuvwxyz0123456789';
  const int length = 10; // Length of the random part of the email

  String randomEmail = '';

  for (int i = 0; i < length; i++) {
    randomEmail += characters[random.nextInt(characters.length)];
  }

  return '$randomEmail@$domain';
}

Item getShirt() {
  final salePriceMoney = PriceMoney(amount: Random().nextInt(1000) + 1000, currency: "SGD");
  final purchasePriceMoney = PriceMoney(amount: Random().nextInt(1000) + 1000, currency: "SGD");

  final whiteShirt = ItemVariation.create(
      name: "White Shirt",
      stockable: true,
      sku: 'sku 123',
      salePriceMoney: salePriceMoney,
      purchasePriceMoney: purchasePriceMoney);

  final blackShirt = ItemVariation.create(
      name: "Black Shirt",
      stockable: true,
      sku: 'sku 234',
      salePriceMoney: salePriceMoney,
      purchasePriceMoney: purchasePriceMoney);

  return Item.create(name: "shirt", variations: [whiteShirt, blackShirt], unit: 'pcs');
}

Item getJean() {
  final salePriceMoney = PriceMoney(amount: Random().nextInt(1000) + 1000, currency: "SGD");
  final purchasePriceMoney = PriceMoney(amount: Random().nextInt(1000) + 1000, currency: "SGD");

  final whiteJean = ItemVariation.create(
      name: "White Jean",
      stockable: true,
      sku: 'sku 123',
      salePriceMoney: salePriceMoney,
      purchasePriceMoney: purchasePriceMoney);

  final blackJean = ItemVariation.create(
      name: "Black Jean",
      stockable: true,
      sku: 'sku 234',
      salePriceMoney: salePriceMoney,
      purchasePriceMoney: purchasePriceMoney);

  return Item.create(name: "jeans", variations: [whiteJean, blackJean], unit: 'pcs');
}

List<LineItem> getLineItemsWithRandomCount({required List<Item> items}) {
  return items
      .map((e) => e.variations.map((e) => LineItem.create(
          itemVariation: e, rate: e.purchasePriceMoney.amountInDouble, quantity: Random().nextInt(5) + 5, unit: 'pcs')))
      .flattened
      .toList();
}

List<LineItem> getLineItems({required List<Tuple2<int, Item>> items}) {
  return items
      .map((f) => f.value2.variations.map((e) => LineItem.create(
          itemVariation: e, rate: e.purchasePriceMoney.amountInDouble, quantity: f.value1, unit: 'pcs')))
      .flattened
      .toList();
}

List<StockLineItem> getStocklLineItemWithRandomCount({required List<Item> createdItemList}) {
  return createdItemList
      .map((e) => e.variations.map((e) => StockLineItem.create(itemVariation: e, quantity: Random().nextInt(5) + 5)))
      .flattened
      .toList();
}

List<StockLineItem> getStockLineItem({required List<Tuple2<int, Item>> items}) {
  return items
      .map((e) => e.value2.variations.map((f) => StockLineItem.create(itemVariation: f, quantity: e.value1)))
      .flattened
      .toList();
}
