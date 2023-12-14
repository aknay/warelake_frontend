class PayloadItem {
  String? name;
  PayloadItem({this.name});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }
}
