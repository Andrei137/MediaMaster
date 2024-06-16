import 'package:hive/hive.dart';

class Genre extends HiveObject {
  // Hive fields
  int id;
  String name;

  // Automatic id generator
  static int nextId = 0;

  Genre({this.id = -1, required this.name}) {
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
    return id == (other as Genre).id;
  }

  @override
  int get hashCode => id;
}

class GenreAdapter extends TypeAdapter<Genre> {
  @override
  final int typeId = 16;

  @override
  Genre read(BinaryReader reader) {
    return Genre(
      id: reader.readInt(),
      name: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Genre obj) {
    writer.writeInt(obj.id);
    writer.writeString(obj.name);
  }
}
