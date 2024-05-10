import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'game.dart';

// Don't change the number below (typeId).
// For information regarding what can be modified check out https://docs.hivedb.dev/#/custom-objects/generate_adapter
class Media extends HiveObject {
  // Hive fields
  int id;
  String originalName;
  String description;
  DateTime releaseDate;
  int criticScore;
  int communityScore;
  String mediaType;

  // For ease of use
  HiveObject? _media;

  // Automatic id generator
  static int nextId = 0;

  Media(
      {this.id = -1,
      required this.originalName,
      required this.description,
      required this.releaseDate,
      required this.criticScore,
      required this.communityScore,
      required this.mediaType}) {
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
    return id == (other as Media).id;
  }
  
  @override
  int get hashCode => id;

  HiveObject get media {
    if(_media == null) {
      if(mediaType == "Game") {
        Box<Game> box = Hive.box<Game>('games');
        for(int i = 0;i < box.length;++i) {
          if(id == box.getAt(i)!.mediaId) {
            _media = box.getAt(i);
          }
        }
      }
      // TODO: Implement the other types
      if(_media == null) {
        throw Exception("Media of id $id does not have an associated (concrete) Media object or mediaType value is wrong ($mediaType)");
      }
    }
    return _media!;
  }
}

class MediaAdapter extends TypeAdapter<Media> {
  @override
  final int typeId = 3;

  @override
  Media read(BinaryReader reader) {
    return Media(
      id: reader.readInt(),
      originalName: reader.readString(),
      description: reader.readString(),
      releaseDate: reader.read(),
      criticScore: reader.readInt(),
      communityScore: reader.readInt(),
      mediaType: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Media obj) {
    writer.writeInt(obj.id);
    writer.writeString(obj.originalName);
    writer.writeString(obj.description);
    writer.write(obj.releaseDate);
    writer.writeInt(obj.criticScore);
    writer.writeInt(obj.communityScore);
    writer.writeString(obj.mediaType);
  }
}
