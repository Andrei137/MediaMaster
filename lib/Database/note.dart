import 'package:hive/hive.dart';
import 'media.dart';
import 'user.dart';

// Don't change the numbers below (HiveType and HiveField).
// For information regarding what can be modified check out https://docs.hivedb.dev/#/custom-objects/generate_adapter
// HiveObject handles primary key automatically and allows relationships between objects
@HiveType(typeId: 5)
class Note extends HiveObject {
  @HiveField(0)
  Media media;

  @HiveField(1)
  User user;

  @HiveField(2)
  String content;

  @HiveField(3)
  DateTime creationDate = DateTime.now();

  @HiveField(4)
  DateTime modifiedDate = DateTime.now();

  Note({required this.media, required this.user, required this.content});

  @override
  String toString() {
    return "(Media: ${media.key}, user: ${user.username}, content: $content, creationDate: $creationDate, modifiedDate: $modifiedDate)";
  }
}

class NoteAdapter extends TypeAdapter<Note> {
  @override
  final int typeId = 5;

  @override
  Note read(BinaryReader reader) {
    return Note(
      media: reader.read(),
      user: reader.read(),
      content: reader.readString(),
    )
      ..creationDate = reader.read()
      ..modifiedDate = reader.read();
  }

  @override
  void write(BinaryWriter writer, Note obj) {
    writer.write(obj.media);
    writer.write(obj.user);
    writer.writeString(obj.content);
    writer.write(obj.creationDate);
    writer.write(obj.modifiedDate);
  }
}
