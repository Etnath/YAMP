import 'dart:async';

import 'package:flutter/material.dart';
import 'package:dart_message_bus/dart_message_bus.dart';

import 'createPlaylistDialog.dart';
import '../controllers/audioController.dart';
import '../controllers/playlistController.dart';
import '../models/song.dart';
import '../models/Constants.dart';

class MusicItem extends StatefulWidget {
  final Song song;
  final List<Song> _playlist;
  final AudioController _audioController;
  final PlaylistController _playlistController;
  final MessageBus _messageBus;

  MusicItem(this.song, this._playlist, this._audioController,
      this._playlistController, this._messageBus);

  @override
  State<StatefulWidget> createState() {
    return new MusicItemState(this.song, this._playlist, this._audioController,
        this._playlistController, this._messageBus);
  }
}

class MusicItemState extends State<MusicItem> {
  Song song;
  final List<Song> _playlist;
  final AudioController _audioController;
  final PlaylistController _playlistController;
  final MessageBus _messageBus;

  List<String> _playlistNames;

  MusicItemState(this.song, this._playlist, this._audioController,
      this._playlistController, this._messageBus) {
    _initPlaylistNames();
    _messageBus.subscribe(MessageNames.modelChanged, onModelChanged);
  }

  void _initPlaylistNames() {
    _playlistNames = _playlistController.getPlaylistNames();
    _playlistNames.add("Create Playlist");
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        new Container(
          margin: const EdgeInsets.only(bottom: 2.0),
          padding: const EdgeInsets.symmetric(vertical: 5.0),
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
          _getFavoriteButton(context),
          new PopupMenuButton<String>(
            onSelected: _selectPlaylist,
            itemBuilder: (BuildContext context) {
              return _playlistNames.map((String playlist) {
                return PopupMenuItem<String>(
                  value: playlist,
                  child: Text(playlist),
                );
              }).toList();
            },
            icon: new Icon(Icons.more_vert),
          ),
        ],
      ),
    );
  }

  _handleOnTap() {
    _audioController.changeMusic(song);
    _messageBus
        .publish(new Message(MessageNames.pushMusicPlayer, data: _playlist));
  }

  Widget _getFavoriteButton(BuildContext context) {
    var playlists = _playlistController.getPlaylists(song);

    if (playlists.any((pl) {
      return pl.title == DefaultPlaylistNames.favorites;
    })) {
      return new IconButton(
        onPressed: _onFavoritePressed,
        color: Theme.of(context).accentColor,
        icon: new Icon(Icons.star),
      );
    } else {
      return new IconButton(
        onPressed: _onFavoritePressed,
        icon: new Icon(Icons.star_border),
      );
    }
  }

  Future<Null> _showCreateDialog() async {
  return showDialog<Null>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return new CreatePlaylistDialog(_messageBus);
    },
  );
}

  void _onFavoritePressed() {
    _selectPlaylist(DefaultPlaylistNames.favorites);
  }

  void _selectPlaylist(String value) {
    if (value == "Create Playlist") {
      _showCreateDialog();
    } else {
      Map<String, dynamic> data = {'playlist': value, 'song': song};

      _messageBus.publish(
          new Message(MessageNames.toggleSongFromPlaylist, data: data));
    }
  }

  void onModelChanged(Message message) {
    if (mounted) {
      setState(() {
        song = song;
        _initPlaylistNames();
      });
    }
  }
}
