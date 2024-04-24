import 'package:hive/hive.dart';

// Don't change the numbers below (HiveType and HiveField).
// For information regarding what can be modified check out https://docs.hivedb.dev/#/custom-objects/generate_adapter
// HiveObject handles primary key automatically and allows relationships between objects
@HiveType(typeId: 3)
class Media extends HiveObject {
  @HiveField(0)
  String description;

  @HiveField(1)
  DateTime releaseDate;

  @HiveField(2)
  int criticScore;

  @HiveField(3)
  int communityScore;

  @HiveField(4)
  String mediaType;

  Media({required this.description, required this.releaseDate, required this.criticScore, required this.communityScore, required this.mediaType});

  @override
  String toString() {
    return "(Description: $description, releaseDate: $releaseDate, criticScore: $criticScore, communityScore: $communityScore, mediaType: $mediaType)";
  }
}

class MediaAdapter extends TypeAdapter<Media> {
  @override
  final int typeId = 3;

  @override
  Media read(BinaryReader reader) {
    return Media(
      description: reader.readString(),
      releaseDate: reader.read(),
      criticScore: reader.readInt(),
      communityScore: reader.readInt(),
      mediaType: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Media obj) {
    writer.writeString(obj.description);
    writer.write(obj.releaseDate);
    writer.writeInt(obj.criticScore);
    writer.writeInt(obj.communityScore);
    writer.writeString(obj.mediaType);
  }
}