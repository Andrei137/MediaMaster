import 'package:hive/hive.dart';
import 'media.dart';
import 'platform.dart';

// Don't change the numbers below (HiveType and HiveField).
// For information regarding what can be modified check out https://docs.hivedb.dev/#/custom-objects/generate_adapter
// HiveObject handles primary key automatically and allows relationships between objects
@HiveType(typeId: 25)
class MediaPlatform extends HiveObject {
  @HiveField(0)
  Media media;

  @HiveField(1)
  Platform platform;

  MediaPlatform({required this.media, required this.platform});

  @override
  String toString() {
    return "(Media: ${media.key}, platform: ${platform.key})";
  }
}

class MediaPlatformAdapter extends TypeAdapter<MediaPlatform> {
  @override
  final int typeId = 25;

  @override
  MediaPlatform read(BinaryReader reader) {
    return MediaPlatform(
      media: reader.read(),
      platform: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, MediaPlatform obj) {
    writer.write(obj.media);
    writer.write(obj.platform);
  }
}
