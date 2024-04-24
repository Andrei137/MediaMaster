import 'package:hive/hive.dart';
import 'media.dart';
import 'publisher.dart';

// Don't change the numbers below (HiveType and HiveField).
// For information regarding what can be modified check out https://docs.hivedb.dev/#/custom-objects/generate_adapter
// HiveObject handles primary key automatically and allows relationships between objects
@HiveType(typeId: 21)
class MediaPublisher extends HiveObject {
  @HiveField(0)
  Media media;

  @HiveField(1)
  Publisher publisher;

  MediaPublisher({required this.media, required this.publisher});

  @override
  String toString() {
    return "(Media: ${media.key}, publisher: ${publisher.key})";
  }
}

class MediaPublisherAdapter extends TypeAdapter<MediaPublisher> {
  @override
  final int typeId = 21;

  @override
  MediaPublisher read(BinaryReader reader) {
    return MediaPublisher(
      media: reader.read(),
      publisher: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, MediaPublisher obj) {
    writer.write(obj.media);
    writer.write(obj.publisher);
  }
}
