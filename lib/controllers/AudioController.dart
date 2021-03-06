import 'dart:math';

import 'package:audioplayer/audioplayer.dart';
import 'package:dart_message_bus/dart_message_bus.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';

import '../models/applicationModel.dart';
import '../models/constants.dart';
import '../models/song.dart';

typedef MusicChanger(Song song);
typedef MusicPlay();
typedef NextSong();
typedef PreviousSong();
typedef EnableShuffle();
typedef EnableRepeat();

class AudioController {
  ApplicationModel _model = Injector.getInjector().get<ApplicationModel>();
  AudioPlayer _audioPlayer;
  MessageBus _messageBus = Injector.getInjector().get<MessageBus>();
  Duration _currentSongDuration;

  AudioController() {
    _audioPlayer = new AudioPlayer();
    _currentSongDuration = new Duration();

    _subscribe();
  }

  void changeMusic(Song music) {
    if (_model.currentSong == null || _model.currentSong.path != music.path) {
      _model.currentSong = music;
      _audioPlayer.stop().whenComplete(
          startAudioPlayer); //for some reasons the player needs to be stopped before loading a new song
    } else {
      startAudioPlayer();
    }
  }

  void startAudioPlayer() {
    _model.isPlaying = true;
    _audioPlayer.play(_model.currentSong.path);
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
      int currentSongIndex = _model.currentPlaylist.indexOf(_model.currentSong);

      if (currentSongIndex >= (_model.currentPlaylist.length - 1)) {
        nextSong = _model.currentPlaylist[0];
      } else {
        nextSong = _model.currentPlaylist[currentSongIndex + 1];
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
    int currentSongIndex = _model.currentPlaylist.indexOf(_model.currentSong);

    if (currentSongIndex <= 0) {
      previousSong = _model.currentPlaylist[_model.currentPlaylist.length - 1];
    } else {
      previousSong = _model.currentPlaylist[currentSongIndex - 1];
    }

    changeMusic(previousSong);
  }

  void enableRepeat() {
    _model.isRepeat = !_model.isRepeat;
  }

  void enableShuffle() {
    _model.isShuffle = !_model.isShuffle;
  }

  void onPlayerStateChanged(AudioPlayerState state) {
    if (state == AudioPlayerState.COMPLETED) {
      playNextSong();
      _messageBus.publish(new Message("ModelChanged"));
    }
  }

  void onAudioPositionChanged(Duration event) {
    if (_currentSongDuration != _audioPlayer.duration) {
      _messageBus.publish(
          new Message("music/songChanged", data: _audioPlayer.duration));
      _currentSongDuration = _audioPlayer.duration;
    }
    _messageBus.publish(new Message("music/progressChanged", data: event));
  }

  void onSeekRequest(Message message) {
    double seconds = message.data * _audioPlayer.duration.inSeconds;
    _audioPlayer.seek(seconds);
  }

  

  void dispose() {
    _audioPlayer.stop();
  }

  void _subscribe() {
    _audioPlayer.onPlayerStateChanged.listen((onPlayerStateChanged));
    _audioPlayer.onAudioPositionChanged.listen(onAudioPositionChanged);

    _messageBus.subscribe(MessageNames.musicSeek, onSeekRequest);
    
  }
}
