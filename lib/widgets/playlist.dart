import 'package:flutter/material.dart';

import '../widgets/musicItem.dart';

class PlayList extends StatelessWidget {
  final List<MusicItem> _musicItems;
  final String _title;

  PlayList(this._musicItems, this._title);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body:new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        new AppBar(
          title: new Text(_title),
          leading: new Container(
            margin: const EdgeInsets.fromLTRB(8.0, 8.0, 0.0, 8.0),
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
    ),
    );
  }
}
