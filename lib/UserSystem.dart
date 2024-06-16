import 'package:hive_flutter/hive_flutter.dart';

import 'Models/game.dart';
import 'Models/media.dart';
import 'Models/media_user.dart';
import 'Models/media_user_tag.dart';
import 'Models/media_user_genre.dart';
import 'Models/wishlist.dart';
import 'Models/note.dart';
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
  Set<Wishlist> currentUserWishlist = {};
  Set<Note> currentUserNotes = {};

  void init() {
    currentUser = null;
  }

  void login(User user) {
    currentUser = user;
    loadUserContent();
  }

  void logout() {
    currentUser = null;
    clearUserData();
  }

  void clearUserData() {
    currentUserGenres.clear();
    currentUserNotes.clear();
    currentUserMedia.clear();
    currentUserTags.clear();
    currentUserWishlist.clear();
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

  Set<Wishlist> getUserWishlist() {
    return currentUserWishlist;
  }

  List<Game> getUserWishlistGames() {
    return List.from(currentUserWishlist.map((w) => w.media.media as Game));
  }

  Set<Note> getUserNotes(Media media) {
    return Set.from(currentUserNotes.where((note) => note.mediaId == media.id));
  }

  Future<void> loadUserContent() async {
    clearUserData();

    if (currentUser != null) {
      currentUserGenres = Set.from(
        Hive.box<MediaUserGenre>('media-user-genres')
            .values
            .where((mug) => mug.user == currentUser),
      );
      currentUserMedia = Set.from(
        Hive.box<MediaUser>('media-users')
            .values
            .where((mu) => mu.user == currentUser),
      );
      currentUserNotes = Set.from(
        Hive.box<Note>('notes')
            .values
            .where((note) => note.user == currentUser),
      );
      currentUserTags = Set.from(
        Hive.box<MediaUserTag>('media-user-tags')
            .values
            .where((mut) => mut.user == currentUser),
      );
      currentUserWishlist = Set.from(
        Hive.box<Wishlist>('wishlists')
            .values
            .where((w) => w.user == currentUser),
      );
    }
  }
}
