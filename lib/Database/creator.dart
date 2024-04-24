import 'package:hive/hive.dart';

// Don't change the numbers below (HiveType and HiveField).
// For information regarding what can be modified check out https://docs.hivedb.dev/#/custom-objects/generate_adapter
// HiveObject handles primary key automatically and allows relationships between objects
@HiveType(typeId: 22)
class Creator extends HiveObject {
  @HiveField(0)
  String name;

  Creator({required this.name});

  @override
  String toString() {
    return "(Name: $name)";
  }
}

class CreatorAdapter extends TypeAdapter<Creator> {
  @override
  final int typeId = 22;

  @override
  Creator read(BinaryReader reader) {
    return Creator(
      name: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Creator obj) {
    writer.writeString(obj.name);
  }
}
