import 'package:hive/hive.dart';
import 'tv_series.dart';
import 'season.dart';
import 'media.dart';

// Don't change the numbers below (HiveType and HiveField).
// For information regarding what can be modified check out https://docs.hivedb.dev/#/custom-objects/generate_adapter
// HiveObject handles primary key automatically and allows relationships between objects
@HiveType(typeId: 13)
class Episode extends HiveObject {
  @HiveField(0)
  TvSeries tvSeries;

  @HiveField(1)
  Season season;

  @HiveField(2)
  Media media;

  @HiveField(3)
  int durationInSeconds;

  Episode(
      {required this.tvSeries,
      required this.season,
      required this.media,
      required this.durationInSeconds});

  @override
  String toString() {
    return "(TvSeries: ${tvSeries.key}, season: ${season.key}, media: ${media.key}, durationInSeconds: $durationInSeconds)";
  }
}

class EpisodeAdapter extends TypeAdapter<Episode> {
  @override
  final int typeId = 13;

  @override
  Episode read(BinaryReader reader) {
    return Episode(
      tvSeries: reader.read(),
      season: reader.read(),
      media: reader.read(),
      durationInSeconds: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, Episode obj) {
    writer.write(obj.tvSeries);
    writer.write(obj.season);
    writer.write(obj.media);
    writer.writeInt(obj.durationInSeconds);
  }
}
