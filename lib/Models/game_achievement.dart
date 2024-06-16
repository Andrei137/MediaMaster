import 'package:hive/hive.dart';
import 'game.dart';

class GameAchievement extends HiveObject {
  // Hive fields
  int id;
  int gameId;
  String name;
  String description;

  // For ease of use
  Game? _game;

  // Automatic id generator
  static int nextId = 0;

  GameAchievement(
      {this.id = -1,
      required this.gameId,
      required this.name,
      required this.description}) {
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
    return id == (other as GameAchievement).id;
  }

  @override
  int get hashCode => id;

  Game get game {
    if (_game == null) {
      Box<Game> box = Hive.box<Game>('games');
      for (int i = 0; i < box.length; ++i) {
        if (gameId == box.getAt(i)!.id) {
          _game = box.getAt(i);
        }
      }
      if (_game == null) {
        throw Exception(
            "Game Achievement of id $id does not have an associated Game object or gameId value is wrong ($gameId)");
      }
    }
    return _game!;
  }
}

class GameAchievementAdapter extends TypeAdapter<GameAchievement> {
  @override
  final int typeId = 8;

  @override
  GameAchievement read(BinaryReader reader) {
    return GameAchievement(
      id: reader.readInt(),
      gameId: reader.read(),
      name: reader.readString(),
      description: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, GameAchievement obj) {
    writer.writeInt(obj.id);
    writer.writeInt(obj.gameId);
    writer.writeString(obj.name);
    writer.writeString(obj.description);
  }
}
