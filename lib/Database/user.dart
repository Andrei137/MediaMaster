import 'package:hive/hive.dart';

// Don't change the numbers below (HiveType and HiveField).
// For information regarding what can be modified check out https://docs.hivedb.dev/#/custom-objects/generate_adapter
// HiveObject handles primary key automatically and allows relationships between objects
@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  String username;

  // There is no way to make this unique from hive. This must be checked when we create the new User
  @HiveField(1)
  String email;

  // This is hashed
  @HiveField(2)
  String password;

  @HiveField(3)
  String hashSalt;

  @HiveField(4)
  DateTime creationDate = DateTime.now();

  User({required this.username, required this.email, required this.hashSalt, required this.password});

  @override
  String toString() {
    return "(Username: $username, email: $email, creation date: ${creationDate.toString()})";
  }
}

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 0;

  @override
  User read(BinaryReader reader) {
    return User(
      username: reader.readString(),
      email: reader.readString(),
      password: reader.readString(),
      hashSalt: reader.readString(),
    )..creationDate = reader.read();
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer.writeString(obj.username);
    writer.writeString(obj.email);
    writer.writeString(obj.password);
    writer.writeString(obj.hashSalt);
    writer.write(obj.creationDate);
  }
}