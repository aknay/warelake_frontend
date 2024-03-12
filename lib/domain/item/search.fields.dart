class ItemSearchField {
  final String? startingAfterItemId;
  final String? itemName;
  ItemSearchField({
    this.startingAfterItemId,
    this.itemName,
  });
}

class ItemVariationSearchField {
  final String? startingAfterId;
  final String? itemName;
  final String? barcode;
  ItemVariationSearchField({
    this.startingAfterId,
    this.itemName,
    this.barcode,
  });
  Map<String, String> toMap() {
    Map<String, String> additionalQuery = {};

    if (startingAfterId != null) {
      additionalQuery["starting_after"] = startingAfterId!;
    }
    if (itemName != null) {
      additionalQuery["item_name"] = itemName!;
    }

    if (barcode != null) {
      additionalQuery["barcode"] = barcode!;
    }

    return additionalQuery;
  }
}
