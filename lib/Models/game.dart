import 'package:hive/hive.dart';
import 'media.dart';

// Don't change the number below (typeId).
// For information regarding what can be modified check out https://docs.hivedb.dev/#/custom-objects/generate_adapter
class Game extends HiveObject {
  // Hive fields
  int mediaId;
  int id;
  int parentGameId;
  String OSMinimum;
  String OSRecommended;
  String CPUMinimum;
  String CPURecommended;
  String RAMMinimum;
  String RAMRecommended;
  String HDDMinimum;
  String HDDRecommended;
  String GPUMinimum;
  String GPURecommended;
  int HLTBMainInSeconds;
  int HLTBMainSideInSeconds;
  int HLTBCompletionistInSeconds;
  int HLTBAllStylesInSeconds;
  int HLTBSoloInSeconds;
  int HLTBCoopInSeconds;
  int HLTBVersusInSeconds;
  int HLTBSingleplayerInSeconds;

  // For ease of use
  Media? _media;
  Game? _parentGame;

  // Automatic id generator
  static int nextId = 0;

  Game(
      {this.id = -1,
      required this.mediaId,
      this.parentGameId = -1,
      required this.OSMinimum,
      required this.OSRecommended,
      required this.CPUMinimum,
      required this.CPURecommended,
      required this.RAMMinimum,
      required this.RAMRecommended,
      required this.HDDMinimum,
      required this.HDDRecommended,
      required this.GPUMinimum,
      required this.GPURecommended,
      this.HLTBMainInSeconds = -1,
      this.HLTBMainSideInSeconds = -1,
      this.HLTBCompletionistInSeconds = -1,
      this.HLTBAllStylesInSeconds = -1,
      this.HLTBSoloInSeconds = -1,
      this.HLTBCoopInSeconds = -1,
      this.HLTBVersusInSeconds = -1,
      this.HLTBSingleplayerInSeconds = -1}) {
        if(id == -1) {
          id = nextId;
        }
        if(id >= nextId) {
          nextId = id + 1;
        }
      }

  @override
  bool operator==(Object other) {
    if(runtimeType != other.runtimeType) {
      return false;
    }
    return id == (other as Game).id;
  }
  
  @override
  int get hashCode => id;

  Media get media {
    if(_media == null) {
      Box<Media> box = Hive.box<Media>('media');
      for(int i = 0;i < box.length;++i) {
        if(mediaId == box.getAt(i)!.id) {
          _media = box.getAt(i);
        }
      }
      if(_media == null) {
        throw Exception("Game of id $id does not have an associated Media object or mediaId value is wrong ($mediaId)");
      }
    }
    return _media!;
  }

  Game? get parentGame {
    if(parentGameId == -1) {
      return null;
    }
    if(_parentGame == null) {
      Box<Game> box = Hive.box<Game>('games');
      for(int i = 0;i < box.length;++i) {
        if(parentGameId == box.getAt(i)!.id) {
          _parentGame = box.getAt(i);
        }
      }
      if(_parentGame == null) {
        throw Exception("Game of id $id does not have an associated Parent Game object or gameId value is wrong ($parentGameId)");
      }
    }
    return _parentGame!;
  }

  int getMinTimeToBeat() {
    List<int> times = List.from([HLTBAllStylesInSeconds, HLTBCompletionistInSeconds, HLTBCoopInSeconds, HLTBMainInSeconds, HLTBMainSideInSeconds, HLTBSingleplayerInSeconds, HLTBSoloInSeconds, HLTBVersusInSeconds]);
    int minTime = -1;

    for(int time in times) {
      if(minTime == -1 || minTime > time) {
        minTime = time;
      }
    }

    return minTime;
  }
}

class GameAdapter extends TypeAdapter<Game> {
  @override
  final int typeId = 7;

  @override
  Game read(BinaryReader reader) {
    return Game(
      id: reader.readInt(),
      mediaId: reader.readInt(),
      parentGameId: reader.readInt(),
      OSMinimum: reader.readString(),
      OSRecommended: reader.readString(),
      CPUMinimum: reader.readString(),
      CPURecommended: reader.readString(),
      RAMMinimum: reader.readString(),
      RAMRecommended: reader.readString(),
      HDDMinimum: reader.readString(),
      HDDRecommended: reader.readString(),
      GPUMinimum: reader.readString(),
      GPURecommended: reader.readString(),
      HLTBMainInSeconds: reader.readInt(),
      HLTBMainSideInSeconds: reader.readInt(),
      HLTBCompletionistInSeconds: reader.readInt(),
      HLTBAllStylesInSeconds: reader.readInt(),
      HLTBSoloInSeconds: reader.readInt(),
      HLTBCoopInSeconds: reader.readInt(),
      HLTBVersusInSeconds: reader.readInt(),
      HLTBSingleplayerInSeconds: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, Game obj) {
    writer.writeInt(obj.id);
    writer.writeInt(obj.mediaId);
    writer.writeInt(obj.parentGameId);
    writer.writeString(obj.OSMinimum);
    writer.writeString(obj.OSRecommended);
    writer.writeString(obj.CPUMinimum);
    writer.writeString(obj.CPURecommended);
    writer.writeString(obj.RAMMinimum);
    writer.writeString(obj.RAMRecommended);
    writer.writeString(obj.HDDMinimum);
    writer.writeString(obj.HDDRecommended);
    writer.writeString(obj.GPUMinimum);
    writer.writeString(obj.GPURecommended);
    writer.writeInt(obj.HLTBMainInSeconds);
    writer.writeInt(obj.HLTBMainSideInSeconds);
    writer.writeInt(obj.HLTBCompletionistInSeconds);
    writer.writeInt(obj.HLTBAllStylesInSeconds);
    writer.writeInt(obj.HLTBSoloInSeconds);
    writer.writeInt(obj.HLTBCoopInSeconds);
    writer.writeInt(obj.HLTBVersusInSeconds);
    writer.writeInt(obj.HLTBSingleplayerInSeconds);
  }
}
