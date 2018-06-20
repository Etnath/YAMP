import 'package:flutter/material.dart';

import 'musicItem.dart';

class MusicList extends StatelessWidget {
  final List<MusicItem> _musicItems;

  MusicList(this._musicItems);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        new AppBar(
          title: new Text("Music List"),
          leading: new Container(
            margin: const EdgeInsets.fromLTRB(12.0, 8.0, 0.0, 8.0),
            child: Image.asset('resources/YAMPLogoLetter.png'),
          ),
        ),
        new Flexible(
          child: new ListView.builder(
            itemBuilder: (_, int index) => _musicItems[index],
            itemCount: _musicItems.length,
          ),
        ),
      ],
    );
  }
}
