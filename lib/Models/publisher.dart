import 'package:hive/hive.dart';

// Don't change the number below (typeId).
// For information regarding what can be modified check out https://docs.hivedb.dev/#/custom-objects/generate_adapter
class Publisher extends HiveObject {
  // Hive fields
  int id;
  String name;

  // Automatic id generator
  static int nextId = 0;

  Publisher(
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
    return id == (other as Publisher).id;
  }
  
  @override
  int get hashCode => id;
}

class PublisherAdapter extends TypeAdapter<Publisher> {
  @override
  final int typeId = 20;

  @override
  Publisher read(BinaryReader reader) {
    return Publisher(
      id: reader.readInt(),
      name: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Publisher obj) {
    writer.writeInt(obj.id);
    writer.writeString(obj.name);
  }
}
