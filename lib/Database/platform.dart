import 'package:hive/hive.dart';

// Don't change the numbers below (HiveType and HiveField).
// For information regarding what can be modified check out https://docs.hivedb.dev/#/custom-objects/generate_adapter
// HiveObject handles primary key automatically and allows relationships between objects
@HiveType(typeId: 24)
class Platform extends HiveObject {
  @HiveField(0)
  String name;

  Platform({required this.name});

  @override
  String toString() {
    return "(Name: $name)";
  }
}

class PlatformAdapter extends TypeAdapter<Platform> {
  @override
  final int typeId = 24;

  @override
  Platform read(BinaryReader reader) {
    return Platform(
      name: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Platform obj) {
    writer.writeString(obj.name);
  }
}
