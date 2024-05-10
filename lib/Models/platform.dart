import 'package:hive/hive.dart';

// Don't change the number below (typeId).
// For information regarding what can be modified check out https://docs.hivedb.dev/#/custom-objects/generate_adapter
class Platform extends HiveObject {
  // Hive fields
  int id;
  String name;

  // Automatic id generator
  static int nextId = 0;

  Platform(
      {this.id = -1,
      required this.name}) {
        if(id == -1) {
          id = nextId;
        }
        if(id >= nextId) {
          nextId = id + 1;
        }
      }

  @override
  bool operator==(Object other) {
    if(runtimeType != other.runtimeType) {
      return false;
    }
    return id == (other as Platform).id;
  }
  
  @override
  int get hashCode => id;
}

class PlatformAdapter extends TypeAdapter<Platform> {
  @override
  final int typeId = 24;

  @override
  Platform read(BinaryReader reader) {
    return Platform(
      id: reader.readInt(),
      name: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Platform obj) {
    writer.writeInt(obj.id);
    writer.writeString(obj.name);
  }
}
