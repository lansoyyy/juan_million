import 'package:juan_million/models/municipality_model.dart';

class Province {
  final String id;
  final String name;
  final String regionId;
  final String regionName;
  final List<Municipality> municipalities;

  Province({
    required this.id,
    required this.name,
    required this.regionId,
    required this.regionName,
    required this.municipalities,
  });

  factory Province.fromJson(Map<String, dynamic> json) {
    var municipalitiesList = json['municipalities'] as List;
    List<Municipality> municipalitiesItems =
        municipalitiesList.map((item) => Municipality.fromJson(item)).toList();

    return Province(
      id: json['id'],
      name: json['name'],
      regionId: json['regionId'],
      regionName: json['regionName'],
      municipalities: municipalitiesItems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'regionId': regionId,
      'regionName': regionName,
      'municipalities':
          municipalities.map((municipality) => municipality.toJson()).toList(),
    };
  }
}
