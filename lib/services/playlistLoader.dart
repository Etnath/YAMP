import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/constants.dart';
import '../models/playlist.dart';
import '../models/song.dart';

class PlaylistLoader {
  Future<List<Playlist>> loadPlaylists() async {
    final directory = await getApplicationDocumentsDirectory();

    var loadedPlaylists = new List<Playlist>();

    var file = new File(directory.path + LocalPath.playlists);
    if (file.existsSync()) {
      List<dynamic> playlists = json.decode(file.readAsStringSync());

      for (var playlistJson in playlists) {
        loadedPlaylists.add(new Playlist.fromJson(playlistJson));
      }
    } else {
      loadedPlaylists
          .add(new Playlist(DefaultPlaylistNames.favorites, new List<Song>()));
    }

    return loadedPlaylists;
  }

  void savePlaylist(List<Playlist> playlists) async {
    final directory = await getApplicationDocumentsDirectory();

    var file = new File(directory.path + LocalPath.playlists);

    file.writeAsStringSync(json.encode(playlists));
  }
}
