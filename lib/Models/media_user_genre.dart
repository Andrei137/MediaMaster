import 'package:hive/hive.dart';
import 'media.dart';
import 'user.dart';
import 'genre.dart';

class MediaUserGenre extends HiveObject {
  // Hive fields
  int mediaId;
  int userId;
  int genreId;

  // For ease of use
  Media? _media;
  User? _user;
  Genre? _genre;

  MediaUserGenre(
      {required this.mediaId, required this.userId, required this.genreId});

  @override
  bool operator ==(Object other) {
    if (runtimeType != other.runtimeType) {
      return false;
    }
    return mediaId == (other as MediaUserGenre).mediaId &&
        userId == other.userId &&
        genreId == other.genreId;
  }

  @override
  int get hashCode => Object.hash(mediaId, userId, genreId);

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
            "MediaUserGenre of mediaId $mediaId, userId $userId and genreId $genreId does not have an associated Media object or mediaId value is wrong");
      }
    }
    return _media!;
  }

  User get user {
    if (_user == null) {
      Box<User> box = Hive.box<User>('users');
      for (int i = 0; i < box.length; ++i) {
        if (userId == box.getAt(i)!.id) {
          _user = box.getAt(i);
        }
      }
      if (_user == null) {
        throw Exception(
            "MediaUserGenre of mediaId $mediaId, userId $userId and genreId $genreId does not have an associated User object or userId value is wrong");
      }
    }
    return _user!;
  }

  Genre get genre {
    if (_genre == null) {
      Box<Genre> box = Hive.box<Genre>('genres');
      for (int i = 0; i < box.length; ++i) {
        if (genreId == box.getAt(i)!.id) {
          _genre = box.getAt(i);
        }
      }
      if (_genre == null) {
        throw Exception(
            "MediaUserGenre of mediaId $mediaId, userId $userId and genreId $genreId does not have an associated Genre object or genreId value is wrong");
      }
    }
    return _genre!;
  }
}

class MediaUserGenreAdapter extends TypeAdapter<MediaUserGenre> {
  @override
  final int typeId = 17;

  @override
  MediaUserGenre read(BinaryReader reader) {
    return MediaUserGenre(
      mediaId: reader.readInt(),
      userId: reader.readInt(),
      genreId: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, MediaUserGenre obj) {
    writer.writeInt(obj.mediaId);
    writer.writeInt(obj.userId);
    writer.writeInt(obj.genreId);
  }
}
