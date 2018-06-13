import 'music.dart';

class ApplicationModel{
  bool isLoading;
  bool isPlaying;
  Music currentMusic;

  ApplicationModel(){
    isLoading = true;
    isPlaying = false;
    currentMusic = null;
  }
}