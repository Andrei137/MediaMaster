import 'package:hive/hive.dart';
import 'media.dart';
import 'user.dart';

// Don't change the number below (typeId).
// For information regarding what can be modified check out https://docs.hivedb.dev/#/custom-objects/generate_adapter
class Note extends HiveObject {
  // Hive fields
  int id;
  int mediaId;
  int userId;
  String content;
  DateTime creationDate = DateTime.now();
  DateTime modifiedDate = DateTime.now();

  // For ease of use
  Media? _media;
  User? _user;

  // Automatic id generator
  static int nextId = 0;

  Note(
      {this.id = -1,
      required this.mediaId,
      required this.userId,
      required this.content}) {
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
    return id == (other as Note).id;
  }
  
  @override
  int get hashCode => id;

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
      id: reader.readInt(),
      mediaId: reader.readInt(),
      userId: reader.readInt(),
      content: reader.readString(),
    )
      ..creationDate = reader.read()
      ..modifiedDate = reader.read();
  }

  @override
  void write(BinaryWriter writer, Note obj) {
    writer.writeInt(obj.id);
    writer.writeInt(obj.mediaId);
    writer.writeInt(obj.userId);
    writer.writeString(obj.content);
    writer.write(obj.creationDate);
    writer.write(obj.modifiedDate);
  }
}
