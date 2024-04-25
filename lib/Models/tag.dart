import 'package:hive/hive.dart';

// Don't change the numbers below (HiveType and HiveField).
// For information regarding what can be modified check out https://docs.hivedb.dev/#/custom-objects/generate_adapter
// HiveObject handles primary key automatically and allows relationships between objects
@HiveType(typeId: 14)
class Tag extends HiveObject {
  @HiveField(0)
  String name;

  Tag({required this.name});

  @override
  String toString() {
    return "(Tag name: $name)";
  }
}

class TagAdapter extends TypeAdapter<Tag> {
  @override
  final int typeId = 14;

  @override
  Tag read(BinaryReader reader) {
    return Tag(
      name: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Tag obj) {
    writer.writeString(obj.name);
  }
}
