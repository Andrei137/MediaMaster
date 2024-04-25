import 'package:hive/hive.dart';
import 'media.dart';
import 'user.dart';

// Don't change the numbers below (HiveType and HiveField).
// For information regarding what can be modified check out https://docs.hivedb.dev/#/custom-objects/generate_adapter
// HiveObject handles primary key automatically and allows relationships between objects
@HiveType(typeId: 6)
class MediaUser extends HiveObject {
  @HiveField(0)
  Media media;

  @HiveField(1)
  User user;

  @HiveField(2)
  String name;

  @HiveField(3)
  int userScore;

  @HiveField(4)
  DateTime addedDate;

  @HiveField(5)
  String coverImage;

  @HiveField(6)
  String status;

  @HiveField(7)
  String series;

  @HiveField(8)
  String icon;

  @HiveField(9)
  String backgroundImage;

  @HiveField(10)
  DateTime lastInteracted;

  @HiveField(11)
  int gameTime;

  @HiveField(12)
  int bookReadPages;

  MediaUser(
      {required this.media,
      required this.user,
      required this.name,
      required this.userScore,
      required this.addedDate,
      required this.coverImage,
      required this.status,
      required this.series,
      required this.icon,
      required this.backgroundImage,
      required this.lastInteracted,
      this.gameTime = 0,
      this.bookReadPages = 0});

  @override
  String toString() {
    return "(Media: ${media.key}, user: ${user.username}, name: $name, addedDate: $addedDate, status: $status)";
  }
}

class MediaUserAdapter extends TypeAdapter<MediaUser> {
  @override
  final int typeId = 6;

  @override
  MediaUser read(BinaryReader reader) {
    return MediaUser(
      media: reader.read(),
      user: reader.read(),
      name: reader.readString(),
      userScore: reader.readInt(),
      addedDate: reader.read(),
      coverImage: reader.readString(),
      status: reader.readString(),
      series: reader.readString(),
      icon: reader.readString(),
      backgroundImage: reader.readString(),
      lastInteracted: reader.read(),
      gameTime: reader.readInt(),
      bookReadPages: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, MediaUser obj) {
    writer.write(obj.media);
    writer.write(obj.user);
    writer.writeString(obj.name);
    writer.writeInt(obj.userScore);
    writer.write(obj.addedDate);
    writer.writeString(obj.coverImage);
    writer.writeString(obj.status);
    writer.writeString(obj.series);
    writer.writeString(obj.icon);
    writer.writeString(obj.backgroundImage);
    writer.write(obj.lastInteracted);
    writer.writeInt(obj.gameTime);
    writer.writeInt(obj.bookReadPages);
  }
}
