import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

import 'package:path_provider/path_provider.dart';
import 'package:dart_tags/dart_tags.dart';

import '../models/music.dart';

class MusicLoader {
  
  static const _methodChannel = const MethodChannel('read');

  TagProcessor _tp;

  MusicLoader(){
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

  Future<List<Music>> loadMusic() async {
    Directory root = await getExternalStorageDirectory();
    var musicPath = root.path + "/Music";

    Directory musicDirectory = new Directory(musicPath);
    var fileList = musicDirectory.listSync();

    List<Music> musics = new List<Music>();
    for (var file in fileList) {
      if(file.path.toLowerCase().endsWith(".mp3"))
      {
        Music music = await createMusic(file.path);
        musics.add(music);
      }      
    }

    musics.add(new Music("ddddd/ddddd/dddd/dddd/dd","wdadwadw",'rrr'));
    return musics;
  }

  Future<Music> createMusic(String filePath) async{
    File file = new File(filePath);

    var tags = await _tp.getTagsFromByteArray(file.readAsBytes());
    for (var tag in tags) {
      if(tag.tags.length > 0)
      {
        String title = '';
        String singer = '';
        
        if(tag.tags.containsKey('title'))
        {
            title = tag.tags['title'];
        }

        if(tag.tags.containsKey('artist'))
        {
            singer = tag.tags['artist'];
        }
        return new Music(filePath, title, singer);
      }
    }

    //No tags
    return new Music(filePath, file.path.split('/').last.split('.').first, '');
  }
}

enum PermissionState { GRANTED, DENIED, SHOW_RATIONALE }
