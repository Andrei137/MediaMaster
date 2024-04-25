import 'package:hive/hive.dart';
import 'tv_series.dart';

// Don't change the numbers below (HiveType and HiveField).
// For information regarding what can be modified check out https://docs.hivedb.dev/#/custom-objects/generate_adapter
// HiveObject handles primary key automatically and allows relationships between objects
@HiveType(typeId: 12)
class Season extends HiveObject {
  @HiveField(0)
  TvSeries tvSeries;

  @HiveField(1)
  String name;

  @HiveField(2)
  String coverImage;

  Season(
      {required this.tvSeries, required this.name, required this.coverImage});

  @override
  String toString() {
    return "(TvSeries: ${tvSeries.key}, name: $name)";
  }
}

class SeasonAdapter extends TypeAdapter<Season> {
  @override
  final int typeId = 12;

  @override
  Season read(BinaryReader reader) {
    return Season(
      tvSeries: reader.read(),
      name: reader.readString(),
      coverImage: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Season obj) {
    writer.write(obj.tvSeries);
    writer.writeString(obj.name);
    writer.writeString(obj.coverImage);
  }
}
