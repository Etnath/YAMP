import 'music.dart';

class ApplicationModel{
  bool isLoading;
  bool isPlaying;
  Music currentMusic;
  List<Music> musics;


  ApplicationModel(){
    isLoading = true;
    isPlaying = false;
    currentMusic = null;
    musics = new List<Music>();
  }
}