
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:place_plugin/place.dart';

class PlacePlugin {
  static const MethodChannel _channel =
      const MethodChannel('place_plugin');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }


  static void initialize( String apiKey) async {
    await _channel.invokeMethod('initialize',<String,dynamic>{
      'apiKey':apiKey
    });
  }

  static Future<List<Place>> search(String keyword) async{
    final result = await _channel.invokeMethod('search',<String,dynamic>{
      'keyword': keyword
    });
    if(result != null){
      return Place.fromNative(result);
    }
    return [];
  }

  static Future<Place?> getPlace(Place place) async{

    final result = await _channel.invokeMethod('getPlace',<String,dynamic>{
      'placeId': place.placeId,
    });
    if(result != null){
      place.lat = double.parse(result["latitude"].toString());
      place.lng = double.parse(result["longitude"].toString());
      place.formattedAddress = result['formattedAddress'];
      place.city = result['city'];
      place.district = result['district'];
      return place;
    }
    return null;
  }
}
