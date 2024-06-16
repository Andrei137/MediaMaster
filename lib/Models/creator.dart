import 'package:hive/hive.dart';

class Creator extends HiveObject {
  // Hive fields
  int id;
  String name;

  // Automatic id generator
  static int nextId = 0;

  Creator({this.id = -1, required this.name}) {
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
    return id == (other as Creator).id;
  }

  @override
  int get hashCode => id;
}

class CreatorAdapter extends TypeAdapter<Creator> {
  @override
  final int typeId = 22;

  @override
  Creator read(BinaryReader reader) {
    return Creator(
      id: reader.readInt(),
      name: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Creator obj) {
    writer.writeInt(obj.id);
    writer.writeString(obj.name);
  }
}
