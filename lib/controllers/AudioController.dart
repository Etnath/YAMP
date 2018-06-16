import 'package:audioplayer/audioplayer.dart';
import 'package:dart_message_bus/dart_message_bus.dart';
import 'dart:math';

import '../models/ApplicationModel.dart';
import '../models/song.dart';

typedef MusicChanger(Song song);
typedef MusicPlay();
typedef NextSong();
typedef PreviousSong();
typedef EnableShuffle();
typedef EnableRepeat();

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

  void playNextSong() {
    if (_model.isRepeat) {
      _audioPlayer.seek(0.0);
      return;
    }

    Song nextSong;
    if (_model.isShuffle) {
      int i = new Random().nextInt(_model.songs.length - 1);
      nextSong = _model.songs[i];
    } else {
      int currentSongIndex = _model.songs.indexOf(_model.currentSong);

      if (currentSongIndex >= _model.songs.length) {
        nextSong = _model.songs[0];
      } else {
        nextSong = _model.songs[currentSongIndex + 1];
      }
    }

    changeMusic(nextSong);
  }

  void playPreviousSong() {
    if (_model.isRepeat) {
      _audioPlayer.seek(0.0);
      return;
    }

    Song previousSong;
    int currentSongIndex = _model.songs.indexOf(_model.currentSong);

    if (currentSongIndex <= 0) {
      previousSong = _model.songs[_model.songs.length - 1];
    } else {
      previousSong = _model.songs[currentSongIndex - 1];
    }

    changeMusic(previousSong);
  }

  void enableRepeat() {
    _model.isRepeat = !_model.isRepeat;
  }

  void enableShuffle() {
    _model.isShuffle = !_model.isShuffle;
  }
}
