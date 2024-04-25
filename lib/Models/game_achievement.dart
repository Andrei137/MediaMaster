import 'package:hive/hive.dart';
import 'game.dart';

// Don't change the numbers below (HiveType and HiveField).
// For information regarding what can be modified check out https://docs.hivedb.dev/#/custom-objects/generate_adapter
// HiveObject handles primary key automatically and allows relationships between objects
@HiveType(typeId: 8)
class GameAchievement extends HiveObject {
  @HiveField(0)
  Game game;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  GameAchievement(
      {required this.game, required this.name, required this.description});

  @override
  String toString() {
    return "(Game: ${game.key}, name: $name, description: $description)";
  }
}

class GameAchievementAdapter extends TypeAdapter<GameAchievement> {
  @override
  final int typeId = 8;

  @override
  GameAchievement read(BinaryReader reader) {
    return GameAchievement(
      game: reader.read(),
      name: reader.readString(),
      description: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, GameAchievement obj) {
    writer.write(obj.game);
    writer.writeString(obj.name);
    writer.writeString(obj.description);
  }
}
