import 'package:hive/hive.dart';
import 'tv_series.dart';
import 'season.dart';
import 'media.dart';

class Episode extends HiveObject {
  // Hive fields
  int id;
  int tvSeriesId;
  int seasonId;
  int mediaId;
  int durationInSeconds;

  // For ease of use
  TvSeries? _tvSeries;
  Season? _season;
  Media? _media;

  // Automatic id generator
  static int nextId = 0;

  Episode(
      {this.id = -1,
      required this.tvSeriesId,
      required this.seasonId,
      this.mediaId = -1,
      required this.durationInSeconds}) {
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
    return id == (other as Episode).id;
  }

  @override
  int get hashCode => id;

  TvSeries get tvSeries {
    if (_tvSeries == null) {
      Box<TvSeries> box = Hive.box<TvSeries>('tvSeries');
      for (int i = 0; i < box.length; ++i) {
        if (tvSeriesId == box.getAt(i)!.id) {
          _tvSeries = box.getAt(i);
        }
      }
      if (_tvSeries == null) {
        throw Exception(
            "Episode of id $id does not have an associated Tv Series object or tvSeriesId value is wrong ($tvSeriesId)");
      }
    }
    return _tvSeries!;
  }

  Season get season {
    if (_season == null) {
      Box<Season> box = Hive.box<Season>('seasons');
      for (int i = 0; i < box.length; ++i) {
        if (tvSeriesId == box.getAt(i)!.id) {
          _season = box.getAt(i);
        }
      }
      if (_season == null) {
        throw Exception(
            "Episode of id $id does not have an associated Season object or seasonId value is wrong ($seasonId)");
      }
    }
    return _season!;
  }

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
            "Episode of id $id does not have an associated Media object or mediaId value is wrong ($mediaId)");
      }
    }
    return _media!;
  }
}

class EpisodeAdapter extends TypeAdapter<Episode> {
  @override
  final int typeId = 13;

  @override
  Episode read(BinaryReader reader) {
    return Episode(
      id: reader.readInt(),
      tvSeriesId: reader.readInt(),
      seasonId: reader.readInt(),
      mediaId: reader.readInt(),
      durationInSeconds: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, Episode obj) {
    writer.write(obj.id);
    writer.write(obj.tvSeriesId);
    writer.write(obj.seasonId);
    writer.write(obj.mediaId);
    writer.writeInt(obj.durationInSeconds);
  }
}
