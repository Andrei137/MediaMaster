import 'package:hive/hive.dart';
import 'media.dart';
import 'user.dart';
import 'genre.dart';

// Don't change the numbers below (HiveType and HiveField).
// For information regarding what can be modified check out https://docs.hivedb.dev/#/custom-objects/generate_adapter
// HiveObject handles primary key automatically and allows relationships between objects
@HiveType(typeId: 17)
class MediaUserGenre extends HiveObject {
  @HiveField(0)
  Media media;

  @HiveField(1)
  User user;

  @HiveField(2)
  Genre genre;

  MediaUserGenre({required this.media, required this.user, required this.genre});

  @override
  String toString() {
    return "(Media: {$media}, user: {$user}, genre: {$genre})";
  }
}

class MediaUserGenreAdapter extends TypeAdapter<MediaUserGenre> {
  @override
  final int typeId = 17;

  @override
  MediaUserGenre read(BinaryReader reader) {
    return MediaUserGenre(
      media: reader.read(),
      user: reader.read(),
      genre: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, MediaUserGenre obj) {
    writer.write(obj.media);
    writer.write(obj.user);
    writer.write(obj.genre);
  }
}