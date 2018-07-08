import 'package:dart_message_bus/dart_message_bus.dart';
import 'package:flutter/material.dart';

import '../models/constants.dart';

class DeletePlaylistDialog extends StatelessWidget {
  final MessageBus _messageBus;
  final String _playlistName;

  DeletePlaylistDialog(this._messageBus, this._playlistName);

  @override
  Widget build(BuildContext context) {
    return new AlertDialog(
      title: new Text(
        'Delete Playlist',
        style: new TextStyle(
          color: Theme.of(context).primaryColor,
        ),
      ),
      content: new SingleChildScrollView(
        child: new ListBody(
          children: <Widget>[
            new Text('Are you sure you want to delete ' + _playlistName + '?'),
          ],
        ),
      ),
      actions: <Widget>[
        new FlatButton(
          child: new Text('Delete'),
          onPressed: () {
              _messageBus.publish(new Message(MessageNames.deletePlaylist,
                  data: _playlistName));

            Navigator.of(context).pop();
          },
        ),
        new FlatButton(
          child: new Text(
            'Cancel',
            style: Theme.of(context).textTheme.body1,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
