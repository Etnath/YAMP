import 'dart:convert';

import 'song.dart';

class Playlist {
  String title;
  List<Song> songs;

  Playlist(this.title, this.songs);

  Playlist.fromJson(Map<String, dynamic> jsonDocument) {
    songs = new List<Song>();
    title = jsonDocument['title'];

    List<dynamic> songsJson = json.decode(jsonDocument['songs']);
    for (var songJson in songsJson) {
      Song song = new Song.fromJson(songJson);

      //Cached songs generated with YAMP < v0.3 may generate empty fields, we need replace to replace them.
      if (song.singer == '') {
        song.singer = 'Unknown';
      }

      if (song.album == '') {
        song.album = 'Unknown';
      }
      songs.add(song);
    }
  }

  Map<String, dynamic> toJson() =>
      {'title': title, 'songs': json.encode(songs)};
}
