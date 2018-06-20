import 'dart:async';

import 'package:flutter/material.dart';
import 'package:dart_message_bus/dart_message_bus.dart';

import 'models/ApplicationModel.dart';
import 'widgets/splashScreen.dart';
import 'widgets/musicItem.dart';
import 'widgets/musicList.dart';
import 'views/musicPlayerView.dart';
import 'services/musicLoader.dart';
import 'controllers/AudioController.dart';

class YampApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return YampAppState();
  }
}

class YampAppState extends State<YampApp> {
  BuildContext _context;
  ApplicationModel _model;
  AudioController _audioController;
  MessageBus _messageBus;
  Stopwatch _stopwatch;

  @override
  void initState() {
    super.initState();
    _stopwatch = new Stopwatch();
    _model = new ApplicationModel();
    _messageBus = new MessageBus();
    _messageBus.subscribe("PushRoute", onPushRoute);
    _messageBus.subscribe("ModelChanged", onModelChanged);
    _audioController = new AudioController(_model, _messageBus);
    viewDisplayed();
  }

  Future viewDisplayed() async {
    MusicLoader loader = new MusicLoader();
    PermissionState permissionState = await loader.canReadExternalStorage();
    switch (permissionState) {
      case PermissionState.GRANTED:
        loader.loadMusic().then((loadedMusic) {
          _model.songs = loadedMusic;

          if (_stopwatch.elapsedMilliseconds < 3000) {
            //We wait to let a chance to the splashscreen to be displayed. To be refactored later
            Future.delayed(const Duration(milliseconds: 500)).then((dynamic) {
              setState(() {
                _model.isLoading = false;
              });
            });
          } else {
            setState(() {
              _model.isLoading = false;
            });
          }
          _stopwatch.stop();
        });
        break;
      case PermissionState.DENIED:
        await new Future.delayed(new Duration(seconds: 1));
        showErrorMessage();
        break;
      case PermissionState.SHOW_RATIONALE:
        showPermissionRationale();
        break;
    }
    return null;
  }

  Future showPermissionRationale() {
    return showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      child: new AlertDialog(
        title: new Text('Read storage Permission'),
        content: new SingleChildScrollView(
          child: new ListBody(
            children: <Widget>[
              new Text('YAMP use this permission to access your music.'),
            ],
          ),
        ),
        actions: <Widget>[
          new FlatButton(
            child: new Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
              viewDisplayed();
            },
          ),
        ],
      ),
    );
  }

  void showErrorMessage() {}

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'YAMP',
      theme: new ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.teal,
          primaryColor: const Color(0xff89FFDF), //39FFCA
          accentColor: const Color(0xfFFF4545),
          backgroundColor: const Color(0xff404040)),
      home: new Scaffold(
        body: new Builder(builder: (BuildContext context) {
          _context = context;
          return _buildBody();
        }),
      ),
      routes: <String, WidgetBuilder>{
        "/MusicPlayer": (BuildContext context) =>
            new MusicPlayerView(_model, _audioController)
      },
    );
  }

  Widget _buildBody() {
    if (_model.isLoading) {
      _stopwatch.start();
      return new SplashScreen();
    } else {
      List<MusicItem> musicItems = new List<MusicItem>();
      for (var music in _model.songs) {
        musicItems.add(
            new MusicItem(music, _audioController.changeMusic, _messageBus));
      }

      return new MusicList(musicItems);
    }
  }

  onPushRoute(Message m) {
    if (Navigator.canPop(context)) {
      Navigator.of(_context).popAndPushNamed(m.data.toString());
    } else {
      Navigator.of(_context).pushNamed(m.data.toString());
    }
  }

  void onModelChanged(Message message) {
    setState(() {
      _model = _model;
    });
  }
}
