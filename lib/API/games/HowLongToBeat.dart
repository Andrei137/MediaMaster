import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import '../general/Service.dart';

class HowLongToBeat implements Service {
  // Members
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
      return {'error': e};
    }
  }

  Future<List<String>> _getLinks(String gameName) async {
    try {
      final encodedGameName = Uri.encodeQueryComponent("how long to beat $gameName");
      final url = Uri.parse("https://www.google.com/search?q=$encodedGameName");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final document = parse(response.body);
        final linkList = document.querySelectorAll('a[href*="howlongtobeat.com/game/"]');

        // Add the links to a set to remove duplicates
        var linkSet = <String>{};

        for (int i = 0; i < linkList.length; ++i) {
          String link = linkList[i].attributes['href'].toString();

          // Remove google and bad howlongtobeat links
          if (link.contains('www.google') || _badLinks.any((element) => link.contains(element))) {
            continue;
          }

          // /url?q=https://howlongtobeat.com/game/[id]&[other_stuff] -> https://howlongtobeat.com/game/[id]
          link = link.split('/url?q=').last.split('&').first;
          linkSet.add(link);
        }

        return linkSet.toList();
      } 
      else {
        return ['Response code ${response.statusCode}'];
      }
    }
    catch (e) {
      return ['Error: $e'];
    }
  }

  Future<List<Map<String, dynamic>>> _getGames(String gameName) async {
    try {
      final links = await _getLinks(gameName);

      var options = <Map<String, dynamic>>[];
      for (int i = 0; i < links.length; ++i) {
        var response = await http.get(Uri.parse(links[i]));
        if (response.statusCode == 200) {
          final document = parse(response.body);
          final actualGameName = document.querySelector('.GameHeader_profile_header__q_PID')?.text;
          if (actualGameName != null) {
            options.add({
              'name': actualGameName,
              'link': links[i]
            });
          }
        }
      }
      return options;
    }
    catch (e) {
      return [{'error': '$e'}];
    }
  }

  Future<Map<String, dynamic>> _searchGame(String link) async {
    try
    {
      final response = await http.get(Uri.parse(link));

      if (response.statusCode == 200) {
        return await _gameTimes(parse(response.body));
      } 
      else {
        return {'error': 'Response code ${response.statusCode}'};
      }
    }
    catch (e) {
      return {'error': e};
    }
  }

  // Public methods
  @override
  Future<List<Map<String, dynamic>>> getOptions(String gameName) async {
    return instance._getGames(gameName);
  }

  @override
  Future<Map<String, dynamic>> getInfo(Map<String, dynamic> game) async {
    return instance._searchGame(game['link']);
  }
}
