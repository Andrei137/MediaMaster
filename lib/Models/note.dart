import 'package:hive/hive.dart';
import 'media.dart';
import 'user.dart';

// Don't change the number below (typeId).
// For information regarding what can be modified check out https://docs.hivedb.dev/#/custom-objects/generate_adapter
class Note extends HiveObject {
  // Hive fields
  int mediaId;
  int userId;
  String content;
  DateTime creationDate = DateTime.now();
  DateTime modifiedDate = DateTime.now();

  // For ease of use
  Media? _media;
  User? _user;

  Note({required this.mediaId, required this.userId, required this.content});

  @override
  bool operator==(Object other) {
    if(runtimeType != other.runtimeType) {
      return false;
    }
    return userId == (other as Note).userId && mediaId == other.mediaId;
  }
  
  @override
  int get hashCode => Object.hash(mediaId, userId);

  User get user {
    if(_user == null) {
      Box<User> box = Hive.box<User>('users');
      for(int i = 0;i < box.length;++i) {
        if(userId == box.getAt(i)!.id) {
          _user = box.getAt(i);
        }
      }
      if(_user == null) {
        throw Exception("Note of userId $userId and mediaId $mediaId does not have an associated User object or userId value is wrong");
      }
    }
    return _user!;
  }

  Media get media {
    if(_media == null) {
      Box<Media> box = Hive.box<Media>('media');
      for(int i = 0;i < box.length;++i) {
        if(mediaId == box.getAt(i)!.id) {
          _media = box.getAt(i);
        }
      }
      if(_media == null) {
        throw Exception("Note of userId $userId and mediaId $mediaId does not have an associated Media object or mediaId value is wrong");
      }
    }
    return _media!;
  }
}

class NoteAdapter extends TypeAdapter<Note> {
  @override
  final int typeId = 5;

  @override
  Note read(BinaryReader reader) {
    return Note(
      mediaId: reader.readInt(),
      userId: reader.readInt(),
      content: reader.readString(),
    )
      ..creationDate = reader.read()
      ..modifiedDate = reader.read();
  }

  @override
  void write(BinaryWriter writer, Note obj) {
    writer.write(obj.mediaId);
    writer.write(obj.userId);
    writer.writeString(obj.content);
    writer.write(obj.creationDate);
    writer.write(obj.modifiedDate);
  }
}
