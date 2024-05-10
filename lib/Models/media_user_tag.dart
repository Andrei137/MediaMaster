import 'package:hive/hive.dart';
import 'media.dart';
import 'user.dart';
import 'tag.dart';

// Don't change the number below (typeId).
// For information regarding what can be modified check out https://docs.hivedb.dev/#/custom-objects/generate_adapter
class MediaUserTag extends HiveObject {
  // Hive fields
  int mediaId;
  int userId;
  int tagId;

  // For ease of use
  Media? _media;
  User? _user;
  Tag? _tag;

  MediaUserTag(
      {required this.mediaId,
      required this.userId,
      required this.tagId});

  @override
  bool operator==(Object other) {
    if(runtimeType != other.runtimeType) {
      return false;
    }
    return userId == (other as MediaUserTag).userId && mediaId == other.mediaId && tagId == other.tagId;
  }
  
  @override
  int get hashCode => Object.hash(mediaId, userId, tagId);

  Media get media {
    if(_media == null) {
      Box<Media> box = Hive.box<Media>('media');
      for(int i = 0;i < box.length;++i) {
        if(mediaId == box.getAt(i)!.id) {
          _media = box.getAt(i);
        }
      }
      if(_media == null) {
        throw Exception("MediaUserTag of mediaId $mediaId, userId $userId and tagId $tagId does not have an associated Media object or mediaId value is wrong");
      }
    }
    return _media!;
  }

  User get user {
    if(_user == null) {
      Box<User> box = Hive.box<User>('users');
      for(int i = 0;i < box.length;++i) {
        if(userId == box.getAt(i)!.id) {
          _user = box.getAt(i);
        }
      }
      if(_user == null) {
        throw Exception("MediaUserTag of mediaId $mediaId, userId $userId and tagId $tagId does not have an associated User object or userId value is wrong");
      }
    }
    return _user!;
  }

  Tag get tag {
    if(_tag == null) {
      Box<Tag> box = Hive.box<Tag>('tags');
      for(int i = 0;i < box.length;++i) {
        if(tagId == box.getAt(i)!.id) {
          _tag = box.getAt(i);
        }
      }
      if(_tag == null) {
        throw Exception("MediaUserTag of mediaId $mediaId, userId $userId and tagId $tagId does not have an associated Tag object or tagId value is wrong");
      }
    }
    return _tag!;
  }
}

class MediaUserTagAdapter extends TypeAdapter<MediaUserTag> {
  @override
  final int typeId = 15;

  @override
  MediaUserTag read(BinaryReader reader) {
    return MediaUserTag(
      mediaId: reader.readInt(),
      userId: reader.readInt(),
      tagId: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, MediaUserTag obj) {
    writer.writeInt(obj.mediaId);
    writer.writeInt(obj.userId);
    writer.writeInt(obj.tagId);
  }
}
