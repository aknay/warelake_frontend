import 'dart:math';

import 'package:collection/collection.dart';
import 'package:dartz/dartz.dart';
import 'package:warelake/domain/item/entities.dart';
import 'package:warelake/domain/item/requests.dart';
import 'package:warelake/domain/purchase.order/entities.dart';
import 'package:warelake/domain/stock.transaction/entities.dart';

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
  return Item.create(name: "shirt", unit: 'pcs');
}

CreateItemRequest getShirtItemRequest({int? salePriceInInt, int? purchasePrice}) {
  final whiteShirt = getWhiteShirt(salePriceInInt: salePriceInInt, purchasePriceInInt: purchasePrice);
  final blackShirt = getBlackShirt(salePriceInInt: salePriceInInt, purchasePriceInInt: purchasePrice);
  return CreateItemRequest(item: Item.create(name: "shirt", unit: 'pcs'), itemVariations: [whiteShirt, blackShirt]);
}

ItemVariation getWhiteShirt({int? salePriceInInt, int? purchasePriceInInt}) {
  final salePrice = salePriceInInt ?? Random().nextInt(1000) + 1000;
  final purchasePrice = purchasePriceInInt ?? Random().nextInt(1000) + 1000;
  final salePriceMoney = PriceMoney(amount: salePrice, currency: "SGD");
  final purchasePriceMoney = PriceMoney(amount: purchasePrice, currency: "SGD");
  return ItemVariation.create(
      name: "White Shirt",
      stockable: true,
      sku: 'sku 123',
      salePriceMoney: salePriceMoney,
      purchasePriceMoney: purchasePriceMoney);
}

ItemVariation getBlackShirt({int? salePriceInInt, int? purchasePriceInInt}) {
  final salePrice = salePriceInInt ?? Random().nextInt(1000) + 1000;
  final purchasePrice = purchasePriceInInt ?? Random().nextInt(1000) + 1000;
  final salePriceMoney = PriceMoney(amount: salePrice, currency: "SGD");
  final purchasePriceMoney = PriceMoney(amount: purchasePrice, currency: "SGD");
  return ItemVariation.create(
      name: "Black Shirt",
      stockable: true,
      sku: 'sku 123',
      salePriceMoney: salePriceMoney,
      purchasePriceMoney: purchasePriceMoney);
}

Item getJean() {
  return Item.create(name: "jeans", unit: 'pcs');
}

CreateItemRequest getJeanItemRequest({int? salePriceInInt, int? purchasePrice}) {
  final whiteJean = getWhiteJean(salePriceInInt: salePriceInInt, purchasePriceInInt: purchasePrice);
  final blackJean = getBlackJean(salePriceInInt: salePriceInInt, purchasePriceInInt: purchasePrice);
  return CreateItemRequest(item: Item.create(name: "jeans", unit: 'pcs'), itemVariations: [whiteJean, blackJean]);
}

ItemVariation getWhiteJean({int? salePriceInInt, int? purchasePriceInInt}) {
  final salePrice = salePriceInInt ?? Random().nextInt(1000) + 1000;
  final purchasePrice = purchasePriceInInt ?? Random().nextInt(1000) + 1000;
  final salePriceMoney = PriceMoney(amount: salePrice, currency: "SGD");
  final purchasePriceMoney = PriceMoney(amount: purchasePrice, currency: "SGD");
  return ItemVariation.create(
      name: "White Jean",
      stockable: true,
      sku: 'sku 123',
      salePriceMoney: salePriceMoney,
      purchasePriceMoney: purchasePriceMoney);
}

ItemVariation getBlackJean({int? salePriceInInt, int? purchasePriceInInt}) {
  final salePrice = salePriceInInt ?? Random().nextInt(1000) + 1000;
  final purchasePrice = purchasePriceInInt ?? Random().nextInt(1000) + 1000;
  final salePriceMoney = PriceMoney(amount: salePrice, currency: "SGD");
  final purchasePriceMoney = PriceMoney(amount: purchasePrice, currency: "SGD");
  return ItemVariation.create(
      name: "Black Jean",
      stockable: true,
      sku: 'sku 123',
      salePriceMoney: salePriceMoney,
      purchasePriceMoney: purchasePriceMoney);
}

List<LineItem> getLineItemsWithRandomCount({required List<ItemVariation> items}) {
  return items
      .map((e) => LineItem.create(
          itemVariation: e, rate: e.purchasePriceMoney.amountInDouble, quantity: Random().nextInt(5) + 5, unit: 'pcs'))
      .toList();
}

List<LineItem> getLineItems({required List<Tuple2<double, List<ItemVariation>>> items}) {
  return items
      .map((f) => f.value2.map((e) => LineItem.create(
          itemVariation: e, rate: e.purchasePriceMoney.amountInDouble, quantity: f.value1, unit: 'unit')))
      .flattened
      .toList();
}

List<LineItem> getLineItemIndividual({required List<Tuple2<double, ItemVariation>> items}) {
  return items
      .map((e) => LineItem.create(
          itemVariation: e.value2, rate: e.value2.purchasePriceMoney.amountInDouble, quantity: e.value1, unit: 'pcs'))
      .toList();
}

List<StockLineItem> getStocklLineItemWithRandomCount({required List<ItemVariation> createdItemList}) {
  return createdItemList
      .map((e) => StockLineItem.create(itemVariation: e, quantity: Random().nextInt(5) + 5.0))
      .toList();
}

List<StockLineItem> getStockLineItem({required List<Tuple2<double, List<ItemVariation>>> items}) {
  return items
      .map((e) => e.value2.map((f) => StockLineItem.create(itemVariation: f, quantity: e.value1)))
      .flattened
      .toList();
}

List<StockLineItem> getStockLineItemWithIndividual({required List<Tuple2<double, ItemVariation>> items}) {
  return items.map((e) => StockLineItem.create(itemVariation: e.value2, quantity: e.value1)).toList();
}
