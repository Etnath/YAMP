import 'package:flutter/material.dart';
import 'package:audioplayer/audioplayer.dart';

import '../models/music.dart';

class MusicPlayerView extends StatefulWidget {
  final Music _music;
  final bool _restartSong;

  MusicPlayerView(this._music, this._restartSong);

  @override
  State<StatefulWidget> createState() {
    return MusicPlayerState(_music, _restartSong);
  }
}

class MusicPlayerState extends State<MusicPlayerView> {
  bool _isPlaying;
  Music _music;
  AudioPlayer _audioPlayer;
  bool _restartSong;

  MusicPlayerState(this._music, this._restartSong);

  @override
  void initState() {
    super.initState();

    if (_audioPlayer == null) {
      _audioPlayer = new AudioPlayer();
    }

    _isPlaying = true;

    if (_restartSong) {
      //Then the user selected a new song, we need to play it    
      _audioPlayer.stop(); //for some reasons the player needs to be stopped before loading a new song
     
    }
     _audioPlayer.play(_music.path);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
        child: new IconButton(
          icon: new Icon(Icons.play_circle_outline),
          onPressed: _handlePlay,
        ),
      ),
    );
  }

  void _handlePlay() {
    if (_isPlaying) {
      _isPlaying = false;
      _audioPlayer.pause();
    } else {
      _isPlaying = true;
      _audioPlayer.play(_music.path);
    }
  }
}
