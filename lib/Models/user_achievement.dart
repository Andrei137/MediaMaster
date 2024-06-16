import 'package:hive/hive.dart';
import 'user.dart';
import 'app_achievement.dart';

class UserAchievement extends HiveObject {
  // Hive fields
  int userId;
  int achievementId;
  DateTime unlockDate;

  // For ease of use
  User? _user;
  AppAchievement? _achievement;

  UserAchievement(
      {required this.userId,
      required this.achievementId,
      required this.unlockDate});

  @override
  bool operator ==(Object other) {
    if (runtimeType != other.runtimeType) {
      return false;
    }
    return userId == (other as UserAchievement).userId &&
        achievementId == other.achievementId;
  }

  @override
  int get hashCode => Object.hash(userId, achievementId);

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
            "UserAchievement of userId $userId and achievementId $achievementId does not have an associated User object or userId value is wrong");
      }
    }
    return _user!;
  }

  AppAchievement get achievement {
    if (_achievement == null) {
      Box<AppAchievement> box = Hive.box<AppAchievement>('appAchievements');
      for (int i = 0; i < box.length; ++i) {
        if (achievementId == box.getAt(i)!.id) {
          _achievement = box.getAt(i);
        }
      }
      if (_achievement == null) {
        throw Exception(
            "UserAchievement of userId $userId and achievementId $achievementId does not have an associated AppAchievement object or achievementId value is wrong");
      }
    }
    return _achievement!;
  }
}

class UserAchievementAdapter extends TypeAdapter<UserAchievement> {
  @override
  final int typeId = 2;

  @override
  UserAchievement read(BinaryReader reader) {
    return UserAchievement(
      userId: reader.readInt(),
      achievementId: reader.readInt(),
      unlockDate: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, UserAchievement obj) {
    writer.writeInt(obj.userId);
    writer.writeInt(obj.achievementId);
    writer.write(obj.unlockDate);
  }
}
