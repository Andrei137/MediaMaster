import 'package:hive/hive.dart';
import 'media.dart';
import 'publisher.dart';

class MediaPublisher extends HiveObject {
  // Hive fields
  int mediaId;
  int publisherId;

  // For ease of use
  Media? _media;
  Publisher? _publisher;

  MediaPublisher({required this.mediaId, required this.publisherId});

  @override
  bool operator ==(Object other) {
    if (runtimeType != other.runtimeType) {
      return false;
    }
    return mediaId == (other as MediaPublisher).mediaId &&
        publisherId == other.publisherId;
  }

  @override
  int get hashCode => Object.hash(mediaId, publisherId);

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
            "MediaPublisher of mediaId $mediaId and publisherId $publisherId does not have an associated Media object or mediaId value is wrong");
      }
    }
    return _media!;
  }

  Publisher get publisher {
    if (_publisher == null) {
      Box<Publisher> box = Hive.box<Publisher>('publishers');
      for (int i = 0; i < box.length; ++i) {
        if (publisherId == box.getAt(i)!.id) {
          _publisher = box.getAt(i);
        }
      }
      if (_publisher == null) {
        throw Exception(
            "MediaPublisher of mediaId $mediaId and publisherId $publisherId does not have an associated Publisher object or publisherId value is wrong");
      }
    }
    return _publisher!;
  }
}

class MediaPublisherAdapter extends TypeAdapter<MediaPublisher> {
  @override
  final int typeId = 21;

  @override
  MediaPublisher read(BinaryReader reader) {
    return MediaPublisher(
      mediaId: reader.readInt(),
      publisherId: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, MediaPublisher obj) {
    writer.writeInt(obj.mediaId);
    writer.writeInt(obj.publisherId);
  }
}
