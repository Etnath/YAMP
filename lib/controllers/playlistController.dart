import 'package:dart_message_bus/dart_message_bus.dart';

import '../models/ApplicationModel.dart';
import '../models/constants.dart';
import '../models/playlist.dart';
import '../models/song.dart';
import '../services/playlistLoader.dart';

class PlaylistController {
  ApplicationModel _model;
  MessageBus _messageBus;
  PlaylistLoader _playlistLoader;

  PlaylistController(this._model, this._messageBus) {
    _playlistLoader = new PlaylistLoader();

    _subscribe();
  }

  void _createPlaylist(Message message) {
    String playlistName = message.data;

    if (!_model.playLists.any((pl) {
      return pl.title == playlistName;
    })) {
      _model.playLists.add(new Playlist(playlistName, new List<Song>()));

      _messageBus.publish(new Message("ModelChanged"));
      _playlistLoader.savePlaylist(_model.playLists);
    }
  }

  void _deletePlaylist(Message message) {
    String playlistName = message.data;

    if (_model.playLists.any((pl) {
      return pl.title == playlistName;
    })) {
      _model.playLists.removeWhere((pl) {
        return pl.title == playlistName;
      });

      _messageBus.publish(new Message("ModelChanged"));
      _playlistLoader.savePlaylist(_model.playLists);
    }
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

    _messageBus.publish(new Message("ModelChanged"));
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

    _messageBus.publish(new Message("ModelChanged"));
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

    _messageBus.publish(new Message("ModelChanged"));
    _playlistLoader.savePlaylist(_model.playLists);
  }

  void _initPlaylistIfRequired(String playlistName) {
    if (!_model.playLists.any((pl) {
      return pl.title == playlistName;
    })) {
      _model.playLists.add(new Playlist(playlistName, new List<Song>()));
    }
  }

  ///Returns all the playlists that contain [song]
  List<Playlist> getPlaylists(Song song) {
    return _model.playLists.where((pl) {
      return pl.songs.any((s) {
        return s.path == song.path;
      });
    }).toList();
  }

  ///Returns the name of all the playlists
  List<String> getPlaylistNames() {
    return _model.playLists.map((pl) {
      return pl.title;
    }).toList();
  }

  void _subscribe() {
    _messageBus.subscribe(MessageNames.createPlaylist, _createPlaylist);
    _messageBus.subscribe(MessageNames.deletePlaylist, _deletePlaylist);
    _messageBus.subscribe(MessageNames.addToPlaylist, _onAddToPlaylist);
    _messageBus.subscribe(
        MessageNames.removeFromPlaylist, _onRemoveFromPlaylist);
    _messageBus.subscribe(
        MessageNames.toggleSongFromPlaylist, _onToggleFromPlaylist);
  }
}
