import 'package:hive/hive.dart';
import 'media.dart';
import 'creator.dart';

// Don't change the number below (typeId).
// For information regarding what can be modified check out https://docs.hivedb.dev/#/custom-objects/generate_adapter
class MediaCreator extends HiveObject {
  // Hive fields
  int mediaId;
  int creatorId;

  // For ease of use
  Media? _media;
  Creator? _creator;

  MediaCreator({required this.mediaId, required this.creatorId});

  @override
  bool operator==(Object other) {
    if(runtimeType != other.runtimeType) {
      return false;
    }
    return mediaId == (other as MediaCreator).mediaId && creatorId == other.creatorId;
  }
  
  @override
  int get hashCode => Object.hash(mediaId, creatorId);

  Media get media {
    if(_media == null) {
      Box<Media> box = Hive.box<Media>('media');
      for(int i = 0;i < box.length;++i) {
        if(mediaId == box.getAt(i)!.id) {
          _media = box.getAt(i);
        }
      }
      if(_media == null) {
        throw Exception("MediaCreator of mediaId $mediaId and creatorId $creatorId does not have an associated Media object or mediaId value is wrong");
      }
    }
    return _media!;
  }

  Creator get creator {
    if(_creator == null) {
      Box<Creator> box = Hive.box<Creator>('creators');
      for(int i = 0;i < box.length;++i) {
        if(creatorId == box.getAt(i)!.id) {
          _creator = box.getAt(i);
        }
      }
      if(_creator == null) {
        throw Exception("MediaCreator of mediaId $mediaId and creatorId $creatorId does not have an associated Creator object or creatorId value is wrong");
      }
    }
    return _creator!;
  }
}

class MediaCreatorAdapter extends TypeAdapter<MediaCreator> {
  @override
  final int typeId = 23;

  @override
  MediaCreator read(BinaryReader reader) {
    return MediaCreator(
      mediaId: reader.readInt(),
      creatorId: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, MediaCreator obj) {
    writer.writeInt(obj.mediaId);
    writer.writeInt(obj.creatorId);
  }
}
