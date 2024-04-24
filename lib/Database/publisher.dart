import 'package:hive/hive.dart';

// Don't change the numbers below (HiveType and HiveField).
// For information regarding what can be modified check out https://docs.hivedb.dev/#/custom-objects/generate_adapter
// HiveObject handles primary key automatically and allows relationships between objects
@HiveType(typeId: 20)
class Publisher extends HiveObject {
  @HiveField(0)
  String name;

  Publisher({required this.name});

  @override
  String toString() {
    return "(Name: name)";
  }
}

class ClassNameAdapter extends TypeAdapter<Publisher> {
  @override
  final int typeId = 20;

  @override
  Publisher read(BinaryReader reader) {
    return Publisher(
      name: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Publisher obj) {
    writer.writeString(obj.name);
  }
}