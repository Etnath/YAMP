import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:path_provider/path_provider.dart';
import 'package:dart_tags/dart_tags.dart';

import '../models/song.dart';

class MusicLoader {
  static const _methodChannel = const MethodChannel('read');

  TagProcessor _tp;
  List<Song> _cachedSongs;

  MusicLoader() {
    _tp = new TagProcessor();
  }

  Future<PermissionState> canReadExternalStorage() async {
    try {
      final int result = await _methodChannel.invokeMethod('hasPermission');
      return new Future.value(PermissionState.values.elementAt(result));
    } on PlatformException catch (e) {
      print('Exception ' + e.toString());
    }
    return new Future.value(PermissionState.DENIED);
  }

  Future<List<Song>> loadMusic() async {
    Directory root = await getExternalStorageDirectory();
    var musicPath = root.path + "/Music";

    Directory musicDirectory = new Directory(musicPath);
    var fileList = musicDirectory.listSync(recursive: true);

    loadCachedSongs();

    List<Song> musics = new List<Song>();
    for (var file in fileList) {
      if (file.path.toLowerCase().endsWith(".mp3") ||
          file.path.toLowerCase().endsWith(".m4a")) {
        Song music = await createMusic(file.path);
        musics.add(music);
      }
    }

    saveCachedSongs();

    return musics;
  }

  void loadCachedSongs() async {
    final directory = await getApplicationDocumentsDirectory();

    _cachedSongs = new List<Song>();
    var file = new File(directory.path + "/cachedSong.json");
    if (file.existsSync()) {
      List<dynamic> songs = json.decode(file.readAsStringSync());
      for (var songJson in songs) {
        Song song = new Song.fromJson(songJson);

        //Cached songs generated with YAMP < v0.3 may generate empty fields, we need replace to replace them.
        if (song.singer == '') {
          song.singer = 'Unknown';
        }

        if (song.album == '') {
          song.album = 'Unknown';
        }
        _cachedSongs.add(song);
      }
    }
  }

  void saveCachedSongs() async {
    final directory = await getApplicationDocumentsDirectory();

    var file = new File(directory.path + "/cachedSong.json");
    if (directory.listSync().any((file) {
      return file.path == (directory.path + "/cachedSong.json");
    })) {
      file.deleteSync();
    }

    file.writeAsStringSync(json.encode(_cachedSongs));
  }

  Future<Song> createMusic(String filePath) async {
    File file = new File(filePath);

    if (_cachedSongs != null &&
        _cachedSongs.any((cachedSong) {
          return cachedSong.path == filePath;
        })) {
      return _cachedSongs.firstWhere((cachedSong) {
        return cachedSong.path == filePath;
      });
    }

    var tags = await _tp.getTagsFromByteArray(file.readAsBytes());
    for (var tag in tags) {
      if (tag.tags.length > 0) {
        String title = 'Unknown';
        String singer = 'Unknown';
        String album = 'Unknown';

        if (tag.tags.containsKey('title') &&
            tag.tags['title'].toString().length > 0) {
          title = tag.tags['title'];
        } else {
          title = file.path.split('/').last.split('.').first;
        }

        if (tag.tags.containsKey('artist')) {
          singer = tag.tags['artist'];
        }

        if (tag.tags.containsKey('album')) {
          album = tag.tags['album'];
        }

        var song = new Song(filePath, title, singer, album);
        _cachedSongs.add(song);

        return new Song(filePath, title, singer, album);
      }
    }

    //No tags
    var song = new Song(filePath, file.path.split('/').last.split('.').first,
        'Unknown', 'Unknown');
    _cachedSongs.add(song);
    return song;
  }
}

enum PermissionState { GRANTED, DENIED, SHOW_RATIONALE }
