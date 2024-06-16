import 'package:hive/hive.dart';
import 'media.dart';
import 'retailer.dart';

class MediaRetailer extends HiveObject {
  // Hive fields
  int mediaId;
  int retailerId;

  // For ease of use
  Media? _media;
  Retailer? _retailer;

  MediaRetailer({required this.mediaId, required this.retailerId});

  @override
  bool operator ==(Object other) {
    if (runtimeType != other.runtimeType) {
      return false;
    }
    return mediaId == (other as MediaRetailer).mediaId &&
        retailerId == other.retailerId;
  }

  @override
  int get hashCode => Object.hash(mediaId, retailerId);

  Media get media {
    if (_media == null) {
      Box<Media> box = Hive.box<Media>('media');
      for (int i = 0; i < box.length; ++i) {
        if (mediaId == box.getAt(i)!.id) {
          _media = box.getAt(i);
        }
      }
      if (_media == null) {
        throw Exception(
            "MediaRetailer of mediaId $mediaId and retailerId $retailerId does not have an associated Media object or mediaId value is wrong");
      }
    }
    return _media!;
  }

  Retailer get retailer {
    if (_retailer == null) {
      Box<Retailer> box = Hive.box<Retailer>('retailers');
      for (int i = 0; i < box.length; ++i) {
        if (retailerId == box.getAt(i)!.id) {
          _retailer = box.getAt(i);
        }
      }
      if (_retailer == null) {
        throw Exception(
            "MediaRetailer of mediaId $mediaId and retailerId $retailerId does not have an associated Retailer object or retailerId value is wrong");
      }
    }
    return _retailer!;
  }
}

class MediaRetailerAdapter extends TypeAdapter<MediaRetailer> {
  @override
  final int typeId = 19;

  @override
  MediaRetailer read(BinaryReader reader) {
    return MediaRetailer(
      mediaId: reader.readInt(),
      retailerId: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, MediaRetailer obj) {
    writer.writeInt(obj.mediaId);
    writer.writeInt(obj.retailerId);
  }
}
