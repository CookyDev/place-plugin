import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:place_plugin/place.dart';
import 'package:place_plugin/place_plugin.dart';
import 'package:place_plugin_example/place_autocomplete_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final PlaceAutocompleteService _autoCompleteService =
      PlaceAutocompleteService();

  @override
  void initState() {
    super.initState();
    // initPlatformState();
    //_autoCompleteService.searchPlace("244");
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await PlacePlugin.platformVersion ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: TextField(
              onChanged: (text) {
                _autoCompleteService.searchPlace(text);
              },
            ),
          ),
          body: StreamBuilder(
              stream: _autoCompleteService.searchStream,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  if (snapshot.data == 'searching_') {
                    return const Center(
                      child: CupertinoActivityIndicator(),
                    );
                  }
                  if (snapshot.data is List<Place>) {
                    final places = snapshot.data as List<Place>;
                    if (places.isNotEmpty) {
                      return ListView.separated(
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return InkWell(
                              onTap: () {
                                PlacePlugin.getPlace(places[index])
                                    .then((value) {
                                  print("value:");
                                  print(value!.name! + value.lat.toString() + " - " + value.lng.toString() + value.city!  + value.district!);
                                });
                              },
                              child: Text(places[index].name ?? ""));
                        },
                        itemCount: places.length,
                        separatorBuilder: (BuildContext context, int index) =>
                            Divider(
                          color: Colors.grey,
                          height: 1,
                        ),
                      );
                    }
                  } else {
                    return Text("not found");
                  }
                } else {
                  return Text("not found");
                }
                return Text("not found");
              })),
    );
  }
}
