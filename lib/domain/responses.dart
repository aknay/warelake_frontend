class ListResponse<T> {
  List<T> data;
  bool hasMore;

  ListResponse({required this.data, required this.hasMore});

  factory ListResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
    final data = <T>[];
    json['data'].forEach((v) {
      data.add(fromJson(v));
    });

    final hasMore = json['has_more'];

    return ListResponse<T>(data: data, hasMore: hasMore);
  }
}