import 'package:flutter/material.dart';

import '../app.dart';
import '../models/music.dart';
import '../views/musicPlayerView.dart';

class MusicItem extends StatelessWidget {
  final Music _music;
  BuildContext _context;
  final MusicChanger changeMusic;

  MusicItem(this._music, this.changeMusic);

  @override
  Widget build(BuildContext context) {
    _context = context;
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
                  _music.name,
                  style: new TextStyle(color: Theme.of(context).primaryColor),
                ),
                new Text(
                  _music.singer,
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
    changeMusic(_music);
  }
}
