import 'package:hive/hive.dart';

// Don't change the numbers below (HiveType and HiveField).
// For information regarding what can be modified check out https://docs.hivedb.dev/#/custom-objects/generate_adapter
// HiveObject handles primary key automatically and allows relationships between objects
@HiveType(typeId: 26)
class Link extends HiveObject {
  @HiveField(0)
  String name;

  Link({required this.name});

  @override
  String toString() {
    return "(Name: $name)";
  }
}

class LinkAdapter extends TypeAdapter<Link> {
  @override
  final int typeId = 26;

  @override
  Link read(BinaryReader reader) {
    return Link(
      name: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Link obj) {
    writer.writeString(obj.name);
  }
}
