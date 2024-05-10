import 'package:hive_flutter/hive_flutter.dart';

import 'Models/game.dart';
import 'Models/media_user.dart';
import 'Models/user.dart';

class UserSystem {
  // The following 3 definitions are used to make this class a singleton
  static final UserSystem _userSystem = UserSystem._internal();

  factory UserSystem() {
    return _userSystem;
  }

  // This is the constructor, which will need to be changed probably when we add AUTH
  UserSystem._internal() {
    init();
    loadUserContent();
  }
  // Until now we make the class a singleton. Next is what really matters

  User? currentUser;
  Set<MediaUser> currentUserMedia = {};

  void init() {
    var users = Hive.box<User>('users');
    if(users.isEmpty) {
      currentUser = User(
        username: "username",
        email: "email",
        hashSalt: "hashSalt",
        password: "password",
      );
      users.add(currentUser!);
    }
    else {
      // TODO: Change here to allow login/logout and whatever else from AUTH
      currentUser = users.getAt(0)!;
    }
  }

  void clearUserData() {
    currentUserMedia.clear();
  }

  List<Game> getUserGames() {
    return List.from(currentUserMedia.map((mu) => mu.media.media as Game));
  }

  Future<void> loadUserContent() async {
    clearUserData();

    if(currentUser != null) {
      var mediaUsers = Hive.box<MediaUser>('media-users');
      for(int i = 0;i < mediaUsers.length;++i) {
        MediaUser mu = mediaUsers.getAt(i)!;
        if(mu.user == currentUser) {
          currentUserMedia.add(mu);
        }
      }
    }
  }
}