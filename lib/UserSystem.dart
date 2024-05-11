import 'package:hive_flutter/hive_flutter.dart';

import 'Models/game.dart';
import 'Models/media_user.dart';
import 'Models/media_user_tag.dart';
import 'Models/media_user_genre.dart';
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
  Set<MediaUserTag> currentUserTags = {};
  Set<MediaUserGenre> currentUserGenres = {};

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
    currentUserTags.clear();
    currentUserGenres.clear();
  }

  List<Game> getUserGames() {
    return List.from(currentUserMedia.map((mu) => mu.media.media as Game));
  }

  Set<MediaUserGenre> getUserGenres() {
    return currentUserGenres;
  }

  Set<MediaUserTag> getUserTags() {
    return currentUserTags;
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

      var mediaUserTags = Hive.box<MediaUserTag>('media-user-tags');
      for(int i = 0;i < mediaUserTags.length;++i) {
        MediaUserTag mut = mediaUserTags.getAt(i)!;
        if(mut.user == currentUser) {
          currentUserTags.add(mut);
        }
      }

      var mediaUserGenres = Hive.box<MediaUserGenre>('media-user-genres');
      for(int i = 0;i < mediaUserGenres.length;++i) {
        MediaUserGenre mug = mediaUserGenres.getAt(i)!;
        if(mug.user == currentUser) {
          currentUserGenres.add(mug);
        }
      }
    }
  }
}