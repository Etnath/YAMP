import 'dart:async';

import 'package:dart_message_bus/dart_message_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';

import '../controllers/audioController.dart';
import '../controllers/playlistController.dart';
import '../models/Constants.dart';
import '../models/song.dart';
import 'createPlaylistDialog.dart';

class MusicItem extends StatefulWidget {
  final Song song;
  final List<Song> _playlist;
  

  MusicItem(this.song, this._playlist);

  @override
  State<StatefulWidget> createState() {
    return new MusicItemState(this.song, this._playlist);
  }
}

class MusicItemState extends State<MusicItem> {
  Song song;
  final List<Song> _playlist;
  final AudioController _audioController = Injector.getInjector().get<AudioController>();
  final PlaylistController _playlistController = Injector.getInjector().get<PlaylistController>();
  final MessageBus _messageBus = Injector.getInjector().get<MessageBus>();

  List<String> _playlistNames;

  MusicItemState(this.song, this._playlist) {
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
                  child: _getPlaylistPopuItemContent(context, playlist),
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

  Widget _getPlaylistPopuItemContent(BuildContext context, String playlist)
  {
    if(playlist == 'Create Playlist'){
      return Text(playlist);
    } else {
    var playlists = _playlistController.getPlaylists(song);

    if(playlists.any((pl) { return pl.title == playlist;})){
      return Row(
        children: [
          Icon(Icons.star, color: Theme.of(context).accentColor,),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 8.0),
              child: Text(playlist),
            ) 
          ),         
        ],
      );
    } else {
      return Row(
        children: [
          Icon(Icons.star_border),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 8.0),
              child: Text(playlist),
            ) 
          ),         
        ],
      );
    }
    }
  }

  Future<Null> _showCreateDialog() async {
  return showDialog<Null>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return new CreatePlaylistDialog();
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
