import 'package:hive/hive.dart';
import 'media.dart';
import 'user.dart';
import 'tag.dart';

// Don't change the numbers below (HiveType and HiveField).
// For information regarding what can be modified check out https://docs.hivedb.dev/#/custom-objects/generate_adapter
// HiveObject handles primary key automatically and allows relationships between objects
@HiveType(typeId: 15)
class MediaUserTag extends HiveObject {
  @HiveField(0)
  Media media;

  @HiveField(1)
  User user;

  @HiveField(2)
  Tag tag;

  MediaUserTag({required this.media, required this.user, required this.tag});

  @override
  String toString() {
    return "(Media: {$media}, user: {$user}, tag: {$tag})";
  }
}

class MediaUserTagAdapter extends TypeAdapter<MediaUserTag> {
  @override
  final int typeId = 15;

  @override
  MediaUserTag read(BinaryReader reader) {
    return MediaUserTag(
      media: reader.read(),
      user: reader.read(),
      tag: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, MediaUserTag obj) {
    writer.write(obj.media);
    writer.write(obj.user);
    writer.write(obj.tag);
  }
}