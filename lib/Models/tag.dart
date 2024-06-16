import 'package:hive/hive.dart';

class Tag extends HiveObject {
  // Hive fields
  int id;
  String name;

  // Automatic id generator
  static int nextId = 0;

  Tag({this.id = -1, required this.name}) {
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
    return id == (other as Tag).id;
  }

  @override
  int get hashCode => id;
}

class TagAdapter extends TypeAdapter<Tag> {
  @override
  final int typeId = 14;

  @override
  Tag read(BinaryReader reader) {
    return Tag(
      id: reader.readInt(),
      name: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Tag obj) {
    writer.writeInt(obj.id);
    writer.writeString(obj.name);
  }
}
