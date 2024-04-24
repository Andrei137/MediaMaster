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
  String OS;

  @HiveField(3)
  String CPUMinimum;

  @HiveField(4)
  String CPURecommended;

  @HiveField(5)
  String RAMMinimum;

  @HiveField(6)
  String RAMRecommended;

  @HiveField(7)
  String HDDMinimum;

  @HiveField(8)
  String HDDRecommended;

  @HiveField(9)
  String GPUMinimum;

  @HiveField(10)
  String GPURecommended;

  @HiveField(11)
  int HLTBMainInSeconds;

  @HiveField(12)
  int HLTBMainSideInSeconds;

  @HiveField(13)
  int HLTBCompletionistInSeconds;

  @HiveField(14)
  int HLTBAllStylesInSeconds;

  @HiveField(15)
  int HLTBSoloInSeconds;

  @HiveField(16)
  int HLTBCoopInSeconds;

  @HiveField(17)
  int HLTBVersusInSeconds;

  @HiveField(18)
  int HLTBSingleplayerInSeconds;

  Game(
      {required this.media,
      required this.OS,
      required this.CPUMinimum,
      required this.CPURecommended,
      required this.RAMMinimum,
      required this.RAMRecommended,
      required this.HDDMinimum,
      required this.HDDRecommended,
      required this.GPUMinimum,
      required this.GPURecommended,
      required this.HLTBMainInSeconds,
      required this.HLTBMainSideInSeconds,
      required this.HLTBCompletionistInSeconds,
      required this.HLTBAllStylesInSeconds,
      required this.HLTBSoloInSeconds,
      required this.HLTBCoopInSeconds,
      required this.HLTBVersusInSeconds,
      required this.HLTBSingleplayerInSeconds,
      this.parentGame});

  @override
  String toString() {
    return "(Media: ${media.key}, OS: $OS, HLTBMainInSeconds: $HLTBMainInSeconds)";
  }
}

class GameAdapter extends TypeAdapter<Game> {
  @override
  final int typeId = 7;

  @override
  Game read(BinaryReader reader) {
    return Game(
      media: reader.read(),
      OS: reader.readString(),
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
    writer.writeString(obj.OS);
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
