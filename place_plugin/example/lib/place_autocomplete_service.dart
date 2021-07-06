import 'dart:async';
import 'dart:io';

import 'package:place_plugin/place.dart';
import 'package:place_plugin/place_plugin.dart';

class PlaceAutocompleteService {
  final _controller = StreamController();
  String googlePlaceApiKey = '';
  Strig googlePlaceAndroidApiKey = '';

  PlaceAutocompleteService() {
    PlacePlugin.initialize(
        Platform.isIOS ? googlePlaceApiKey : googlePlaceAndroidApiKey);
  }

  Stream get searchStream => _controller.stream;

  void searchPlace(String keyword) {
    if (keyword.isNotEmpty) {
      _controller.sink.add('searching_');
      PlacePlugin.search(keyword).then((result) {
        print("search success");
        print(result);
        _controller.sink.add(result);
      }).catchError((e) {});
    } else {
      print("search failed");
      _controller.add([]);
    }
  }

  void getPlaceDetail(Place place) {
    if (place.placeId!.isNotEmpty) {
      PlacePlugin.getPlace(place).then((result) {
        _controller.sink.add(result);
      }).catchError((e) {});
    } else {
      _controller.add([]);
    }
  }
}
