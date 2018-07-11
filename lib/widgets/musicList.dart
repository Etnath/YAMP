import 'package:dart_message_bus/dart_message_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';

import '../models/applicationModel.dart';
import '../models/constants.dart';
import '../models/song.dart';
import 'albumItem.dart';
import 'artistItem.dart';
import 'musicItem.dart';
import 'playlistItem.dart';

class MusicList extends StatefulWidget {

  MusicList();

  @override
  State<StatefulWidget> createState() {
    return MusicListState();
  }
}

class MusicListState extends State<MusicList> {
  final ApplicationModel _model = Injector.getInjector().get<ApplicationModel>();
  final MessageBus _messageBus = Injector.getInjector().get<MessageBus>();

  List<MusicItem> _musicItems;
  List<ArtistItem> _artistItems;
  List<AlbumItem> _albumItems;
  List<PlaylistItem> _playlistItems;
  SortMode _sortMode;

  MusicListState() {
    _musicItems = new List<MusicItem>();
    _artistItems = new List<ArtistItem>();
    _albumItems = new List<AlbumItem>();
    _playlistItems = new List<PlaylistItem>();

    _initLists();

    _messageBus.subscribe(MessageNames.modelChanged, onModelChanged);
    _sortMode = SortMode.TITLE;
  }

  void _initLists() {
    _musicItems.clear();
    _artistItems.clear();
    _albumItems.clear();
    _playlistItems.clear();
    
    _model.songs.sort((a, b) => a.name.compareTo(b.name));
    
    for (var music in _model.songs) {
      _musicItems.add(new MusicItem(
          music, _model.songs));
    }
    _musicItems.sort((a, b) => a.song.name.compareTo(b.song.name));
    
    _model.songsGroupedBySinger.forEach(_initArtistItem);
    _artistItems.sort((a, b) => a.artist.compareTo(b.artist));
    
    _model.songsGroupedByAlbum.forEach(_initAlbumItem);
    _albumItems.sort((a, b) => a.album.compareTo(b.album));
    
    for (var playlist in _model.playLists) {
      _playlistItems.add(new PlaylistItem(playlist));
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        new AppBar(
          title: new Text("Music List"),
          leading: new Container(
            margin: const EdgeInsets.fromLTRB(8.0, 8.0, 0.0, 8.0),
            child: Image.asset('resources/YAMPLogoLetter.png'),
          ),
        ),
        _buildHeader(),
        new Flexible(
          child: _buildList(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return new Container(
      color: Theme.of(context).primaryColor,
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Expanded(
            child: _getTitleButton(),
          ),
          new Expanded(
            child: _getArtistButton(),
          ),
          new Expanded(
            child: _getAlbumButton(),
          ),
          new Expanded(
            child: _getPlaylistButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    switch (_sortMode) {
      case SortMode.ARTISTS:
        return _buildArtistList();
      case SortMode.ALBUMS:
        return _buildAlbumList();
      case SortMode.PLAYLIST:
        return _buildPlaylistList();
      default:
        return _buildTitleList();
    }
  }

  Widget _buildTitleList() {
    return new GestureDetector(
      onTap: onListTap,
      child: new ListView.builder(
        itemBuilder: (_, int index) => _musicItems[index],
        itemCount: _musicItems.length,
      ),
    );
  }

  Widget _buildArtistList() {
    return new ListView.builder(
      itemBuilder: (_, int index) => _artistItems[index],
      itemCount: _artistItems.length,
    );
  }

  Widget _buildAlbumList() {
    return new ListView.builder(
      itemBuilder: (_, int index) => _albumItems[index],
      itemCount: _albumItems.length,
    );
  }

  Widget _buildPlaylistList() {
    return new ListView.builder(
      itemBuilder: (_, int index) => _playlistItems[index],
      itemCount: _playlistItems.length,
    );
  }

  void onSortByTitle() {
    setState(() {
      _musicItems.sort((a, b) => a.song.name.compareTo(b.song.name));
      _sortMode = SortMode.TITLE;
    });
  }

  void onSortByArtist() {
    setState(() {
      _musicItems.sort((a, b) => a.song.singer.compareTo(b.song.singer));
      _sortMode = SortMode.ARTISTS;
    });
  }

  void onSortByAlbum() {
    setState(() {
      _musicItems.sort((a, b) => a.song.album.compareTo(b.song.album));
      _sortMode = SortMode.ALBUMS;
    });
  }

  
  void onSortByPlaylists() {
    setState(() {
      _sortMode = SortMode.PLAYLIST;
    });
  }

  Widget _getTitleButton() {
    Color buttonColor;
    if (_sortMode == SortMode.TITLE) {
      buttonColor = Theme.of(context).accentColor;
    } else {
      buttonColor = Theme.of(context).primaryColor;
    }

    return new FlatButton(
      color: buttonColor,
      child:
          new Text('Titles', style: Theme.of(context).primaryTextTheme.button),
      onPressed: onSortByTitle,
    );
  }

  Widget _getArtistButton() {
    Color buttonColor;
    if (_sortMode == SortMode.ARTISTS) {
      buttonColor = Theme.of(context).accentColor;
    } else {
      buttonColor = Theme.of(context).primaryColor;
    }

    return new FlatButton(
      color: buttonColor,
      child:
          new Text('Artists', style: Theme.of(context).primaryTextTheme.button),
      onPressed: onSortByArtist,
    );
  }

  Widget _getAlbumButton() {
    Color buttonColor;
    if (_sortMode == SortMode.ALBUMS) {
      buttonColor = Theme.of(context).accentColor;
    } else {
      buttonColor = Theme.of(context).primaryColor;
    }

    return new FlatButton(
      color: buttonColor,
      child:
          new Text('Albums', style: Theme.of(context).primaryTextTheme.button),
      onPressed: onSortByAlbum,
    );
  }

  Widget _getPlaylistButton() {
    Color buttonColor;
    if (_sortMode == SortMode.PLAYLIST) {
      buttonColor = Theme.of(context).accentColor;
    } else {
      buttonColor = Theme.of(context).primaryColor;
    }

    return new FlatButton(
      color: buttonColor,
      child: new Text('Playlists',
          style: Theme.of(context).primaryTextTheme.button),
      onPressed: onSortByPlaylists,
    );
  }

  void _initArtistItem(String key, List<Song> value) {
    _artistItems.add(new ArtistItem(key, value));
  }

  void _initAlbumItem(String key, List<Song> value) {
    _albumItems.add(new AlbumItem(key, value));
  }

  void onListTap() {
    _model.currentPlaylist = _model.songs;
  }

  void onModelChanged(Message message) {
    if (mounted) {
      setState(() {
        _initLists();
      });
    }
  }
}

enum SortMode { TITLE, ARTISTS, ALBUMS, PLAYLIST }
