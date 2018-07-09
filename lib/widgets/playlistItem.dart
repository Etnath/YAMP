import 'dart:async';

import 'package:dart_message_bus/dart_message_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';

import '../models/constants.dart';
import '../models/playlist.dart';
import 'deletePlaylistDialog.dart';

class PlaylistItem extends StatefulWidget {
  final Playlist _playlist;

  PlaylistItem(this._playlist);

  @override
  State<StatefulWidget> createState() {
    return new PlaylistState(this._playlist);
  }
}

class PlaylistState extends State<PlaylistItem> {
  Playlist _playlist;
  final MessageBus _messageBus = Injector.getInjector().get<MessageBus>();

  PlaylistState(this._playlist) {
    _messageBus.subscribe(MessageNames.modelChanged, onModelChanged);
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: const EdgeInsets.only(top: 2.0),
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      decoration: new BoxDecoration(color: Theme.of(context).cardColor),
      child: _buildTile(context),
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
                    _playlist.title,
                    style: new TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  new Text(
                    _playlist.songs.length.toString() + " songs",
                    style: Theme.of(context).textTheme.body1,
                  ),
                ],
              ),
            ),
          ),
          _showDeleteIcon(context),
        ],
      ),
    );
  }

  Widget _showDeleteIcon(BuildContext context) {
    if (_playlist.title == DefaultPlaylistNames.favorites) {
      return new IgnorePointer(
        child: new Opacity(
          opacity: 0.0,
          child: new IconButton(
            onPressed: _deletePlaylist,
            icon: new Icon(Icons.remove_circle),
          ),
        ),
      );
    } else {
      return new IconButton(
        onPressed: _deletePlaylist,
        icon: new Icon(Icons.remove_circle),
        color: Theme.of(context).accentColor,
      );
    }
  }

  Future<Null> _showDeleteDialog() async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return new DeletePlaylistDialog(_playlist.title);
      },
    );
  }

  _handleOnTap() {
    _messageBus
        .publish(new Message(MessageNames.pushPlaylist, data: _playlist));
  }

  void onModelChanged(Message message) {
    if (mounted) {
      setState(() {
        _playlist = _playlist;
      });
    }
  }

  void _deletePlaylist() {
    _showDeleteDialog();
  }
}
