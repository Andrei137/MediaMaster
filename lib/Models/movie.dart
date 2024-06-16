import 'package:hive/hive.dart';
import 'media.dart';

class Movie extends HiveObject {
  // Hive fields
  int id;
  int mediaId;
  String originalLanguage;
  int durationInseconds;

  // For ease of use
  Media? _media;

  // Automatic id generator
  static int nextId = 0;

  Movie(
      {this.id = -1,
      required this.mediaId,
      required this.originalLanguage,
      required this.durationInseconds}) {
    if (id == -1) {
      id = nextId;
    }
    if (id >= nextId) {
      nextId = id + 1;
    }
  }

  @override
  bool operator ==(Object other) {
    if (runtimeType != other.runtimeType) {
      return false;
    }
    return id == (other as Movie).id;
  }

  @override
  int get hashCode => id;

  Media get media {
    if (_media == null) {
      Box<Media> box = Hive.box<Media>('media');
      for (int i = 0; i < box.length; ++i) {
        if (mediaId == box.getAt(i)!.id) {
          _media = box.getAt(i);
        }
      }
      if (_media == null) {
        throw Exception(
            "Movie of id $id does not have an associated Media object or mediaId value is wrong ($mediaId)");
      }
    }
    return _media!;
  }
}

class MovieAdapter extends TypeAdapter<Movie> {
  @override
  final int typeId = 10;

  @override
  Movie read(BinaryReader reader) {
    return Movie(
      id: reader.readInt(),
      mediaId: reader.readInt(),
      originalLanguage: reader.readString(),
      durationInseconds: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, Movie obj) {
    writer.writeInt(obj.id);
    writer.writeInt(obj.mediaId);
    writer.writeString(obj.originalLanguage);
    writer.writeInt(obj.durationInseconds);
  }
}
