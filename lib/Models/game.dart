import 'package:hive/hive.dart';
import 'media.dart';

// Don't change the numbers below (HiveType and HiveField).
// For information regarding what can be modified check out https://docs.hivedb.dev/#/custom-objects/generate_adapter
// HiveObject handles primary key automatically and allows relationships between objects
@HiveType(typeId: 7)
class Game extends HiveObject {
  @HiveField(0)
  Media media;

  @HiveField(1)
  Game? parentGame;

  @HiveField(2)
  String OSMinimum;

  @HiveField(3)
  String OSRecommended;

  @HiveField(4)
  String CPUMinimum;

  @HiveField(5)
  String CPURecommended;

  @HiveField(6)
  String RAMMinimum;

  @HiveField(7)
  String RAMRecommended;

  @HiveField(8)
  String HDDMinimum;

  @HiveField(9)
  String HDDRecommended;

  @HiveField(10)
  String GPUMinimum;

  @HiveField(11)
  String GPURecommended;

  @HiveField(12)
  int HLTBMainInSeconds;

  @HiveField(13)
  int HLTBMainSideInSeconds;

  @HiveField(14)
  int HLTBCompletionistInSeconds;

  @HiveField(15)
  int HLTBAllStylesInSeconds;

  @HiveField(16)
  int HLTBSoloInSeconds;

  @HiveField(17)
  int HLTBCoopInSeconds;

  @HiveField(18)
  int HLTBVersusInSeconds;

  @HiveField(19)
  int HLTBSingleplayerInSeconds;

  Game(
      {required this.media,
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
      this.HLTBSingleplayerInSeconds = -1,
      this.parentGame});

  @override
  String toString() {
    return "(Media: ${media.key}, OSRecommended: $OSRecommended, HLTBMainInSeconds: $HLTBMainInSeconds)";
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
      media: reader.read(),
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
      parentGame: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, Game obj) {
    writer.write(obj.media);
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
    writer.write(obj.parentGame);
  }
}
