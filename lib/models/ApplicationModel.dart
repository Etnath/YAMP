import 'song.dart';

import '../utilities/helper.dart';

class ApplicationModel {
  bool isLoading;
  bool isPlaying;
  bool isRepeat;
  bool isShuffle;
  Song currentSong;
  List<Song> songs;
  List<Song> currentPlaylist;
  Map<String, List<Song>> songsGroupedBySinger;
  Map<String, List<Song>> songsGroupedByAlbum;

  ApplicationModel() {
    isLoading = true;
    isPlaying = false;
    isRepeat = false;
    isShuffle = false;
    currentSong = null;
    songs = new List<Song>();
    currentPlaylist = new List<Song>();
    songsGroupedBySinger = new Map<String, List<Song>>();
    songsGroupedByAlbum = new Map<String, List<Song>>();
  }

  void init(List<Song> loadedSongs) {
    songs = loadedSongs;
    songsGroupedBySinger =
        Helper.groupBy(loadedSongs, (Song song) => song.singer);
    songsGroupedByAlbum =
        Helper.groupBy(loadedSongs, (Song song) => song.album);
    currentPlaylist = songs;
  }
}
