import 'package:hive/hive.dart';
import 'tv_series.dart';

// Don't change the number below (typeId).
// For information regarding what can be modified check out https://docs.hivedb.dev/#/custom-objects/generate_adapter
class Season extends HiveObject {
  // Hive fields
  int id;
  int tvSeriesId;
  String name;
  String coverImage;

  // For ease of use
  TvSeries? _tvSeries;

  // Automatic id generator
  static int nextId = 0;

  Season(
      {this.id = -1,
      required this.tvSeriesId,
      required this.name,
      required this.coverImage}) {
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
    return id == (other as TvSeries).id;
  }
  
  @override
  int get hashCode => id;

  TvSeries get tvSeries {
    if(_tvSeries == null) {
      Box<TvSeries> box = Hive.box<TvSeries>('tvSeries');
      for(int i = 0;i < box.length;++i) {
        if(tvSeriesId == box.getAt(i)!.id) {
          _tvSeries = box.getAt(i);
        }
      }
      if(_tvSeries == null) {
        throw Exception("Season of id $id does not have an associated TvSeries object or tvSeriesId value is wrong ($tvSeriesId)");
      }
    }
    return _tvSeries!;
  }
}

class SeasonAdapter extends TypeAdapter<Season> {
  @override
  final int typeId = 12;

  @override
  Season read(BinaryReader reader) {
    return Season(
      id: reader.readInt(),
      tvSeriesId: reader.readInt(),
      name: reader.readString(),
      coverImage: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Season obj) {
    writer.writeInt(obj.id);
    writer.writeInt(obj.tvSeriesId);
    writer.writeString(obj.name);
    writer.writeString(obj.coverImage);
  }
}
