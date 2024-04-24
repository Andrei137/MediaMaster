import 'package:hive/hive.dart';
import 'user.dart';
import 'app_achievement.dart';

// Don't change the numbers below (HiveType and HiveField).
// For information regarding what can be modified check out https://docs.hivedb.dev/#/custom-objects/generate_adapter
// HiveObject handles primary key automatically and allows relationships between objects
@HiveType(typeId: 2)
class UserAchievement extends HiveObject {
  @HiveField(0)
  User user;

  @HiveField(1)
  AppAchievement achievement;

  @HiveField(2)
  DateTime unlockDate;

  UserAchievement(
      {required this.user,
      required this.achievement,
      required this.unlockDate});

  @override
  String toString() {
    return "(User: ${user.username}, achievement: ${achievement.name}, unlockDate: $unlockDate)";
  }
}

class UserAchievementAdapter extends TypeAdapter<UserAchievement> {
  @override
  final int typeId = 2;

  @override
  UserAchievement read(BinaryReader reader) {
    return UserAchievement(
      user: reader.read(),
      achievement: reader.read(),
      unlockDate: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, UserAchievement obj) {
    writer.write(obj.user);
    writer.write(obj.achievement);
    writer.write(obj.unlockDate);
  }
}
