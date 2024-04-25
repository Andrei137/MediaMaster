import 'package:hive_flutter/hive_flutter.dart';

import '/../Models/app_achievement.dart';
import '/../Models/book.dart';
import '/../Models/creator.dart';
import '/../Models/episode.dart';
import '/../Models/game.dart';
import '/../Models/game_achievement.dart';
import '/../Models/genre.dart';
import '/../Models/link.dart';
import '/../Models/media.dart';
import '/../Models/media_creator.dart';
import '/../Models/media_link.dart';
import '/../Models/media_platform.dart';
import '/../Models/media_publisher.dart';
import '/../Models/media_retailer.dart';
import '/../Models/media_user.dart';
import '/../Models/media_user_genre.dart';
import '/../Models/media_user_tag.dart';
import '/../Models/movie.dart';
import '/../Models/note.dart';
import '/../Models/platform.dart';
import '/../Models/publisher.dart';
import '/../Models/retailer.dart';
import '/../Models/season.dart';
import '/../Models/tag.dart';
import '/../Models/tv_series.dart';
import '/../Models/user.dart';
import '/../Models/user_achievement.dart';
import '/../Models/wishlist.dart';

void testAllRelationships() {
  var appAchievements = Hive.box('appAchievements');
  var books = Hive.box<Book>('books');
  var creators = Hive.box<Creator>('creators');
  var episodes = Hive.box<Episode>('episodes');
  var games = Hive.box<Game>('games');
  var gameAchievements = Hive.box<GameAchievement>('gameAchievements');
  var genres = Hive.box<Genre>('genres');
  var links = Hive.box<Link>('links');
  var media = Hive.box<Media>('media');
  var MediaCreators = Hive.box<MediaCreator>('media-creators');
  var mediaLinks = Hive.box<MediaLink>('media-links');
  var MediaPlatforms = Hive.box<MediaPlatform>('media-platforms');
  var mediaPublishers = Hive.box<MediaPublisher>('media-publishers');
  var mediaRetailers = Hive.box<MediaRetailer>('media-retailers');
  var mediaUsers = Hive.box<MediaUser>('media-users');
  var mediaUserGenres = Hive.box<MediaUserGenre>('media-user-genres');
  var mediaUserTags = Hive.box<MediaUserTag>('media-user-tags');
  var movies = Hive.box<Movie>('movies');
  var notes = Hive.box<Note>('notes');
  var platforms = Hive.box<Platform>('platforms');
  var publishers = Hive.box<Publisher>('publishers');
  var retailers = Hive.box<Retailer>('retailers');
  var seasons = Hive.box<Season>('seasons');
  var tags = Hive.box<Tag>('tags');
  var tvSeries = Hive.box<TvSeries>('tvSeries');
  var users = Hive.box<User>('users');
  var userAchievements = Hive.box<UserAchievement>('userAchievements');
  var wishlists = Hive.box<Wishlist>('wishlists');

  void testMedia() {
    media.clear();
    
    media.add(
      Media(
        originalName: "Joc 1",
        description: "Descriere joc 1",
        releaseDate: DateTime.parse("2000-12-25"),
        criticScore: 10,
        communityScore: 10,
        mediaType: "Game",
      ),
    );
    media.add(
      Media(
        originalName: "Joc 2",
        description: "Descriere joc 2",
        releaseDate: DateTime.parse("2024-01-01"),
        criticScore: 5,
        communityScore: 5,
        mediaType: "Game",
      ),
    );
    media.add(
      Media(
        originalName: "Joc 3",
        description: "Descriere joc 3",
        releaseDate: DateTime.parse("1993-12-10"),
        criticScore: 11,
        communityScore: 12,
        mediaType: "Game",
      ),
    );

    media.add(
      Media(
        originalName: "Carte 1",
        description: "Descriere carte 1",
        releaseDate: DateTime.parse("2012-04-04"),
        criticScore: 10,
        communityScore: 10,
        mediaType: "Game",
      ),
    );
    media.add(
      Media(
        originalName: "Joc 2",
        description: "Descriere joc 2",
        releaseDate: DateTime.parse("2024-01-01"),
        criticScore: 5,
        communityScore: 5,
        mediaType: "Game",
      ),
    );
    media.add(
      Media(
        originalName: "Joc 3",
        description: "Descriere joc 3",
        releaseDate: DateTime.parse("1993-12-10"),
        criticScore: 11,
        communityScore: 12,
        mediaType: "Game",
      ),
    );
  };

  {
    appAchievements.add(
      AppAchievement(
        name: "Nume achievement",
        description: "Descriere achievement",
      ),
    );

    appAchievements.add(
      AppAchievement(
        name: "Al doilea",
        description: "Domn student, nu merge asa",
      ),
    );

    
  }
}