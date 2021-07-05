import 'package:flutter/material.dart';

class Place {
  String? name;
  String? address;
  String? formattedAddress;
  String? placeId;
  double? lat;
  double? lng;
  String? city;
  String? district;
  String? ward;

  Place(
      {this.name,
      this.address,
      this.formattedAddress,
      this.placeId,
      this.lat,
      this.lng,
      this.city,
      this.district,
      this.ward});

  static List<Place> fromNative(List results) {
    return results.map((p) => Place.fromJson(p)).toList();
  }

  factory Place.fromJson(Map<dynamic, dynamic> json) => Place(
        name: json['name'] ?? '',
        address: json['address'] ?? '',
        formattedAddress: json['formattedAddress'] ?? '',
        placeId: json['placeId'] ?? '',
        lat: json['lat'] ?? 0,
        lng: json['lng'] ?? 0,
        city: json['city'] ?? '',
        district: json['district'] ?? '',
        ward: json['ward'] ?? '',
      );
}
