import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../general/Service.dart';
import '../general/Constants.dart';

class TmdbMovies implements Service {
  // Members
  final _headers = {
    "accept": "application/json",
    "Authorization": "Bearer $accessTokenTMDB"
  };
  final _url = Uri.parse("https://api.themoviedb.org/3/search/movie");
  final _genreUrl = Uri.parse("https://api.themoviedb.org/3/genre/movie/list");

  // Private constructor
  TmdbMovies._();

  // Singleton instance
  static final TmdbMovies _instance = TmdbMovies._();

  // Accessor for the singleton instance
  static TmdbMovies get instance => _instance;

  // Private methods
  Future<List<Map<String, dynamic>>> _getMovies(String movieName) async {
    try {
      final params = {
        "query": Uri.encodeQueryComponent(movieName)
      };
      final response = await http.get(_url.replace(queryParameters: params), headers: _headers);

      if (response.statusCode == 200) {
        final movies = json.decode(response.body);

        final options = <Map<String, dynamic>>[];
        for (var movie in movies['results']) {
          options.add({
            'name': movie['title'],
            'overview': movie['overview'],
            'release_date': movie['release_date'],
            'rating': movie['vote_average'],
            'genre': movie['genre_ids'],
            'original_language': movie['original_language']
          });

          final genreResponse = await http.get(_genreUrl, headers: _headers);

          if (genreResponse.statusCode == 200) {
            final genres = json.decode(genreResponse.body);

            for (var genre in genres['genres']) {
              if (movie['genre_ids'].contains(genre['id'])) {
                options.last['genre'].remove(genre['id']);
                options.last['genre'].add(genre['name']);
              }
            }
          }
        }
        return options;
      }
      else {
        return [];
      }
    }
    catch (e) {
      return [];
    }
  }

  // Public methods
  @override
  Future<List<Map<String, dynamic>>> getOptions(String movieName) async {
    return instance._getMovies(movieName);
  }

  @override
  Future<Map<String, dynamic>> getInfo(Map<String, dynamic> book) async {
    return book;
  }
}