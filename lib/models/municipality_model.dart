class Municipality {
  final String id;
  final String name;
  final String provinceName;
  final List<String> barangays;

  Municipality({
    required this.id,
    required this.name,
    required this.provinceName,
    required this.barangays,
  });

  factory Municipality.fromJson(Map<String, dynamic> json) {
    var barangaysList = json['barangays'] as List;
    List<String> barangaysItems =
        barangaysList.map((item) => item as String).toList();

    return Municipality(
      id: json['id'],
      name: json['name'],
      provinceName: json['provinceName'],
      barangays: barangaysItems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'provinceName': provinceName,
      'barangays': barangays,
    };
  }
}
