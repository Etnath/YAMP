import 'song.dart';

class ApplicationModel{
  bool isLoading;
  bool isPlaying;
  bool isRepeat;
  bool isShuffle;
  Song currentSong;
  List<Song> songs;


  ApplicationModel(){
    isLoading = true;
    isPlaying = false;
    isRepeat = false;
    isShuffle = false;
    currentSong = null;
    songs = new List<Song>();
  }
}