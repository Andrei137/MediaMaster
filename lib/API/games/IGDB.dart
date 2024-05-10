import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../general/Service.dart';
import '../general/Constants.dart';

class IGDB implements Service {
  // Members
  final _params = {
    "client_id": clientIdIGDB,
    "client_secret": clientSecretIGDB,
    "grant_type": "client_credentials"
  };
  String _accessToken = "";
  List<String> _artwork = [];
  String _cover = "";
  List<String> _collections = [];
  List<dynamic> _developers = [];
  List<String> _franchises = [];
  List<String> _genres = [];
  List<dynamic> _publishers = [];
  List<String> _websites = [];

  // Private constructor
  IGDB._();

  // Singleton instance
  static final IGDB _instance = IGDB._();

  // Accessor for the singleton instance
  static IGDB get instance => _instance;

  // Private methods
  void reset() {
    _artwork = [];
    _cover = "";
    _collections = [];
    _developers = [];
    _franchises = [];
    _genres = [];
    _publishers = [];
    _websites = [];
  }

  Future<String> _getAccessToken() async {
    try {
      final url = Uri.parse("https://id.twitch.tv/oauth2/token");
      final response = await http.post(url, body: _params);
      if (response.statusCode == 200) {
        return jsonDecode(response.body)["access_token"];
      } 
      else {
        print("Failed to get access token.");
        return "Fail";
      }
    }
    catch (e) {
      print(e);
      return "Fail";
    }
  }

  String _formatIds(game, key) {
    var ids = "(";
    for (int i = 0; i < game[key].length; ++i) {
      ids += "${game[key][i]}";
      if (i != game[key].length - 1) {
        ids += ", ";
      }
    }
    ids += ")";
    return ids;
  }

  Future<void> _getArtworks(accessToken, game) async {
    try {
      final url = Uri.parse("https://api.igdb.com/v4/artworks");
      final headers = {
        "Client-ID": clientIdIGDB,
        "Authorization": "Bearer $accessToken",
      };
      final body = "fields url; where game = ${game['id']};";
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        var artworks = jsonDecode(response.body);
        for (int i = 0; i < artworks.length; ++i) {
          _artwork.add(artworks[i]['url'].replaceFirst("thumb", "1080p"));
        }
      } 
      else {
        print("Failed to get artworks.");
      }
    }
    catch (e) {
      print(e);
    }
  }

  Future<void> _getCover(accessToken, game) async {
    try {
      final url = Uri.parse("https://api.igdb.com/v4/covers");
      final headers = {
        "Client-ID": clientIdIGDB,
        "Authorization": "Bearer $accessToken",
      };
      final body = "fields url; where id = ${game['cover']};";
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        var cover = jsonDecode(response.body);
        _cover = cover[0]['url'];
        _cover = _cover.replaceFirst("thumb", "cover_big");
      } 
      else {
        print("Failed to get cover.");
      }
    }
    catch (e) {
      print(e);
    }
  }

  Future<void> _getCollections(accessToken, game) async {
    try {
      if (game['collection'] != null) {
        game['collections'].add(game['collection']);
        game.remove('collection');
      }
      final url = Uri.parse("https://api.igdb.com/v4/collections");
      final headers = {
        "Client-ID": clientIdIGDB,
        "Authorization": "Bearer $accessToken",
      };
      final body = "fields name; where id = ${_formatIds(game, 'collections')};";
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        var collections = jsonDecode(response.body);
        for (int i = 0; i < collections.length; ++i) {
          _collections.add(utf8.decode(collections[i]['name'].runes.toList()));
        }
      } 
      else {
        print("Failed to get collections.");
      }
    }
    catch (e) {
      print(e);
    }
  }

  Future<void> _getCompanies(accessToken, game) async {
    try {
      await _getDevelopersAndPublishers(accessToken, game);
      String ids = '(';
      for (int i = 0; i < _developers.length; ++i) {
        ids += "${_developers[i]}";
        if (i != _developers.length - 1) {
          ids += ", ";
        }
      }
      if (_developers.isNotEmpty && _publishers.isNotEmpty) {
        ids += ", ";
      }
      for (int i = 0; i < _publishers.length; ++i) {
        ids += "${_publishers[i]}";
        if (i != _publishers.length - 1) {
          ids += ", ";
        }
      }
      ids += ')';
      final url = Uri.parse("https://api.igdb.com/v4/companies");
      final headers = {
        "Client-ID": clientIdIGDB,
        "Authorization": "Bearer $accessToken",
      };
      final body = "fields name; where id = $ids;";
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        var companies = jsonDecode(response.body);
        for (int i = 0; i < companies.length; ++i) {
          if (_developers.contains(companies[i]['id'])) {
            _developers.add(utf8.decode(companies[i]['name'].runes.toList()));
          }
          if (_publishers.contains(companies[i]['id'])) {
            _publishers.add(utf8.decode(companies[i]['name'].runes.toList()));
          }
        }
        for (int i = 0; i < _developers.length; ++i) {
          if (_developers[i] is int) {
            _developers.removeAt(i);
          }
        }
        for (int i = 0; i < _publishers.length; ++i) {
          if (_publishers[i] is int) {
            _publishers.removeAt(i);
          }
        }
      } 
      else {
        print("Failed to get companies.");
      }
    }
    catch (e) {
      print(e);
    }
  }

  Future<void> _getDevelopersAndPublishers(accessToken, game) async {
    try {
      final url = Uri.parse("https://api.igdb.com/v4/involved_companies");
      final headers = {
        "Client-ID": clientIdIGDB,
        "Authorization": "Bearer $accessToken",
      };
      final body = "fields company,developer,publisher; where id = ${_formatIds(game, 'involved_companies')} & (developer = true | publisher = true);";
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        var companies = jsonDecode(response.body);
        for (int i = 0; i < companies.length; ++i) {
          if (companies[i]['developer'] == true) {
            _developers.add(companies[i]['company']);
          }
          if (companies[i]['publisher'] == true) {
            _publishers.add(companies[i]['company']);
          }
        }
      }
      else {
        print("Failed to get developers and publishers.");
      }
    }
    catch (e) {
      print(e);
    }
  }

  Future<void> _getFranchises(accessToken, game) async {
    try {
      if (game['franchise'] != null) {
        game['franchises'].add(game['franchise']);
        game.remove('franchise');
      }
      final url = Uri.parse("https://api.igdb.com/v4/franchises");
      final headers = {
        "Client-ID": clientIdIGDB,
        "Authorization": "Bearer $accessToken",
      };
      final body = "fields name; where id = ${_formatIds(game, 'franchise')};";
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        var franchises = jsonDecode(response.body);
        for (int i = 0; i < franchises.length; ++i) {
          _franchises.add(utf8.decode(franchises[i]['name'].runes.toList()));
        }
      } 
      else {
        print("Failed to get franchises.");
      }
    }
    catch (e) {
      print(e);
    }
  }

  Future<void> _getGenres(accessToken, game) async {
    try {
      final url = Uri.parse("https://api.igdb.com/v4/genres");
      final headers = {
        "Client-ID": clientIdIGDB,
        "Authorization": "Bearer $accessToken",
      };
      final body = "fields name; where id = ${_formatIds(game, 'genres')};";
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        var genres = jsonDecode(response.body);
        for (int i = 0; i < genres.length; ++i) {
          _genres.add(utf8.decode(genres[i]['name'].runes.toList()));
        }
      } 
      else {
        print("Failed to get genress.");
      }
    }
    catch (e) {
      print(e);
    }
  }

  Future<void> _getWebsites(accessToken, game) async {
    try {
      final url = Uri.parse("https://api.igdb.com/v4/websites");
      final headers = {
        "Client-ID": clientIdIGDB,
        "Authorization": "Bearer $accessToken",
      };
      final body = "fields url; where game = ${game['id']};";
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        var websites = jsonDecode(response.body);
        for (int i = 0; i < websites.length; ++i) {
          _websites.add(websites[i]['url']);
        }
      } 
      else {
        print("Failed to get websites.");
      }
    }
    catch (e) {
      print(e);
    }
  }

  List<dynamic> _filterGames(games) {
    final badWords = ["bundle", "pack"];
    return games.where((game) => !badWords.any((word) => game['name'].toLowerCase().contains(word))).toList();
  }

  Future<List<dynamic>> _getAdditionalGames(accessToken, games) async {
    try {
      List<dynamic> ids = [];
      for (int i = 0; i < games.length; ++i) {
        ids.add(games[i]['id']);
      }

      final url = Uri.parse("https://api.igdb.com/v4/games");
      final headers = {
        "Client-ID": clientIdIGDB,
        "Authorization": "Bearer $accessToken",
      };
      final body = "fields id,aggregated_rating,artworks,collection,collections,cover,dlcs,first_release_date,franchise,genres,involved_companies,name,rating,remakes,remasters,similar_games,summary,url,websites; where parent_game = (${ids.join(", ")});";
      return http.post(url, headers: headers, body: body).then((response) {
        if (response.statusCode == 200) {
          var dlcsRemakesRemasters = jsonDecode(response.body);
          return _filterGames(dlcsRemakesRemasters);
        } 
        else {
          return [{'error': 'Response code ${response.statusCode}'}];
        }
      });
    }
    catch (e) {
      return [{'error': '$e'}];
    }
  }

  Future<List<Map<String, dynamic>>> _getGames(String gameName) async {
    try {
      _accessToken = await _getAccessToken();

      final url = Uri.parse("https://api.igdb.com/v4/games");
      final headers = {
        "Client-ID": clientIdIGDB,
        "Authorization": "Bearer $_accessToken",
      };
      // version_parent = null -> no editions
      // parent_game = null -> no DLCs, remakes, bundles
      final body =
          "fields id,aggregated_rating,artworks,collection,collections,cover,dlcs,first_release_date,franchise,genres,involved_companies,name,rating,remakes,remasters,similar_games,summary,url,websites; search \"$gameName\"; where version_parent = null & parent_game = null;";
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        var games = jsonDecode(response.body);
        games = _filterGames(games);
        var additionalGames = await _getAdditionalGames(_accessToken, games);
        games.addAll(additionalGames);
        for (int i = 0; i < games.length; ++i) {
          games[i]['name'] = utf8.decode(games[i]['name'].runes.toList());
          if (games[i]['first_release_date'] != null) {
            // Turn the Unix timestamp into a DateTime object
            games[i]['first_release_date'] = DateTime.fromMillisecondsSinceEpoch(games[i]['first_release_date'] * 1000);

            // Add the year to the game name
            games[i]['name'] += " (${games[i]['first_release_date'].year})";

            // Format the date as a string, removing the time
            games[i]['first_release_date'] = games[i]['first_release_date'].toString().substring(0, 10);
          }
          if (games[i]['summary'] != null) {
            games[i]['summary'] =
                utf8.decode(games[i]['summary'].runes.toList());
          }
        }
        return List<Map<String, dynamic>>.from(games);
      } 
      else {
        return [{'error': 'Response code ${response.statusCode}'}];
      }
    }
    catch (e) {
      return [{'error': '$e'}];
    }
  }

  Future<Map<String, dynamic>> editGame(Map<String, dynamic> game) async {
    if (game['aggregated_rating'] != null) {
      game['critic_rating'] = (game['aggregated_rating']).round();
      game.remove('aggregated_rating');
    }
    if (game['artworks'] != null) {
      await _getArtworks(_accessToken, game);
      game['artworks'] = _artwork;
    }
    if (game['cover'] != null) {
      await _getCover(_accessToken, game);
      game['cover'] = _cover;
    }
    if (game['collections'] != null) {
      await _getCollections(_accessToken, game);
      game['collections'] = _collections;
    }
    if (game['franchises'] != null) {
      await _getFranchises(_accessToken, game);
      if (game['collections'] != null) {
        game['collections'] += _franchises;
      }
      else {
        game['collections'] = _franchises;
      }
    }
    if (game['genres'] != null) {
      await _getGenres(_accessToken, game);
      game['genres'] = _genres;
    }
    if (game['involved_companies'] != null) {
      await _getCompanies(_accessToken, game);
      game['developers'] = _developers;
      game['publishers'] = _publishers;
      game.remove('involved_companies');
    }
    if (game['rating'] != null) {
      game['user_rating'] = (game['rating']).round();
      game.remove('rating');
    }
    if (game['websites'] != null) {
      await _getWebsites(_accessToken, game);
      game['websites'] = _websites;
    }
    reset();
    return game;
  }

  // Public methods
  @override
  Future<List<Map<String, dynamic>>> getOptions(String gameName) async {
    return instance._getGames(gameName);
  }

  @override
  Future<Map<String, dynamic>> getInfo(Map<String, dynamic> game) async {
    return instance.editGame(game);
  }
}
