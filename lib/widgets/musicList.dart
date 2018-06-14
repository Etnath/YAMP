import 'package:flutter/material.dart';

import 'musicItem.dart';

class MusicList extends StatelessWidget {
  final List<MusicItem> _musicItems;

  MusicList(this._musicItems);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new ListView.builder(
      padding: new EdgeInsets.all(8.0),
      itemBuilder: (_, int index) => _musicItems[index],
      itemCount: _musicItems.length,
    );
  }
}
