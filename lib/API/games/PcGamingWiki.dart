import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import '../general/Service.dart';

class PcGamingWiki implements Service {
  // Members
  final _queries = ['windows', 'os_x', 'linux'];

  // Private constructor
  PcGamingWiki._();

  // Singleton instance
  static final PcGamingWiki _instance = PcGamingWiki._();

  // Accessor for the singleton instance
  static PcGamingWiki get instance => _instance;

  // Private methods
  Future<List<Map<String, dynamic>>> _getGames(String gameName) async {
    try {
      final url ='https://www.pcgamingwiki.com/w/api.php?action=query&format=json&list=search&srsearch=$gameName';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final games = jsonDecode(response.body);

        if (games.containsKey('query') && games['query'].containsKey('search')) {
          var options = <Map<String, dynamic>>[];

          for (var game in games['query']['search']) {
            if (game['snippet'].contains('REDIRECT')) {
              continue;
            }

            options.add({
              'name': game['title'],
            });
          }
          return options;
        }
        else {
          return [{'error': 'No results found.'}];
        }
      }
      else {
        return [{'error': 'Response code ${response.statusCode}'}];
      }
    }
    catch (e) {
      return [{'error': '$e'}];
    }
  }

  Future<Map<String, dynamic>> _searchGame(String gameName) async {
    try {
      final url = "https://www.pcgamingwiki.com/wiki/${gameName.replaceAll(' ', '_')}";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final document = parse(response.body);
        Map<String, dynamic> gameInfo = {
          'link': url,
        };

        for (var query in _queries) {
          final sysreqsTable = document.querySelector('.pcgwikitable#table-sysreqs-$query');

          Map<String, dynamic> sysreqs = {};
          if (sysreqsTable != null) {
            List<Element> rows = sysreqsTable.querySelectorAll('.template-infotable-body, .table-sysreqs-body-row');

            for (var row in rows) {
              final fullCategory = row.querySelector('.table-sysreqs-body-parameter')?.text.trim() ?? '';
              final category = fullCategory.contains('(') ? fullCategory.split('(')[1].split(')')[0] : fullCategory;

              final minimumReq = row.querySelector('.table-sysreqs-body-minimum')?.text.trim() ?? '';
              final recommendedReq = row.querySelector('.table-sysreqs-body-recommended')?.text.trim() ?? '';

              if (minimumReq.isNotEmpty || recommendedReq.isNotEmpty)
              {
                sysreqs[category] = {
                  'minimum': (minimumReq != '') ? minimumReq : null,
                  'recommended': (recommendedReq != '') ? recommendedReq : null
                };
              }
            }
            gameInfo[query] = sysreqs;
          }
        }
        if (gameInfo.isNotEmpty) {
          return gameInfo;
        }
        else {
          return {'error': 'No game data found'};
        }
      }
      else {
        return {'error': 'Failed to get game data'};
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
    return instance._searchGame(game['name']);
  }
}
