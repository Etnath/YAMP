import 'song.dart';

class ApplicationModel{
  bool isLoading;
  bool isPlaying;
  Song currentSong;
  List<Song> songs;


  ApplicationModel(){
    isLoading = true;
    isPlaying = false;
    currentSong = null;
    songs = new List<Song>();
  }
}