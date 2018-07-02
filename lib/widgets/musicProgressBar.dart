import 'package:flutter/material.dart';
import 'package:dart_message_bus/dart_message_bus.dart';
import '../models/constants.dart';

class MusicProgressBar extends StatefulWidget {
  final MessageBus _messageBus;

  MusicProgressBar(this._messageBus);

  @override
  State<StatefulWidget> createState() {
    return MusicProgressBarState(this._messageBus);
  }
}

class MusicProgressBarState extends State<MusicProgressBar> {
  Duration _currentSongPosition;
  Duration _currentSongLength; //in s
  double _progress = 0.0;
  String _progressText;
  MessageBus _messageBus;

  MusicProgressBarState(this._messageBus) {
    _currentSongPosition = new Duration();
    _currentSongLength = new Duration();
    _progressText = "-- / --";
    _messageBus.subscribe("music/progressChanged", onProgressChanged);
    _messageBus.subscribe("music/songChanged", onCurrentSongChanged);
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTapDown: onProgressBarTapDown,
      child: new Column(
        children: <Widget>[
          new Stack(
            children: <Widget>[
              new Column(
                children: <Widget>[
                  //Hack: the three following bar are just here to expand the area of the gesture detector. To refactor later.
                  new LinearProgressIndicator(
                    value: 0.0,
                    backgroundColor: Theme.of(context).canvasColor,
                  ),
                  new LinearProgressIndicator(
                    value: 0.0,
                    backgroundColor: Theme.of(context).canvasColor,
                  ),
                  new LinearProgressIndicator(
                    value: 0.0,
                    backgroundColor: Theme.of(context).canvasColor,
                  )
                ],
              ),
              new Center(
                child: Text(_progressText),
              ),
            ],
          ),
          new LinearProgressIndicator(
            value: _progress,
          ),
        ],
      ),
    );
  }

  void onProgressChanged(Message message) {
    _currentSongPosition = message.data;

    if (this.mounted) {
      setState(() {
        _progress = _currentSongPosition.inMilliseconds /
            _currentSongLength.inMilliseconds;
        _progressText = formatDuration(_currentSongPosition) +
            " / " +
            formatDuration(_currentSongLength);
      });
    }
  }

  void onCurrentSongChanged(Message message) {
    _currentSongLength = message.data;
    _currentSongPosition = new Duration();

    setState(() {
      _progress = _currentSongPosition.inMilliseconds /
          _currentSongLength.inMilliseconds;
      _progressText = formatDuration(_currentSongPosition) +
          " / " +
          formatDuration(_currentSongLength);
    });
  }

  String formatDuration(Duration duration) {
    int seconds = duration.inSeconds % 60;
    String formattedDuration = seconds.toString();
    if (seconds < 10) {
      formattedDuration = "0" + formattedDuration;
    }
    return duration.inMinutes.toString() + ":" + formattedDuration;
  }

  void onProgressBarTapDown(TapDownDetails details) {
    RenderBox box = context.findRenderObject();
    var tapPos = box.globalToLocal(details.globalPosition);
    var width = box.size.width;
    var seekPercentage = tapPos.dx / width;
    _messageBus.publish(new Message(MessageNames.musicSeek, data: seekPercentage));
  }
}
