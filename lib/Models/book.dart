import 'package:hive/hive.dart';
import 'media.dart';

// Don't change the numbers below (HiveType and HiveField).
// For information regarding what can be modified check out https://docs.hivedb.dev/#/custom-objects/generate_adapter
// HiveObject handles primary key automatically and allows relationships between objects
@HiveType(typeId: 9)
class Book extends HiveObject {
  @HiveField(0)
  Media media;

  @HiveField(1)
  String originalLanguage;

  @HiveField(2)
  int totalPages;

  Book(
      {required this.media,
      required this.originalLanguage,
      required this.totalPages});

  @override
  String toString() {
    return "(Media: ${media.key}, originalLanguage: $originalLanguage, totalPages: $totalPages)";
  }
}

class BookAdapter extends TypeAdapter<Book> {
  @override
  final int typeId = 9;

  @override
  Book read(BinaryReader reader) {
    return Book(
      media: reader.read(),
      originalLanguage: reader.readString(),
      totalPages: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, Book obj) {
    writer.write(obj.media);
    writer.writeString(obj.originalLanguage);
    writer.writeInt(obj.totalPages);
  }
}
