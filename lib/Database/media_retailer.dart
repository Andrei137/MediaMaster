import 'package:hive/hive.dart';
import 'media.dart';
import 'retailer.dart';

// Don't change the numbers below (HiveType and HiveField).
// For information regarding what can be modified check out https://docs.hivedb.dev/#/custom-objects/generate_adapter
// HiveObject handles primary key automatically and allows relationships between objects
@HiveType(typeId: 19)
class MediaRetailer extends HiveObject {
  @HiveField(0)
  Media media;

  @HiveField(1)
  Retailer retailer;

  MediaRetailer({required this.media, required this.retailer});

  @override
  String toString() {
    return "(Media: {$media}, retailer: {$retailer})";
  }
}

class MediaRetailerAdapter extends TypeAdapter<MediaRetailer> {
  @override
  final int typeId = 19;

  @override
  MediaRetailer read(BinaryReader reader) {
    return MediaRetailer(
      media: reader.read(),
      retailer: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, MediaRetailer obj) {
    writer.write(obj.media);
    writer.write(obj.retailer);
  }
}
