import 'package:flutter/material.dart';
import 'package:dart_message_bus/dart_message_bus.dart';

import '../models/song.dart';

class ArtistItem extends StatelessWidget {
  final String artist;
  final List<Song> _songs;
  final MessageBus _messageBus;

  ArtistItem(this.artist, this._songs, this._messageBus);

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
                    artist,
                    style: new TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  new Text(
                    _songs.length.toString() + " songs",
                    style: Theme.of(context).textTheme.body1,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  _handleOnTap() 
  {
    Map<String, dynamic> data = {
      'artist': artist,
      'songs': _songs
    };

    _messageBus.publish(new Message("Push/Artist", data: data));
  }
}
