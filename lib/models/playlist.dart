import 'dart:convert';

import 'song.dart';

class Playlist{
  String title;
  List<Song> songs;

  Playlist(this.title, this.songs);

  Playlist.fromJson(Map<String, dynamic> json)
  {
    songs = new List<Song>();
    title = json['title'];
    
    var songsJson = json['songs'];
    if(songsJson != '[]')
    {
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
    
  }

  Map<String, dynamic> toJson() =>
    {
      'title': title,
      'songs': json.encode(songs)
    };
}