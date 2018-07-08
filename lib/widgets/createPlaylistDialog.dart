import 'package:dart_message_bus/dart_message_bus.dart';
import 'package:flutter/material.dart';

import '../models/constants.dart';

class CreatePlaylistDialog extends StatelessWidget {
  final MessageBus _messageBus;
  final TextEditingController controller = new TextEditingController();

  CreatePlaylistDialog(this._messageBus);

  @override
  Widget build(BuildContext context) {
    return new AlertDialog(
      title: new Text('Create Playlist'),
      content: new SingleChildScrollView(
        child: new ListBody(
          children: <Widget>[
            new TextField(controller: controller),
          ],
        ),
      ),
      actions: <Widget>[
        new FlatButton(
          child: new Text('Create'),
          onPressed: () {
            if (controller.text.length > 0) {
              _messageBus.publish(new Message(MessageNames.createPlaylist, data: controller.text));
            }

            Navigator.of(context).pop();
          },
        ),
        new FlatButton(
          child: new Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
