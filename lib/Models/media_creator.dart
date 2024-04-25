import 'package:hive/hive.dart';
import 'media.dart';
import 'creator.dart';

// Don't change the numbers below (HiveType and HiveField).
// For information regarding what can be modified check out https://docs.hivedb.dev/#/custom-objects/generate_adapter
// HiveObject handles primary key automatically and allows relationships between objects
@HiveType(typeId: 23)
class MediaCreator extends HiveObject {
  @HiveField(0)
  Media media;

  @HiveField(1)
  Creator creator;

  MediaCreator({required this.media, required this.creator});

  @override
  String toString() {
    return "(Media: ${media.key}, creator: ${creator.key})";
  }
}

class MediaCreatorAdapter extends TypeAdapter<MediaCreator> {
  @override
  final int typeId = 23;

  @override
  MediaCreator read(BinaryReader reader) {
    return MediaCreator(
      media: reader.read(),
      creator: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, MediaCreator obj) {
    writer.write(obj.media);
    writer.write(obj.creator);
  }
}
