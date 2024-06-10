import 'package:hive/hive.dart';
import 'media.dart';
import 'link.dart';

// Don't change the number below (typeId).
// For information regarding what can be modified check out https://docs.hivedb.dev/#/custom-objects/generate_adapter
class MediaLink extends HiveObject {
  // Hive fields
  int mediaId;
  int linkId;
  
  // For ease of use
  Media? _media;
  Link? _link;

  MediaLink({required this.mediaId, required this.linkId});

  @override
  bool operator==(Object other) {
    if(runtimeType != other.runtimeType) {
      return false;
    }
    return mediaId == (other as MediaLink).mediaId && linkId == other.linkId;
  }
  
  @override
  int get hashCode => Object.hash(mediaId, linkId);

  Media get media {
    if(_media == null) {
      Box<Media> box = Hive.box<Media>('media');
      for(int i = 0;i < box.length;++i) {
        if(mediaId == box.getAt(i)!.id) {
          _media = box.getAt(i);
        }
      }
      if(_media == null) {
        throw Exception("MediaLink of mediaId $mediaId and linkId $linkId does not have an associated Media object or mediaId value is wrong");
      }
    }
    return _media!;
  }

  Link get link {
    if(_link == null) {
      Box<Link> box = Hive.box<Link>('links');
      for(int i = 0;i < box.length;++i) {
        if(linkId == box.getAt(i)!.id) {
          _link = box.getAt(i);
        }
      }
      if(_link == null) {
        throw Exception("MediaLink of mediaId $mediaId and linkId $linkId does not have an associated Link object or linkId value is wrong");
      }
    }
    return _link!;
  }
}

class MediaLinkAdapter extends TypeAdapter<MediaLink> {
  @override
  final int typeId = 27;

  @override
  MediaLink read(BinaryReader reader) {
    return MediaLink(
      mediaId: reader.readInt(),
      linkId: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, MediaLink obj) {
    writer.writeInt(obj.mediaId);
    writer.writeInt(obj.linkId);
  }
}
