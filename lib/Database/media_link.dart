import 'package:hive/hive.dart';
import 'media.dart';
import 'link.dart';

// Don't change the numbers below (HiveType and HiveField).
// For information regarding what can be modified check out https://docs.hivedb.dev/#/custom-objects/generate_adapter
// HiveObject handles primary key automatically and allows relationships between objects
@HiveType(typeId: 27)
class MediaLink extends HiveObject {
  @HiveField(0)
  Media media;

  @HiveField(1)
  Link link;

  MediaLink({required this.media, required this.link});

  @override
  String toString() {
    return "(Media: ${media.key}, link: ${link.key})";
  }
}

class MediaLinkAdapter extends TypeAdapter<MediaLink> {
  @override
  final int typeId = 27;

  @override
  MediaLink read(BinaryReader reader) {
    return MediaLink(
      media: reader.read(),
      link: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, MediaLink obj) {
    writer.write(obj.media);
    writer.write(obj.link);
  }
}
