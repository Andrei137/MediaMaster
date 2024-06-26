import 'package:hive/hive.dart';
import 'media.dart';

class Book extends HiveObject {
  // Hive fields
  int id;
  int mediaId;
  String originalLanguage;
  int totalPages;

  // For ease of use
  Media? _media;

  // Automatic id generation
  static int nextId = 0;

  Book(
      {this.id = -1,
      required this.originalLanguage,
      required this.totalPages,
      this.mediaId = -1}) {
    if (id == -1) {
      id = nextId;
    }
    if (id >= nextId) {
      nextId = id + 1;
    }
  }

  @override
  bool operator ==(Object other) {
    if (runtimeType != other.runtimeType) {
      return false;
    }
    return id == (other as Book).id;
  }

  @override
  int get hashCode => id;

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
            "Book of id $id does not have an associated Media object or mediaId value is wrong ($mediaId)");
      }
    }
    return _media!;
  }
}

class BookAdapter extends TypeAdapter<Book> {
  @override
  final int typeId = 9;

  @override
  Book read(BinaryReader reader) {
    return Book(
      mediaId: reader.readInt(),
      id: reader.readInt(),
      originalLanguage: reader.readString(),
      totalPages: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, Book obj) {
    writer.writeInt(obj.mediaId);
    writer.writeInt(obj.id);
    writer.writeString(obj.originalLanguage);
    writer.writeInt(obj.totalPages);
  }
}
