import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'package:dart_console/dart_console.dart';
import '../general/Service.dart';

class PcGamingWiki implements Service {
  // Members
  final _console = Console();

  // Private constructor
  PcGamingWiki._();

  // Singleton instance
  static final PcGamingWiki _instance = PcGamingWiki._();

  // Accessor for the singleton instance
  static PcGamingWiki get instance => _instance;

  // Private methods
  Future<List<Map<String, dynamic>>> _getGames(String gameName) async {
      // Prepare the search request
      final searchUrl ='https://www.pcgamingwiki.com/w/api.php?action=query&format=json&list=search&srsearch=$gameName';
      final searchResponse = await http.get(Uri.parse(searchUrl));

      if (searchResponse.statusCode == 200) {
        // If the call to the API was successful, get the games
        Map<String, dynamic> games = jsonDecode(searchResponse.body);

        // If we find any games, ask the user to choose one
        if (games.containsKey('query') && games['query'].containsKey('search')) {
          var options = <Map<String, dynamic>>[];
          for (var game in games['query']['search']) {
            options.add({
              'name': game['title'],
            });
          }
          return options;
        }
        else {
          // If the search doesn't return any results, return an empty list
          return [];
        }
      }
      else {
        // If the request fails, return an empty list
        return [];
      }
  }

  Future<Map<String, dynamic>> _searchGame(String gameName) async {
    try {
      // Go to the game's page
      final pageUrl = "https://www.pcgamingwiki.com/wiki/${gameName.replaceAll(' ', '_')}";
      final gameResponse = await http.get(Uri.parse(pageUrl));

      if (gameResponse.statusCode == 200) {
        // If the page exists, parse it
        final document = parse(gameResponse.body);

        // Find the system requirements table
        final sysreqsTable = document.querySelector('.pcgwikitable#table-sysreqs-windows');

        Map<String, dynamic> gameInfo = {
          'gameName': gameName,
          'pageUrl': pageUrl,
        };

        if (sysreqsTable != null) {
          // Get the table rows
          List<Element> rows = sysreqsTable.querySelectorAll('.template-infotable-body, .table-sysreqs-body-row');
          for (var row in rows) {
            final category = row.querySelector('.table-sysreqs-body-parameter')?.text.trim() ?? '';
            final minimumReq = row.querySelector('.table-sysreqs-body-minimum')?.text.trim() ?? '';
            final recommendedReq = row.querySelector('.table-sysreqs-body-recommended')?.text.trim() ?? '';

            // If there are requirements, print them
            if (minimumReq.isNotEmpty || recommendedReq.isNotEmpty)
            {
              gameInfo[category] = {
                'minimum': minimumReq,
                'recommended': recommendedReq,
              };
            }
          }
          return gameInfo;
        }
        else {
          // If the table doesn't exist, return an empty map
          return {};
        }
      }
      else {
        // If the request fails, return an empty map
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
    return instance._searchGame(game['name']);
  }
}