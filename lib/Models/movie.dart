import 'package:hive/hive.dart';
import 'media.dart';

// Don't change the numbers below (HiveType and HiveField).
// For information regarding what can be modified check out https://docs.hivedb.dev/#/custom-objects/generate_adapter
// HiveObject handles primary key automatically and allows relationships between objects
@HiveType(typeId: 10)
class Movie extends HiveObject {
  @HiveField(0)
  Media media;

  @HiveField(1)
  String originalLanguage;

  @HiveField(2)
  int durationInseconds;

  Movie(
      {required this.media,
      required this.originalLanguage,
      required this.durationInseconds});

  @override
  String toString() {
    return "(Media: ${media.key}, originalLanguage: $originalLanguage, durationInseconds: $durationInseconds)";
  }
}

class MovieAdapter extends TypeAdapter<Movie> {
  @override
  final int typeId = 10;

  @override
  Movie read(BinaryReader reader) {
    return Movie(
      media: reader.read(),
      originalLanguage: reader.readString(),
      durationInseconds: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, Movie obj) {
    writer.write(obj.media);
    writer.writeString(obj.originalLanguage);
    writer.writeInt(obj.durationInseconds);
  }
}
