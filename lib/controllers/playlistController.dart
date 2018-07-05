import 'package:dart_message_bus/dart_message_bus.dart';

import '../models/ApplicationModel.dart';
import '../models/song.dart';
import '../models/constants.dart';
import '../models/playlist.dart';
import '../services/playlistLoader.dart';

class PlaylistController {
  ApplicationModel _model;
  MessageBus _messageBus;
  PlaylistLoader _playlistLoader;

  PlaylistController(this._model, this._messageBus) {
    _playlistLoader = new PlaylistLoader();

    _subscribe();
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

  void _subscribe() {
    _messageBus.subscribe(MessageNames.addToPlaylist, _onAddToPlaylist);
    _messageBus.subscribe(
        MessageNames.removeFromPlaylist, _onRemoveFromPlaylist);
    _messageBus.subscribe(
        MessageNames.toggleSongFromPlaylist, _onToggleFromPlaylist);
  }
}