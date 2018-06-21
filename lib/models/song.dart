class Song{
  String path;
  String name;
  String singer;
  String album;

  Song(this.path, this.name, this.singer, this.album);

  Song.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        path = json['path'],
        singer = json['singer'],
        album = json['album'];

  Map<String, dynamic> toJson() =>
    {
      'name': name,
      'path': path,
      'singer': singer,
      'album': album
    };
}