import 'package:hive/hive.dart';
import 'media.dart';
import 'user.dart';

// Don't change the numbers below (HiveType and HiveField).
// For information regarding what can be modified check out https://docs.hivedb.dev/#/custom-objects/generate_adapter
// HiveObject handles primary key automatically and allows relationships between objects
@HiveType(typeId: 4)
class Wishlist extends HiveObject {
  @HiveField(0)
  Media media;

  @HiveField(1)
  User user;

  Wishlist({required this.media, required this.user});

  @override
  String toString() {
    return "(Media: ${media.key}, user: ${user.username})";
  }
}

class WishlistAdapter extends TypeAdapter<Wishlist> {
  @override
  final int typeId = 4;

  @override
  Wishlist read(BinaryReader reader) {
    return Wishlist(
      media: reader.read(),
      user: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, Wishlist obj) {
    writer.write(obj.media);
    writer.write(obj.user);
  }
}
