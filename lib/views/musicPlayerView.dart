import 'package:flutter/material.dart';
import 'package:audioplayer/audioplayer.dart';

import '../models/music.dart';
import '../app.dart';

class MusicPlayerView extends StatefulWidget {
  final Music _music;
  final MusicPlay _playMusic;

  MusicPlayerView(this._music, this._playMusic );

  @override
  State<StatefulWidget> createState() {
    return MusicPlayerState(_music, this._playMusic);
  }
}

class MusicPlayerState extends State<MusicPlayerView> {
  bool _isPlaying;
  Music _music;
  final MusicPlay _playMusic;

  MusicPlayerState(this._music, this._playMusic);

  @override
  void initState() {
    super.initState();

    _isPlaying = true;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
        child: new IconButton(
          icon: new Icon(Icons.play_circle_outline),
          onPressed: _playMusic,
        ),
      ),
    );
  }

  void _handlePlay() {
    if (_isPlaying) {
      _isPlaying = false;
    } else {
      _isPlaying = true;
    }
  }
}
