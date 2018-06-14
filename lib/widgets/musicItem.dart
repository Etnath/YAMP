import 'package:flutter/material.dart';

import '../app.dart';
import '../models/song.dart';

class MusicItem extends StatelessWidget {
  final Song _song;
  final MusicChanger changeMusic;

  MusicItem(this._song, this.changeMusic);

  @override
  Widget build(BuildContext context) {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        new GestureDetector(
          onTap: _handleOnTap,
          child: new Container(
          margin: const EdgeInsets.only(top: 5.0),
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
  }
}
