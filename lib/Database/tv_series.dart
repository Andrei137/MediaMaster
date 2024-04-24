import 'package:hive/hive.dart';
import 'media.dart';

// Don't change the numbers below (HiveType and HiveField).
// For information regarding what can be modified check out https://docs.hivedb.dev/#/custom-objects/generate_adapter
// HiveObject handles primary key automatically and allows relationships between objects
@HiveType(typeId: 11)
class TvSeries extends HiveObject {
  @HiveField(0)
  Media media;

  @HiveField(1)
  String originalLanguage;

  TvSeries({required this.media, required this.originalLanguage});

  @override
  String toString() {
    return "(Media: ${media.key}, originalLanguage: $originalLanguage)";
  }
}

class TvSeriesAdapter extends TypeAdapter<TvSeries> {
  @override
  final int typeId = 11;

  @override
  TvSeries read(BinaryReader reader) {
    return TvSeries(
      media: reader.read(),
      originalLanguage: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, TvSeries obj) {
    writer.write(obj.media);
    writer.writeString(obj.originalLanguage);
  }
}
