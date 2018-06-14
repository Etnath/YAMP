import 'package:flutter/material.dart';

import '../models/ApplicationModel.dart';
import '../app.dart';

class MusicPlayerView extends StatefulWidget {
  final MusicPlay _playMusic;
  final ApplicationModel _model;

  MusicPlayerView(this._model, this._playMusic);

  @override
  State<StatefulWidget> createState() {
    return MusicPlayerState(_model, this._playMusic);
  }
}

class MusicPlayerState extends State<MusicPlayerView> {
  final MusicPlay _playMusic;
  Icon playIcon;
  ApplicationModel _model;

  MusicPlayerState(this._model, this._playMusic);

  @override
  void initState() {
    super.initState();

    
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
        child: new IconButton(
          icon: getPlayIcon(),
          onPressed: _playMusic,
        ),
      ),
    );
  }

  Icon getPlayIcon()
  {
    if(_model.isPlaying){
      return new Icon(Icons.pause);
    }

    return new Icon(Icons.play_arrow);
  }
}
