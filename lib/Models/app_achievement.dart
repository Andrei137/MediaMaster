import 'package:hive/hive.dart';

class AppAchievement extends HiveObject {
  // Hive fields
  int id;
  String name;
  String description;
  int xp;

  // Automatic id generator
  static int nextId = 0;

  AppAchievement(
      {this.id = -1,
      required this.name,
      required this.description,
      this.xp = 100}) {
    if (id == -1) {
      id = nextId;
    }
    if (id >= nextId) {
      nextId = id + 1;
    }
  }

  @override
  bool operator ==(Object other) {
    if (runtimeType != other.runtimeType) {
      return false;
    }
    return id == (other as AppAchievement).id;
  }

  @override
  int get hashCode => id;
}

class AppAchievementAdapter extends TypeAdapter<AppAchievement> {
  @override
  final int typeId = 1;

  @override
  AppAchievement read(BinaryReader reader) {
    return AppAchievement(
      id: reader.readInt(),
      name: reader.readString(),
      description: reader.readString(),
      xp: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, AppAchievement obj) {
    writer.writeInt(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.description);
    writer.writeInt(obj.xp);
  }
}
