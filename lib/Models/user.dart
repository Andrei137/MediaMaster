import 'package:hive/hive.dart';

// Don't change the number below (typeId).
// For information regarding what can be modified check out https://docs.hivedb.dev/#/custom-objects/generate_adapter
class User extends HiveObject {
  // Hive fields
  int id;
  String username;
  // There is no way to make this unique from hive. This must be checked when we create the new User
  String email;
  // This is hashed
  String password;
  String hashSalt;
  DateTime creationDate = DateTime.now();

  // Automatic id generator
  static int nextId = 0;

  User(
      {this.id = -1,
      required this.username,
      required this.email,
      required this.hashSalt,
      required this.password}) {
        if(id == -1) {
          id = nextId;
        }
        if(id >= nextId) {
          nextId = id + 1;
        }
      }

  @override
  bool operator==(Object other) {
    if(runtimeType != other.runtimeType) {
      return false;
    }
    return id == (other as User).id;
  }
  
  @override
  int get hashCode => id;
}

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 0;

  @override
  User read(BinaryReader reader) {
    return User(
      id: reader.readInt(),
      username: reader.readString(),
      email: reader.readString(),
      password: reader.readString(),
      hashSalt: reader.readString(),
    )..creationDate = reader.read();
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer.writeInt(obj.id);
    writer.writeString(obj.username);
    writer.writeString(obj.email);
    writer.writeString(obj.password);
    writer.writeString(obj.hashSalt);
    writer.write(obj.creationDate);
  }
}
