import 'package:hive/hive.dart';

// Don't change the numbers below (HiveType and HiveField).
// For information regarding what can be modified check out https://docs.hivedb.dev/#/custom-objects/generate_adapter
// HiveObject handles primary key automatically and allows relationships between objects
@HiveType(typeId: 16)
class Genre extends HiveObject {
  @HiveField(0)
  String name;

  Genre({required this.name});

  @override
  String toString() {
    return "(Genre name: $name)";
  }
}

class GenreAdapter extends TypeAdapter<Genre> {
  @override
  final int typeId = 16;

  @override
  Genre read(BinaryReader reader) {
    return Genre(
      name: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Genre obj) {
    writer.writeString(obj.name);
  }
}
