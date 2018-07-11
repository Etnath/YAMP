import 'package:dart_message_bus/dart_message_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';

import '../models/constants.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new SplashScreenState();
  }
}

class SplashScreenState extends State<SplashScreen> {
  String _progress = 'Loading';
  double _progressPercent = 0.0;

  SplashScreenState() {
    Injector
        .getInjector()
        .get<MessageBus>()
        .subscribe(MessageNames.musicLoading, onMusicLoaded);
  }

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          new Image.asset('resources/YAMPLogo.png'),
          Container(
            margin: EdgeInsets.fromLTRB(76.0, 8.0, 76.0, 16.0), 
            child: new LinearProgressIndicator(value: _progressPercent,),
          ), 
          new Text(_progress),
        ],
      ),
    );
  }

  void onMusicLoaded(Message message) {
    Map<String, dynamic> data = message.data;
    int total = data["total"];
    int loaded = data["loaded"];

    setState(() {
      _progress = 'Loading (' + loaded.toString() + '/' + total.toString() + ')';
      _progressPercent = (loaded / total);
    });
  }
}
