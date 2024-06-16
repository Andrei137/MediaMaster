import 'tag.dart';
import 'genre.dart';
import 'package:hive_flutter/hive_flutter.dart';

void addSeedData() {
  var tags = Hive.box<Tag>('tags');
  if (tags.isEmpty) {
    var tagsToAdd = [
      "Singleplayer",
      "Multiplayer",
      "Casual",
      "Competitive",
      "VR",
      "Indie",
      "Co-Op",
      "Local Co-Op",
      "MMO",
    ];

    for (String tagName in tagsToAdd) {
      tags.add(
        Tag(
          name: tagName,
        ),
      );
    }
  }

  var genres = Hive.box<Genre>('genres');
  if (genres.isEmpty) {
    var genresToAdd = [
      "Shooter",
      "Strategy",
      "Role Playing",
      "Survival",
      "Fighting",
      "Horror",
      "Sandbox",
      "Tower Defense",
      "Simulator",
      "Action",
      "Adventure",
      "Party Game",
      "Trivia",
      "Puzzle",
      "Board Game",
      "Sports",
      "Racing",
      "Rhythm",
      "Platformer",
      "Battle Royale",
      "Metroidvania",
      "Roguelike",
      "Soulslike",
      "Idle",
      "Open World",
      "Point and Click",
      "Real Time Strategy",
      "Visual Novel",
      "Superhero",
      "Stealth",
      "Detective",
      "Management",
      "Comedy",
      "Difficult",
      "Cooking",
      "MOBA",
    ];

    for (String genreName in genresToAdd) {
      genres.add(
        Genre(
          name: genreName,
        ),
      );
    }
  }
}
