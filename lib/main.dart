import 'package:flutter/material.dart';

import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:dart_message_bus/dart_message_bus.dart';

import 'app.dart';
import 'controllers/audioController.dart';
import 'models/applicationModel.dart';
import 'controllers/playlistController.dart';
import 'services/playlistLoader.dart';
import 'services/musicLoader.dart';

void main(){
  final injector = Injector.getInjector();

  injector.map<ApplicationModel>((i) => new ApplicationModel(), isSingleton: true);
  injector.map<MessageBus>((i) => new MessageBus(), isSingleton: true);
  injector.map<AudioController>((i) => new AudioController(), isSingleton: true);
  injector.map<PlaylistController>((i) => new PlaylistController(), isSingleton: true);
  injector.map<PlaylistLoader>((i) => new PlaylistLoader(), isSingleton: true);
  injector.map<MusicLoader>((i) => new MusicLoader(), isSingleton: true);

  runApp(new YampApp());
}