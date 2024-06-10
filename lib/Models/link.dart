import 'package:hive/hive.dart';

// Don't change the number below (typeId).
// For information regarding what can be modified check out https://docs.hivedb.dev/#/custom-objects/generate_adapter
class Link extends HiveObject {
  // Hive fields
  int id;
  String name;
  String href;

  // Automatic id generator
  static int nextId = 0;

  Link(
      {this.id = -1,
      required this.name,
      required this.href}) {
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
    return id == (other as Link).id;
  }
  
  @override
  int get hashCode => id;
}

class LinkAdapter extends TypeAdapter<Link> {
  @override
  final int typeId = 26;

  @override
  Link read(BinaryReader reader) {
    return Link(
      id: reader.readInt(),
      name: reader.readString(),
      href: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Link obj) {
    writer.writeInt(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.href);
  }
}
