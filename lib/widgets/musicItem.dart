import 'package:flutter/material.dart';
import 'package:dart_message_bus/dart_message_bus.dart';

import '../controllers/AudioController.dart';
import '../models/song.dart';
import '../models/Constants.dart';

class MusicItem extends StatelessWidget {
  final Song song;
  final List<Song> _playlist;
  final MusicChanger changeMusic;
  final MessageBus _messageBus;

  MusicItem(this.song, this._playlist, this.changeMusic, this._messageBus);

  @override
  Widget build(BuildContext context) {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        new Container(
          margin: const EdgeInsets.only(top: 2.0),
          decoration: new BoxDecoration(color: Theme.of(context).cardColor),
          child: _buildTile(context),
        ),
        new Divider(height: 1.0),
      ],
    );
  }

  Widget _buildTile(BuildContext context) {
    return new ListTile(
      title: new Row(
        children: <Widget>[
          new Expanded(
            child: new GestureDetector(
              onTap: _handleOnTap,
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Text(
                    song.name,
                    style: new TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  new Text(
                    song.singer,
                    style: Theme.of(context).textTheme.body1,
                  ),
                  new Text(
                    song.album,
                    style: Theme.of(context).textTheme.body1,
                  ),
                ],
              ),
            ),
          ),
          new IconButton(
            onPressed: _onFavoritePressed,
            icon: new Icon(Icons.star_border),
          ),
          new Icon(Icons.more_vert)
        ],
      ),
    );
  }

  _handleOnTap() {
    changeMusic(song);
    _messageBus
        .publish(new Message(MessageNames.pushMusicPlayer, data: _playlist));
  }

  void _onFavoritePressed() {
    Map<String, dynamic> data = {'playlist': DefaultPlaylistNames.favorites, 'song': song};

    _messageBus
        .publish(new Message(MessageNames.toggleSongFromPlaylist, data: data));
  }
}
