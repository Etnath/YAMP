import 'package:flutter/material.dart';
import 'package:dart_message_bus/dart_message_bus.dart';

import '../controllers/AudioController.dart';
import '../models/song.dart';

class MusicItem extends StatelessWidget {
  final Song _song;
  final MusicChanger changeMusic;
  final MessageBus _navigationBus;

  MusicItem(this._song, this.changeMusic, this._navigationBus);

  @override
  Widget build(BuildContext context) {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        new GestureDetector(
          onTap: _handleOnTap,
          child: new Container(
          margin: const EdgeInsets.only(top: 2.0),
          decoration: new BoxDecoration(color: Theme.of(context).cardColor),
          child: new ListTile(
            title: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text(
                  _song.name,
                  style: new TextStyle(color: Theme.of(context).primaryColor),
                ),
                new Text(
                  _song.singer,
                  style: Theme.of(context).textTheme.body1,
                ),
              ],
            ),
          ),
        ),
        ),       
        new Divider(height: 1.0),
      ],
    );
  }

  _handleOnTap()
  {
    changeMusic(_song);
    _navigationBus.publish(new Message("PushRoute", data: "/MusicPlayer"));
  }
}
