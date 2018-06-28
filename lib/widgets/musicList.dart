import 'package:dart_message_bus/dart_message_bus.dart';
import 'package:flutter/material.dart';

import 'musicItem.dart';
import 'artistItem.dart';
import 'albumItem.dart';
import '../models/song.dart';
import '../models/ApplicationModel.dart';
import '../controllers/AudioController.dart';

class MusicList extends StatefulWidget {
  final ApplicationModel _model;
  final AudioController _audioController;
  final MessageBus _messageBus;

  MusicList(this._model, this._audioController, this._messageBus);

  @override
  State<StatefulWidget> createState() {
    return MusicListState(this._model, this._audioController, this._messageBus);
  }
}

class MusicListState extends State<MusicList> {
  final ApplicationModel _model;
  final AudioController _audioController;
  final MessageBus _messageBus;

  List<MusicItem> _musicItems;
  List<ArtistItem> _artistItems;
  List<AlbumItem> _albumItems;
  SortMode _sortMode;

  MusicListState(this._model, this._audioController, this._messageBus) {
    _musicItems = new List<MusicItem>();
    _artistItems = new List<ArtistItem>();
    _albumItems = new List<AlbumItem>();

    _model.songs.sort((a, b) => a.name.compareTo(b.name));
    
    for (var music in _model.songs) {
      _musicItems
          .add(new MusicItem(music, _model.songs, _audioController.changeMusic, _messageBus));
    }
    _musicItems.sort((a, b) => a.song.name.compareTo(b.song.name));

    _model.songsGroupedBySinger.forEach(_initArtistItem);
    _artistItems.sort((a, b) => a.artist.compareTo(b.artist));

    _model.songsGroupedByAlbum.forEach(_initAlbumItem);
    _albumItems.sort((a, b) => a.album.compareTo(b.album));

    _sortMode = SortMode.TITLE;
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
        new Container(
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
            ],
          ),
        ),
        new Flexible(
          child: _buildList(),
        ),
      ],
    );
  }

  Widget _buildList() {
    switch (_sortMode) {
      case SortMode.ARTISTS:
        return _buildArtistList();
      case SortMode.ALBUMS:
        return _buildAlbumList();
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

  void _initArtistItem(String key, List<Song> value) {
    _artistItems.add(new ArtistItem(key, value, _messageBus));
  }

  void _initAlbumItem(String key, List<Song> value) {
    _albumItems.add(new AlbumItem(key, value, _messageBus));
  }

  void onListTap() {
    _model.currentPlaylist = _model.songs;
  }
}

enum SortMode { TITLE, ARTISTS, ALBUMS }
