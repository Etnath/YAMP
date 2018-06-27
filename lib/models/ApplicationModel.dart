import 'song.dart';

class ApplicationModel{
  bool isLoading;
  bool isPlaying;
  bool isRepeat;
  bool isShuffle;
  Song currentSong;
  List<Song> songs;
  Map<String, List<Song>> songsGroupedBySinger;
  Map<String, List<Song>> songsGroupedByAlbum;


  ApplicationModel(){
    isLoading = true;
    isPlaying = false;
    isRepeat = false;
    isShuffle = false;
    currentSong = null;
    songs = new List<Song>();
    songsGroupedBySinger = new Map<String, List<Song>>();
    songsGroupedByAlbum = new Map<String, List<Song>>();
  }
}