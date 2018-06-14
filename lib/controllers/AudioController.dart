import 'package:flutter/material.dart';

import 'package:audioplayer/audioplayer.dart';
import 'package:dart_message_bus/dart_message_bus.dart';

import '../models/ApplicationModel.dart';
import '../models/song.dart';

typedef MusicChanger(Song song);
typedef MusicPlay();
typedef NextSong();
typedef PreviousSong();

class AudioController {
  ApplicationModel _model;
  AudioPlayer _audioPlayer;
  MessageBus _navigationBus;

  AudioController(this._model, this._navigationBus) {
    _audioPlayer = new AudioPlayer();
  }

  void changeMusic(Song music) {
    if (_model.currentSong == null || _model.currentSong.path != music.path) {
      _model.currentSong = music;
      _audioPlayer
          .stop(); //for some reasons the player needs to be stopped before loading a new song
    }

    _model.isPlaying = true;
    _audioPlayer.play(_model.currentSong.path);
    _navigationBus.publish(new Message("PushRoute", data: "/MusicPlayer"));
  }

  void playMusic() {
    if (_model.isPlaying) {
      _audioPlayer.pause();
      _model.isPlaying = false;
    } else {
      _audioPlayer.play(_model.currentSong.path);
      _model.isPlaying = true;
    }
  }
}
