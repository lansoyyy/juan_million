import 'package:juan_million/models/province_model.dart';

class Region {
  final String id;
  final String regionName;
  final List<Province> provinces;

  Region({
    required this.id,
    required this.regionName,
    required this.provinces,
  });

  factory Region.fromJson(Map<String, dynamic> json) {
    var provinceList = json['provinces'] as List;
    List<Province> provinceItems =
        provinceList.map((item) => Province.fromJson(item)).toList();

    return Region(
      id: json['id'],
      regionName: json['regionName'],
      provinces: provinceItems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'regionName': regionName,
      'provinces': provinces.map((province) => province.toJson()).toList(),
    };
  }
}
