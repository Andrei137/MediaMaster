import 'package:hive/hive.dart';

// Don't change the numbers below (HiveType and HiveField).
// For information regarding what can be modified check out https://docs.hivedb.dev/#/custom-objects/generate_adapter
// HiveObject handles primary key automatically and allows relationships between objects
@HiveType(typeId: 1)
class AppAchievement extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String description;

  @HiveField(2)
  int xp;

  AppAchievement({required this.name, required this.description, this.xp = 100});

  @override
  String toString() {
    return "(Achievement name: $name, description: $description, xp: $xp)";
  }
}

class AppAchievementAdapter extends TypeAdapter<AppAchievement> {
  @override
  final int typeId = 1;

  @override
  AppAchievement read(BinaryReader reader) {
    return AppAchievement(
      name: reader.readString(),
      description: reader.readString(),
      xp: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, AppAchievement obj) {
    writer.writeString(obj.name);
    writer.writeString(obj.description);
    writer.writeInt(obj.xp);
  }
}