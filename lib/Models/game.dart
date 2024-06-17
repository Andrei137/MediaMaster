import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

import 'media.dart';

class Game extends HiveObject {
  // Hive fields
  int mediaId;
  int id;
  int parentGameId;
  int IGDBId;
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
  int HLTBCoopInSeconds;
  int HLTBVersusInSeconds;

  // For ease of use
  Media? _media;
  Game? _parentGame;

  // Automatic id generator
  static int nextId = 0;

  Game({
    this.id = -1,
    required this.mediaId,
    this.parentGameId = -1,
    required this.IGDBId,
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
    this.HLTBCoopInSeconds = -1,
    this.HLTBVersusInSeconds = -1,
  }) {
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
    return id == (other as Game).id;
  }

  @override
  int get hashCode => id;

  Media get media {
    if (_media == null) {
      Box<Media> box = Hive.box<Media>('media');
      for (int i = 0; i < box.length; ++i) {
        if (mediaId == box.getAt(i)!.id) {
          _media = box.getAt(i);
        }
      }
      if (_media == null) {
        throw Exception(
            "Game of id $id does not have an associated Media object or mediaId value is wrong ($mediaId)");
      }
    }
    return _media!;
  }

  Game? get parentGame {
    if (parentGameId == -1) {
      return null;
    }
    if (_parentGame == null) {
      Box<Game> box = Hive.box<Game>('games');
      for (int i = 0; i < box.length; ++i) {
        if (parentGameId == box.getAt(i)!.id) {
          _parentGame = box.getAt(i);
        }
      }
      if (_parentGame == null) {
        throw Exception(
            "Game of id $id does not have an associated Parent Game object or gameId value is wrong ($parentGameId)");
      }
    }
    return _parentGame!;
  }

  int getMinTimeToBeat() {
    List<int> times = List.from([
      HLTBAllStylesInSeconds,
      HLTBCompletionistInSeconds,
      HLTBCoopInSeconds,
      HLTBMainInSeconds,
      HLTBMainSideInSeconds,
      HLTBVersusInSeconds
    ]);
    int minTime = -1;

    for (int time in times) {
      if (minTime == -1 || minTime > time) {
        minTime = time;
      }
    }

    return minTime;
  }

  Widget renderHLTB() {
    String formatTime(int timeInSeconds,
        {bool days = false, bool seconds = false}) {
      String daysStr = "";
      if (days && timeInSeconds >= 60 * 60 * 24) {
        daysStr =
            "${timeInSeconds ~/ (60 * 60 * 24)} day${timeInSeconds ~/ (60 * 60 * 24) > 1 ? 's' : ''}, ";
        timeInSeconds %= 60 * 60 * 24;
      }

      String hoursStr =
          "${timeInSeconds ~/ (60 * 60)} hour${timeInSeconds ~/ (60 * 60) > 1 ? 's' : ''}, ";
      timeInSeconds %= 60 * 60;

      String minutesStr =
          "${timeInSeconds ~/ 60} minute${timeInSeconds ~/ 60 > 1 ? 's' : ''}";
      timeInSeconds %= 60;

      String secondsStr = "";
      if (seconds && timeInSeconds != 0) {
        secondsStr = ", $timeInSeconds";
      }

      return "$daysStr$hoursStr$minutesStr$secondsStr";
    }

    Widget formatHLTBRow(String title, int timeInSeconds) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                title,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  formatTime(timeInSeconds),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (HLTBMainInSeconds > 0)
          formatHLTBRow(
            "Main: ",
            HLTBMainInSeconds,
          ),
        if (HLTBMainSideInSeconds > 0)
          formatHLTBRow(
            "Main + Side: ",
            HLTBMainSideInSeconds,
          ),
        if (HLTBCompletionistInSeconds > 0)
          formatHLTBRow(
            "Completionist: ",
            HLTBCompletionistInSeconds,
          ),
        if (HLTBAllStylesInSeconds > 0)
          formatHLTBRow(
            "All styles: ",
            HLTBAllStylesInSeconds,
          ),
        if (HLTBCoopInSeconds > 0)
          formatHLTBRow(
            "Coop: ",
            HLTBCoopInSeconds,
          ),
        if (HLTBVersusInSeconds > 0)
          formatHLTBRow(
            "Versus: ",
            HLTBVersusInSeconds,
          ),
      ],
    );
  }

  Widget renderPCGW() {
    Widget formatPCGWRow(String title, String details) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                title,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  details,
                  textAlign: TextAlign.left,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        formatPCGWRow(
          "OS minimum: ",
          OSMinimum,
        ),
        formatPCGWRow(
          "OS recommended: ",
          OSRecommended,
        ),
        formatPCGWRow(
          "CPU minimum: ",
          CPUMinimum,
        ),
        formatPCGWRow(
          "CPU recommended: ",
          CPURecommended,
        ),
        formatPCGWRow(
          "RAM minimum: ",
          RAMMinimum,
        ),
        formatPCGWRow(
          "RAM recommended: ",
          RAMRecommended,
        ),
        formatPCGWRow(
          "HDD minimum: ",
          HDDMinimum,
        ),
        formatPCGWRow(
          "HDD recommended: ",
          HDDRecommended,
        ),
        formatPCGWRow(
          "GPU minimum: ",
          GPUMinimum,
        ),
        formatPCGWRow(
          "GPU recommended: ",
          GPURecommended,
        ),
      ],
    );
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
      IGDBId: reader.readInt(),
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
      HLTBCoopInSeconds: reader.readInt(),
      HLTBVersusInSeconds: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, Game obj) {
    writer.writeInt(obj.id);
    writer.writeInt(obj.mediaId);
    writer.writeInt(obj.parentGameId);
    writer.writeInt(obj.IGDBId);
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
    writer.writeInt(obj.HLTBCoopInSeconds);
    writer.writeInt(obj.HLTBVersusInSeconds);
  }
}
