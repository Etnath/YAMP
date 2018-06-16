import 'package:flutter/material.dart';

import '../models/ApplicationModel.dart';
import '../controllers/AudioController.dart';

class MusicPlayerView extends StatefulWidget {
  final ApplicationModel _model;
  final AudioController _controller;

  MusicPlayerView(this._model, this._controller);

  @override
  State<StatefulWidget> createState() {
    return MusicPlayerState(_model, this._controller);
  }
}

class MusicPlayerState extends State<MusicPlayerView> {
  Icon playIcon;
  ApplicationModel _model;
  AudioController _controller;

  MusicPlayerState(this._model, this._controller);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Column(
        children: <Widget>[
          new Expanded(
            child: new Center(
              child: new Text(_model.currentSong.name),
            ),
          ),
          new Divider(height: 1.0),
          new Container(
            decoration: new BoxDecoration(color: Theme.of(context).cardColor),
            child: new Container(
              margin: new EdgeInsets.all(16.0),
              child: _buildMusicControls(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMusicControls() {
    return new IconTheme(
      data: new IconThemeData(color: Theme.of(context).primaryColor),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          new Container(
            margin: new EdgeInsets.symmetric(horizontal: 4.0),
            child: getShuffleIconButton(),
          ),
          new Container(
            margin: new EdgeInsets.symmetric(horizontal: 4.0),
            child: new IconButton(
              icon: new Icon(Icons.skip_previous),
              onPressed: _controller.playPreviousSong,
            ),
          ),
          new Container(
            margin: new EdgeInsets.symmetric(horizontal: 4.0),
            child: new IconButton(
              icon: getPlayIcon(),
              onPressed: playMusic,
            ),
          ),
          new Container(
            margin: new EdgeInsets.symmetric(horizontal: 4.0),
            child: new IconButton(
              icon: new Icon(Icons.skip_next),
              onPressed: _controller.playNextSong,
            ),
          ),
          new Container(
            margin: new EdgeInsets.symmetric(horizontal: 4.0),
            child: getRepeatIconButton(),
          ),
        ],
      ),
    );
  }

  playMusic() {
    setState(() {
      _controller.playMusic();
    });
  }

  enableShuffle() {
    setState(() {
      _controller.enableShuffle();
    });
  }

  enableRepeat() {
    setState(() {
      _controller.enableRepeat();
    });
  }

  Icon getPlayIcon() {
    if (_model.isPlaying) {
      return new Icon(Icons.pause);
    }

    return new Icon(Icons.play_arrow);
  }

  IconButton getShuffleIconButton() {
    if (_model.isShuffle) {
      return new IconButton(
        color: Theme.of(context).accentColor,
        icon: new Icon(Icons.shuffle),
        onPressed: enableShuffle,
      );
    }

    return new IconButton(
      color: Theme.of(context).primaryColor,
      icon: new Icon(Icons.shuffle),
      onPressed: enableShuffle,
    );
  }

  IconButton getRepeatIconButton() {
    if (_model.isRepeat) {
      return new IconButton(
        color: Theme.of(context).accentColor,
        icon: new Icon(Icons.repeat),
        onPressed: enableRepeat,
      );
    }

    return new IconButton(
      color: Theme.of(context).primaryColor,
      icon: new Icon(Icons.repeat),
      onPressed: enableRepeat,
    );
  }
}
