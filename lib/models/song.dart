class Song{
  String path;
  String name;
  String singer;

  Song(this.path, this.name, this.singer);

  Song.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        path = json['path'],
        singer = json['singer'];

  Map<String, dynamic> toJson() =>
    {
      'name': name,
      'path': path,
      'singer': singer,
    };
}