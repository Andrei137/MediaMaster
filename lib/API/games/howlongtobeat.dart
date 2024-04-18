import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'package:dart_console/dart_console.dart';
import '../general/Service.dart';

class HowLongToBeat implements Service {
  // Members
  final _console = Console();
  final _querySelectors = [
    '.GameStats_short__tSJ6I',
    '.GameStats_long__h3afN',
    '.GameStats_full__jz7k7'
  ];
  final _badLinks = ['reviews', 'lists', 'completions'];

  // Private constructor
  HowLongToBeat._();

  // Singleton instance
  static final HowLongToBeat _instance = HowLongToBeat._();

  // Accessor for the singleton instance
  static HowLongToBeat get instance => _instance;

  // Private methods
  Future<Map<String, dynamic>> _gameTimes(Document document) async {
    try {
      var times = <String, dynamic>{};
      for (var selector in _querySelectors) {
        final timeElements = document.querySelectorAll(selector);
        for (var i = 0; i < timeElements.length; ++i) {
          // Split the text after the first digit, and include it in the second one
          // Single-Player68½ Hours - 274 Hours -> Singleplayer and 68½ - 274 Hours
          final text = timeElements[i].text;
          final label = text.split(RegExp(r'\d'))[0].trim();
          final time = text.substring(label.length).trim();

          if (!label.contains('-') && !label.isEmpty && !time.isEmpty) {
            times[label] = time;
          }
        }
      }
      return times;
    }
    catch (e) {
      // If an error occurs, return an empty map
      return {};
    }
  }

  Future<List<String>> _getLinks(String gameName) async {
    try {
      // Prepare the search request
      final encodedGameName = Uri.encodeQueryComponent("how long to beat $gameName");
      final searchUrl = Uri.parse("https://www.google.com/search?q=$encodedGameName");
      final searchResponse = await http.get(searchUrl);

      if (searchResponse.statusCode == 200) {
        // If the search was successful, parse the results
        final document = parse(searchResponse.body);

        // Select all elements with href*="howlongtobeat.com/game/"
        final allHLTBLinks = document.querySelectorAll('a[href*="howlongtobeat.com/game/"]');

        // Add link to a set to remove duplicates
        var tempSet = <String>{};

        for (int i = 0; i < allHLTBLinks.length; ++i) {
          String currLink = allHLTBLinks[i].attributes['href'].toString();

          // Remove google links and bad howlongtobeat links
          if (currLink.contains('www.google') || _badLinks.any((element) => currLink.contains(element))) {
            continue;
          }

          // /url?q=https://howlongtobeat.com/game/[id]&[other_stuff] -> https://howlongtobeat.com/game/[id]
          currLink = currLink.split('/url?q=').last.split('&').first;
          tempSet.add(currLink);
        }

        return tempSet.toList();
      } 
      else {
        // If the search request fails, return an empty list
        return [];
      }
    }
    catch (e) {
      // If an error occurs, return an empty list
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _getGames(String gameName) async {
    try {
      final gameLinks = await _getLinks(gameName);

      var options = <Map<String, dynamic>>[];
      for (int i = 0; i < gameLinks.length; ++i) {
        var gameResponse = await http.get(Uri.parse(gameLinks[i]));
        if (gameResponse.statusCode == 200) {
          final currGameDocument = parse(gameResponse.body);
          final currGameName = currGameDocument.querySelector('.GameHeader_profile_header__q_PID')?.text;
          if (currGameName != null) {
            options.add({
              'name': currGameName,
              'link': gameLinks[i]
            });
          }
        }
      }
      return options;
    }
    catch (e) {
      // If an error occurs, return an empty list
      return [];
    }
  }

  Future<Map<String, dynamic>> _searchGame(Map<String, dynamic> game) async {
    try
    {
      final gameUrl = Uri.parse(game['link']);
      final gameResponse = await http.get(gameUrl);
      if (gameResponse.statusCode == 200) {
        final document = parse(gameResponse.body);
        return await _gameTimes(document);
      } 
      else {
        // If the request failed, return an empty map
        return {};
      }
    }
    catch (e) {
      // If an error occurs, return an empty map
      return {};
    }
  }

  // Public methods
  @override
  Future<List<Map<String, dynamic>>> getOptions(String gameName) async {
    return instance._getGames(gameName);
  }

  @override
  Future<Map<String, dynamic>> search(Map<String, dynamic> game) async {
    return instance._searchGame(game);
  }
}
