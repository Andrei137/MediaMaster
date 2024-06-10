import 'package:hive/hive.dart';
import 'media.dart';
import 'platform.dart';

// Don't change the number below (typeId).
// For information regarding what can be modified check out https://docs.hivedb.dev/#/custom-objects/generate_adapter
class MediaPlatform extends HiveObject {
  // Hive fields
  int mediaId;
  int platformId;

  // For ease of use
  Media? _media;
  Platform? _platform;

  MediaPlatform({required this.mediaId, required this.platformId});

  @override
  bool operator==(Object other) {
    if(runtimeType != other.runtimeType) {
      return false;
    }
    return mediaId == (other as MediaPlatform).mediaId && platform == other.platformId;
  }
  
  @override
  int get hashCode => Object.hash(mediaId, platformId);

  Media get media {
    if(_media == null) {
      Box<Media> box = Hive.box<Media>('media');
      for(int i = 0;i < box.length;++i) {
        if(mediaId == box.getAt(i)!.id) {
          _media = box.getAt(i);
        }
      }
      if(_media == null) {
        throw Exception("MediaPlatform of mediaId $mediaId and platformId $platformId does not have an associated Media object or mediaId value is wrong");
      }
    }
    return _media!;
  }

  Platform get platform {
    if(_platform == null) {
      Box<Platform> box = Hive.box<Platform>('platforms');
      for(int i = 0;i < box.length;++i) {
        if(platformId == box.getAt(i)!.id) {
          _platform = box.getAt(i);
        }
      }
      if(_platform == null) {
        throw Exception("MediaPlatform of mediaId $mediaId and platformId $platformId does not have an associated Platform object or platformId value is wrong");
      }
    }
    return _platform!;
  }
}

class MediaPlatformAdapter extends TypeAdapter<MediaPlatform> {
  @override
  final int typeId = 25;

  @override
  MediaPlatform read(BinaryReader reader) {
    return MediaPlatform(
      mediaId: reader.readInt(),
      platformId: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, MediaPlatform obj) {
    writer.writeInt(obj.mediaId);
    writer.writeInt(obj.platformId);
  }
}
