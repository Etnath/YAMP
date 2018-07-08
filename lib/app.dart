import 'dart:async';

import 'package:dart_message_bus/dart_message_bus.dart';
import 'package:flutter/material.dart';

import 'controllers/audioController.dart';
import 'controllers/playlistController.dart';
import 'models/ApplicationModel.dart';
import 'models/Constants.dart';
import 'models/playlist.dart';
import 'models/song.dart';
import 'services/musicLoader.dart';
import 'services/playlistLoader.dart';
import 'widgets/musicItem.dart';
import 'widgets/musicList.dart';
import 'widgets/musicPlayerWidget.dart';
import 'widgets/playlistWidget.dart';
import 'widgets/splashScreen.dart';

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
  PlaylistController _playlistController;
  MessageBus _messageBus;
  Stopwatch _stopwatch;

  @override
  void initState() {
    super.initState();
    _stopwatch = new Stopwatch();
    _model = new ApplicationModel();
    _messageBus = new MessageBus();

    _subscribe();

    _audioController = new AudioController(_model, _messageBus);
    _playlistController = new PlaylistController(_model, _messageBus);

    viewDisplayed();
  }

  Future viewDisplayed() async {
    MusicLoader loader = new MusicLoader();
    PermissionState permissionState = await loader.canReadExternalStorage();
    switch (permissionState) {
      case PermissionState.GRANTED:
        loader.loadMusic().then((loadedMusic) {
          _model.init(loadedMusic);

          PlaylistLoader playlistLoader = new PlaylistLoader();
          playlistLoader.loadPlaylists().then((playlists) {
            _model.playLists = playlists;

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
          accentColor: const Color(0xfFFF6868),
          backgroundColor: const Color(0xff4b4b4b)),
      home: new Scaffold(
        body: new Builder(builder: (BuildContext context) {
          _context = context;
          return _buildBody();
        }),
      ),
      routes: <String, WidgetBuilder>{
        "/MusicPlayer": (BuildContext context) =>
            new MusicPlayerWidget(_model, _audioController, _messageBus)
      },
    );
  }

  Widget _buildBody() {
    if (_model.isLoading) {
      _stopwatch.start();
      return new SplashScreen();
    } else {
      return new WillPopScope(
        onWillPop: onWillPop,
        child: new MusicList(_model, _audioController, _playlistController, _messageBus),
      );
    }
  }

  onPushMusicPlayer(Message m) {
    _model.currentPlaylist = m.data;

    Navigator.of(_context).pushNamed("/MusicPlayer");
  }

  void onModelChanged(Message message) {
    setState(() {
      _model = _model;
    });
  }

  void onPushArtist(Message message) {
    Map<String, dynamic> data = message.data;
    String artist = data["artist"];
    List<Song> songs = data["songs"];

    var musicItems = new List<MusicItem>();
    for (var song in songs) {
      musicItems.add(new MusicItem(
          song, songs, _audioController, _playlistController, _messageBus));
    }

    Navigator.of(_context).push(new MaterialPageRoute(
        builder: (context) => new PlayListWidget(musicItems, artist)));
  }

  void onPushAlbum(Message message) {
    Map<String, dynamic> data = message.data;
    String album = data["album"];
    List<Song> songs = data["songs"];

    var musicItems = new List<MusicItem>();
    for (var song in songs) {
      musicItems.add(new MusicItem(
          song, songs, _audioController, _playlistController, _messageBus));
    }

    Navigator.of(_context).push(new MaterialPageRoute(
        builder: (context) => new PlayListWidget(musicItems, album)));
  }

  void onPushPlaylist(Message message) {
    Playlist playList = message.data;

    var musicItems = new List<MusicItem>();
    for (var song in playList.songs) {
      musicItems.add(new MusicItem(
          song, playList.songs, _audioController, _playlistController, _messageBus));
    }

    Navigator.of(_context).push(new MaterialPageRoute(
        builder: (context) => new PlayListWidget(musicItems, playList.title)));
  }

  //Audio controller is not disposed when the application is destroyed. To refactor by listening to lifecycle events later
  Future<bool> onWillPop() {
    _audioController.dispose();
    return new Future(() => true);
  }

  void _subscribe() {
    _messageBus.subscribe(MessageNames.pushMusicPlayer, onPushMusicPlayer);
    _messageBus.subscribe(MessageNames.modelChanged, onModelChanged);
    _messageBus.subscribe(MessageNames.pushArtist, onPushArtist);
    _messageBus.subscribe(MessageNames.pushAlbum, onPushAlbum);
    _messageBus.subscribe(MessageNames.pushPlaylist, onPushPlaylist);
  }
}
