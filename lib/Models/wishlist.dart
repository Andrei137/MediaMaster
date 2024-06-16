import 'package:hive/hive.dart';
import 'media.dart';
import 'user.dart';

class Wishlist extends HiveObject {
  // Hive fields
  int mediaId;
  int userId;
  String name;
  int userScore;
  DateTime addedDate;
  String coverImage;
  String status;
  String series;
  String icon;
  String backgroundImage;
  DateTime lastInteracted;
  int gameTime;
  int bookReadPages;

  // For ease of use
  Media? _media;
  User? _user;

  Wishlist(
      {required this.mediaId,
      required this.userId,
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
  bool operator ==(Object other) {
    if (runtimeType != other.runtimeType) {
      return false;
    }
    return mediaId == (other as Wishlist).mediaId && userId == other.userId;
  }

  @override
  int get hashCode => Object.hash(mediaId, userId);

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
            "Wishlist of mediaId $mediaId and userId $userId does not have an associated Media object or mediaId value is wrong");
      }
    }
    return _media!;
  }

  User get user {
    if (_user == null) {
      Box<User> box = Hive.box<User>('users');
      for (int i = 0; i < box.length; ++i) {
        if (userId == box.getAt(i)!.id) {
          _user = box.getAt(i);
        }
      }
      if (_user == null) {
        throw Exception(
            "Wishlist of mediaId $mediaId and userId $userId does not have an associated User object or userId value is wrong");
      }
    }
    return _user!;
  }
}

class WishlistAdapter extends TypeAdapter<Wishlist> {
  @override
  final int typeId = 4;

  @override
  Wishlist read(BinaryReader reader) {
    return Wishlist(
      mediaId: reader.readInt(),
      userId: reader.readInt(),
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
  void write(BinaryWriter writer, Wishlist obj) {
    writer.writeInt(obj.mediaId);
    writer.writeInt(obj.userId);
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
