import 'dart:async';

import 'package:flutter/material.dart';
import 'package:audioplayer/audioplayer.dart';

import 'widgets/splashScreen.dart';
import 'widgets/musicItem.dart';
import 'widgets/musicList.dart';
import 'views/musicPlayerView.dart';
import 'models/music.dart';
import 'services/musicLoader.dart';

typedef MusicChanger(Music music);
typedef MusicPlay();

class YampApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return YampAppState();
  }
}

class YampAppState extends State<YampApp> {
  List<Music> musics;
  Music _currentMusic;
  bool _isLoading;
  BuildContext _context;
  bool _needRestartSong;
  AudioPlayer _audioPlayer;
  bool _isPlaying;
  
  @override
  void initState() {
    super.initState();
    _isLoading = true;
    _audioPlayer = new AudioPlayer();
    _isPlaying = false;
    viewDisplayed();
  }

  Future viewDisplayed() async {
    MusicLoader loader = new MusicLoader();
    PermissionState permissionState = await loader.canReadExternalStorage();
    switch (permissionState) {
      case PermissionState.GRANTED:
        loader.loadMusic().then((loadedMusic) {
          musics = loadedMusic;

          setState(() {
            _isLoading = false;
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
        title: new Text('Contacts Permission'),
        content: new SingleChildScrollView(
          child: new ListBody(
            children: <Widget>[
              new Text('We need this permission because ...'),
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
            new MusicPlayerView(_currentMusic, playMusic)
      },
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return new SplashScreen();
    } else {
      List<MusicItem> musicItems = new List<MusicItem>();
      for (var music in musics) {
        musicItems.add(new MusicItem(music, changeMusic));
      }

      return new MusicList(musicItems);
    }
  }

  void changeMusic(Music music) {
    if (_currentMusic == null || _currentMusic.path != music.path) {
      _currentMusic = music;
      _audioPlayer.stop(); //for some reasons the player needs to be stopped before loading a new song     
    }
    else {
      _needRestartSong = false;
    }

    _isPlaying = true;
    _audioPlayer.play(_currentMusic.path); 

    Navigator.pushNamed(_context, "/MusicPlayer");
  }

  void playMusic()
  {
    if(_isPlaying){
      _audioPlayer.pause(); 
      _isPlaying = false;
    }else{
      _audioPlayer.play(_currentMusic.path);
      _isPlaying = true; 
    }
  }
}
