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
      // some games can't be found when the name contains -
      gameName = gameName.replaceAll('-', ' ');

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
          return [];
        }
      }
      else {
        return [];
      }
    }
    catch (e) {
      return [];
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
          final sysReqsTable = document.querySelector('.pcgwikitable#table-sysreqs-$query');

          Map<String, dynamic> sysReqs = {};
          if (sysReqsTable != null) {
            List<Element> rows = sysReqsTable.querySelectorAll('.template-infotable-body, .table-sysreqs-body-row');

            for (var row in rows) {
              final fullCategory = row.querySelector('.table-sysreqs-body-parameter')?.text.trim() ?? '';
              final category = fullCategory.contains('(') ? fullCategory.split('(')[1].split(')')[0] : fullCategory;

              final minimumReq = row.querySelector('.table-sysreqs-body-minimum')?.text.trim() ?? '';
              final recommendedReq = row.querySelector('.table-sysreqs-body-recommended')?.text.trim() ?? '';

              if (minimumReq.isNotEmpty || recommendedReq.isNotEmpty) {
                sysReqs[category] = {
                  'minimum': (minimumReq != '') ? minimumReq : null,
                  'recommended': (recommendedReq != '') ? recommendedReq : null
                };
              }
            }
            gameInfo[query] = sysReqs;
          }
        }
        if (gameInfo.isNotEmpty) {
          return gameInfo;
        }
        else {
          return {};
        }
      }
      else {
        return {};
      }
    }
    catch (e) {
      return {};
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

  @override
  Future<List<Map<String, dynamic>>> getRecommendations(int gameId) async {
    return [];
  }
}
