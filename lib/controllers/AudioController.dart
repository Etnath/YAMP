import 'package:audioplayer/audioplayer.dart';
import 'dart:math';
import 'package:dart_message_bus/dart_message_bus.dart';

import '../models/ApplicationModel.dart';
import '../models/song.dart';
import '../models/constants.dart';
import '../models/playlist.dart';
import '../services/playlistLoader.dart';

typedef MusicChanger(Song song);
typedef MusicPlay();
typedef NextSong();
typedef PreviousSong();
typedef EnableShuffle();
typedef EnableRepeat();

class AudioController {
  ApplicationModel _model;
  AudioPlayer _audioPlayer;
  MessageBus _messageBus;
  Duration _currentSongDuration;
  PlaylistLoader _playlistLoader;

  AudioController(this._model, this._messageBus) {
    _audioPlayer = new AudioPlayer();
    _currentSongDuration = new Duration();
    _playlistLoader = new PlaylistLoader();

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

  void _onAddToPlaylist(Message message) {
    Map<String, dynamic> data = message.data;
    String playlistName = data['playlist'];
    Song song = data['song'];

    _initPlaylistIfRequired(playlistName);

    var playlist = _model.playLists.firstWhere((pl) {
      return pl.title == playlistName;
    });
    if (!playlist.songs.any((s) {
      return s.path == song.path;
    })) {
      playlist.songs.add(song);
    }

    _playlistLoader.savePlaylist(_model.playLists);
  }

  void _onRemoveFromPlaylist(Message message) {
    Map<String, dynamic> data = message.data;
    String playlistName = data['playlist'];
    Song song = data['song'];

    _initPlaylistIfRequired(playlistName);

    var playlist = _model.playLists.firstWhere((pl) {
      return pl.title == playlistName;
    });
    if (playlist.songs.any((s) {
      return s.path == song.path;
    })) {
      playlist.songs.removeWhere((s) {
        return s.path == song.path;
      });
    }

    _playlistLoader.savePlaylist(_model.playLists);
  }

  void _onToggleFromPlaylist(Message message) {
    Map<String, dynamic> data = message.data;
    String playlistName = data['playlist'];
    Song song = data['song'];

    _initPlaylistIfRequired(playlistName);

    var playlist = _model.playLists.firstWhere((pl) {
      return pl.title == playlistName;
    });
    if (playlist.songs.any((s) {
      return s.path == song.path;
    })) {
      playlist.songs.removeWhere((s) {
        return s.path == song.path;
      });
    } else {
      playlist.songs.add(song);
    }

    _playlistLoader.savePlaylist(_model.playLists);
  }

  void _initPlaylistIfRequired(String playlistName) {
    if (!_model.playLists.any((pl) {
      return pl.title == playlistName;
    })) {
      _model.playLists.add(new Playlist(playlistName, new List<Song>()));
    }
  }

  void dispose() {
    _audioPlayer.stop();
  }

  void _subscribe() {
    _audioPlayer.onPlayerStateChanged.listen((onPlayerStateChanged));
    _audioPlayer.onAudioPositionChanged.listen(onAudioPositionChanged);

    _messageBus.subscribe(MessageNames.musicSeek, onSeekRequest);
    _messageBus.subscribe(MessageNames.addToPlaylist, _onAddToPlaylist);
    _messageBus.subscribe(
        MessageNames.removeFromPlaylist, _onRemoveFromPlaylist);
    _messageBus.subscribe(
        MessageNames.toggleSongFromPlaylist, _onToggleFromPlaylist);
  }
}
