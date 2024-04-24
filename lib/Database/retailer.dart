import 'package:hive/hive.dart';

// Don't change the numbers below (HiveType and HiveField).
// For information regarding what can be modified check out https://docs.hivedb.dev/#/custom-objects/generate_adapter
// HiveObject handles primary key automatically and allows relationships between objects
@HiveType(typeId: 18)
class Retailer extends HiveObject {
  @HiveField(0)
  String name;

  Retailer({required this.name});

  @override
  String toString() {
    return "(Retailer name: $name)";
  }
}

class RetailerAdapter extends TypeAdapter<Retailer> {
  @override
  final int typeId = 18;

  @override
  Retailer read(BinaryReader reader) {
    return Retailer(
      name: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Retailer obj) {
    writer.writeString(obj.name);
  }
}
