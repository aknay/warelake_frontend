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
}
