import 'package:flutter/material.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';

import '../controllers/audioController.dart';
import '../models/applicationModel.dart';
import '../widgets/musicProgressBar.dart';

class MusicPlayerWidget extends StatefulWidget {

  MusicPlayerWidget();

  @override
  State<StatefulWidget> createState() {
    return MusicPlayerState();
  }
}

class MusicPlayerState extends State<MusicPlayerWidget> {
  ApplicationModel _model = Injector.getInjector().get<ApplicationModel>();
  final AudioController _controller = Injector.getInjector().get<AudioController>();

  MusicPlayerState();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Column(
        children: <Widget>[
          new Expanded(
            child: new Center(
              child: new Container(
                margin: const EdgeInsets.symmetric(vertical: 50.0),
                child: new Column(
                  children: <Widget>[
                    new Text(_model.currentSong.name,
                        style: Theme.of(context).textTheme.title),
                    new Text(_model.currentSong.singer,
                        style: Theme.of(context).textTheme.subhead),
                    new Text(_model.currentSong.album,
                        style: Theme.of(context).textTheme.body1),
                  ],
                ),
              ),
            ),
          ),
          new MusicProgressBar(),
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
              onPressed: playPreviousSong,
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
              onPressed: playNextSong,
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

  playPreviousSong() {
    setState(() {
      _controller.playPreviousSong();
    });
  }

  playNextSong() {
    setState(() {
      _controller.playNextSong();
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
