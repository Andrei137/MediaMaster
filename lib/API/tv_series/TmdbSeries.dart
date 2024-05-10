import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../general/Service.dart';
import '../general/Constants.dart';

class TmdbSeries implements Service {
  // Members
  final _headers = {
    "accept": "application/json",
    "Authorization": "Bearer $accessTokenTMDB"
  };
  final _url = Uri.parse("https://api.themoviedb.org/3/search/tv");
  final _genreUrl = Uri.parse("https://api.themoviedb.org/3/genre/tv/list");

  // Private constructor
  TmdbSeries._();

  // Singleton instance
  static final TmdbSeries _instance = TmdbSeries._();

  // Accessor for the singleton instance
  static TmdbSeries get instance => _instance;

  // Private methods
  Future<Map<String, dynamic>> _getEpisodesPerSeason(int tvId) async {
    try {
      final url = Uri.parse("https://api.themoviedb.org/3/tv/$tvId");
      final response = await http.get(url, headers: _headers);
      if (response.statusCode == 200) {
        final series = json.decode(response.body);
        final seasonsInfo = <String, int>{};

        for (var season in series['seasons']) {
          if (season['season_number'] != 0) {
            seasonsInfo[season['season_number'].toString()] =
                season['episode_count'];
          }
        }
        return seasonsInfo;
      } 
      else {
        return {'error': 'Error fetching the number of episodes per season.'};
      }
    }
    catch (e) {
      return {'error': e};
    }
  }
  
  Future<List<Map<String, dynamic>>> _getSeries(String seriesName) async {
    try {
      final params = {
        "query": Uri.encodeQueryComponent(seriesName)
      };
      final response = await http.get(_url.replace(queryParameters: params), headers: _headers);

      if (response.statusCode == 200) {
        final series = json.decode(response.body);

        final options = <Map<String, dynamic>>[];
        for (var tvSeries in series['results']) {
          options.add({
            'id': tvSeries['id'],
            'name': tvSeries['name'],
            'overview': tvSeries['overview'],
            'first_air_date': tvSeries['first_air_date'],
            'genre': tvSeries['genre_ids']
          });
        }

        final genreResponse = await http.get(_genreUrl, headers: _headers);
        if (genreResponse.statusCode == 200) {
          final genres = json.decode(genreResponse.body);

          for (var tvSeries in options) {
            for (var genre in genres['genres']) {
              if (tvSeries['genre'].contains(genre['id'])) {
                tvSeries['genre'].remove(genre['id']);
                tvSeries['genre'].add(genre['name']);
              }
            }
          }
        }

        return options;
      }
      else {
        return [{'error': 'Error fetching TV series.'}];
      }
    }
    catch (e) {
      return [{'error': e}];
    }
  }

  // Public methods
  @override
  Future<List<Map<String, dynamic>>> getOptions(String seriesName) async {
    return instance._getSeries(seriesName);
  }

  @override
  Future<Map<String, dynamic>> getInfo(Map<String, dynamic> series) async {
    final seasonsInfo = await instance._getEpisodesPerSeason(series['id']);

    if (!seasonsInfo.containsKey('error')) {
      series['seasons'] = seasonsInfo;
    }
    return series;
  }
}