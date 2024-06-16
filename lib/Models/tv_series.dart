import 'package:hive/hive.dart';
import 'media.dart';

class TvSeries extends HiveObject {
  // Hive fields
  int id;
  int mediaId;
  String originalLanguage;

  // For ease of use
  Media? _media;

  // Automatic id generator
  static int nextId = 0;

  TvSeries(
      {this.id = -1, required this.mediaId, required this.originalLanguage}) {
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
    return id == (other as TvSeries).id;
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
            "TvSeries of id $id does not have an associated Media object or mediaId value is wrong ($mediaId)");
      }
    }
    return _media!;
  }
}

class TvSeriesAdapter extends TypeAdapter<TvSeries> {
  @override
  final int typeId = 11;

  @override
  TvSeries read(BinaryReader reader) {
    return TvSeries(
      id: reader.readInt(),
      mediaId: reader.readInt(),
      originalLanguage: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, TvSeries obj) {
    writer.writeInt(obj.id);
    writer.writeInt(obj.mediaId);
    writer.writeString(obj.originalLanguage);
  }
}
