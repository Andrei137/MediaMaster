import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'package:dart_console/dart_console.dart';
import 'general/Constants.dart';
import 'general/ServiceHandler.dart';
import 'general/ServiceBuilder.dart';
import 'games/PcGamingWiki.dart';

final console = Console();

int getUserInput(List<Map<String, dynamic>> options) {
  try {
    console.clearScreen();
    print("Choose a game:");
    for (int i = 0; i < options.length; ++i) {
      print("[${i + 1}] ${options[i]['name']}");
    }
    stdout.write("\nEnter the number of the game: ");
    final choice = stdin.readLineSync();
    console.clearScreen();
    
    if (choice != null) {
      final index = int.parse(choice);
      if (index > 0 && index <= options.length) {
        return index;
      }
      else {
        return 0;
      }
    }
    else {
      return 0;
    }
  }
  catch (e) {
    return 0;
  }
}

Future<void> main() async {
  console.clearScreen();
  String query = "Harry Potter";
  bool running = true;
  while (running)
  {
    print("Choose an option:");
    print("[1] IGDB (Games)");
    print("[2] PcGamingWiki (Game System Requirements)");
    print("[3] HowLongToBeat (Game Times)");
    print("[4] Goodreads (Books)");
    print("[5] TMDB (TV Series)");
    print("[6] TMDB (Movies)");
    print("[9] Change query (Current: $query)");
    print("[0] Exit");
    stdout.write("\nEnter your choice: ");
    var choice = stdin.readLineSync() ?? '';
    console.clearScreen();
    switch (choice) {
      case '1':
        // await igdbGames(query);
        break;
      case '2':
        // final systemRequirements = await PcGamingWiki.search(query);
        // print(systemRequirements);
        break;
      case '3':
        ServiceBuilder.setHowLongToBeat();
        break;
      case '4':
        // await goodreads(query);
        break;
      case '5':
        // await tmdbSeries(query);
        break;
      case '6':
        // await tmdbMovies(query);
        break;
      case '9':
        stdout.write("New query: ");
        query = stdin.readLineSync() ?? '';
        break;
      case '0':
        running = false;
        break;
      default:
        print("Invalid choice.");
        break;
    }
    if (running && choice == '3')
    {
      final options = await ServiceHandler.getOptions(query);
      final index = getUserInput(options);
      if (index != 0) {
        final answer = await ServiceHandler.search(options[index - 1]);
        print(answer);
      } 
      stdout.write("\nPress Enter to continue...");
      stdin.readLineSync();
    }
    console.clearScreen();
  }
}

Future<void> igdbGames(String gameName) async {
  try {
    // Prepare the token request
    final tokenUrl = Uri.parse("https://id.twitch.tv/oauth2/token");
    final tokenParams = {
      "client_id": clientIdIGDB,
      "client_secret": clientSecretIGDB,
      "grant_type": "client_credentials"
    };

    // Call the IGDB API
    final tokenResponse = await http.post(tokenUrl, body: tokenParams);
    if (tokenResponse.statusCode == 200) {
      // If the call to the API was successful, get the access token
      final accessToken = jsonDecode(tokenResponse.body)["access_token"];

      // Prepare the game request
      final gameUrl = Uri.parse("https://api.igdb.com/v4/games");
      final gameHeaders = {
        "Client-ID": clientIdIGDB,
        "Authorization": "Bearer $accessToken",
      };
      // version_parent = null -> no editions
      // parent_game = null -> no DLCs
      final gameBody = "fields id,aggregated_rating,artworks,collection,collections,cover,first_release_date,franchise,genres,involved_companies,name,platforms,rating,summary,tags,total_rating,url,websites; search \"$gameName\"; where version_parent = null & parent_game = null;";

      final gameResponse = await http.post(gameUrl, headers: gameHeaders, body: gameBody);
      if (gameResponse.statusCode == 200) {
        // If the call to the API was successful, let the user choose a game
        var games = jsonDecode(gameResponse.body);
        console.clearScreen();
        print("Choose a game:");
        for (int i = 0; i < games.length; ++i) {
            games[i]['name'] = utf8.decode(games[i]['name'].runes.toList());
            if (games[i]['summary'] != null)
            {
              games[i]['summary'] = utf8.decode(games[i]['summary'].runes.toList());
            }
            print("${i + 1}. ${games[i]['name']}");
        }
        stdout.write("\nEnter the number of the game: ");
        final choice = stdin.readLineSync();
        console.clearScreen();

        // Validate the user input
        if (choice != null) {
          final index = int.parse(choice);
          if (index > 0 && index <= games.length) {
            final collectionUrl = Uri.parse("https://api.igdb.com/v4/collections");
            final collectionBody = "fields name; here id = ${games[index - 1]['collection']};";

            final collectionResponse = await http.post(collectionUrl, headers: gameHeaders, body: collectionBody);
            if (collectionResponse.statusCode == 200) 
            {
              final collection = jsonDecode(collectionResponse.body);
              games[index - 1]['collection'] = collection[0]['name'];
            }

            print(games[index - 1]);
          } 
          else {
            print('Invalid choice.');
          }
        }
      } 
      else {
        print("Error: ${gameResponse.statusCode}");
      }
    } 
    else {
      print("Error: ${tokenResponse.statusCode}");
    }
  } 
  catch (e) {
    print("Error: $e");
  }
}

Future<void> goodreads(String bookName) async {
  final bookHeaders = {
    'User-Agent': userAgentsGoodreads
  };

  Future<void> printBookDetails(var book) async {
    final bookResponse = await http.get(Uri.parse(book['bookLink']), headers: bookHeaders);
    if (bookResponse.statusCode == 200) {
      // If the call to the API was successful, get the book details
      final document = parse(bookResponse.body);
      final pagesFormat = document.querySelector('p[data-testid="pagesFormat"]');
      final numPages = pagesFormat?.text?.trim().split(' ')[0] ?? "Unknown";
      final publicationInfo = document.querySelector('p[data-testid="publicationInfo"]')?.text?.trim().split('First published ')?.last ?? "Unknown";
      final description = document.querySelector('span.Formatted')?.text?.trim() ?? "Unknown";
      final scriptTag = document.querySelector('script[type="application/ld+json"]');
      final jsonData = json.decode(scriptTag?.text ?? "{}");
      final bookFormat = jsonData['bookFormat'] ?? 'Unknown';
      final language = jsonData['inLanguage'] ?? 'Unknown';

      print("Title: ${book['title']}");
      print("Author: ${book['author']}");
      print("Average Rating: ${book['avgRating']}");
      print("Number of Pages: $numPages");
      print("Publication Info: $publicationInfo");
      print("Description: $description");
      print("Book Format: $bookFormat");
      print("Language: $language");
    } else {
      print("No data found.");
    }
  }

  final bookUrl = "https://www.goodreads.com/search?q=$bookName";

  final bookResponse = await http.get(Uri.parse(bookUrl), headers: bookHeaders);
  if (bookResponse.statusCode == 200) {
    // If the search was successful, parse the results
    final document = parse(bookResponse.body);

    final books = <Map<String, dynamic>>[];
    for (var book in document.querySelectorAll('tr[itemtype="http://schema.org/Book"]')) {
      final title = book.querySelector('a.bookTitle')?.text?.trim() ?? "Unknown";
      final author = book.querySelector('a.authorName')?.text?.trim() ?? "Unknown";
      final ratingText = book.querySelector('span.minirating')?.text?.trim() ?? "Unknown";
      final avgRating = ratingText.split('avg rating —')[0].trim();
      final bookLink = "https://www.goodreads.com${book.querySelector('a.bookTitle')?.attributes['href'] ?? ""}";

      books.add({
        'title': title,
        'author': author,
        'avgRating': avgRating,
        'bookLink': bookLink,
      });
    }

    // Let the user choose a book
    console.clearScreen();
    print("Choose a book:");
    for (var i = 0; i < books.length; i++) {
      print("${i + 1}. ${books[i]['title']} by ${books[i]['author']}");
    }
    stdout.write("\nEnter the number of the book: "); 
    final choice = stdin.readLineSync();
    console.clearScreen();

    // Validate the user input
    if (choice != null) {
      final index = int.parse(choice);
      if (index > 0 && index <= books.length) {
        await printBookDetails(books[index - 1]);
      } 
      else {
        print('Invalid choice.');
      }
    }
  } 
  else {
    print("No data found.");
  }
}

Future<void> tmdbSeries(String seriesName) async {
  final seriesHeaders = {
    "accept": "application/json",
    "Authorization": "Bearer $accessTokenTMDB"
  };

  Future<Map<String, dynamic>?> getEpisodesPerSeason(int tvId) async {
    // Call the TMDB API
    final seriesUrl = Uri.parse("https://api.themoviedb.org/3/tv/$tvId");

    final seriesResponse = await http.get(seriesUrl, headers: seriesHeaders);
    if (seriesResponse.statusCode == 200) {
      // If the call to the API was successful, get the number of episodes per season
      final series = json.decode(seriesResponse.body);
      final seasonsInfo = <String, dynamic>{};

      for (var season in series['seasons']) {
        if (season['season_number'] != 0) {
          seasonsInfo[season['season_number'].toString()] = season['episode_count'];
        }
      }
      return seasonsInfo;
    } 
    else {
      return null;
    }
  }

  try
  {
    // Call the TMDB API
    final seriesUrl = Uri.parse("https://api.themoviedb.org/3/search/tv");
    final seriesParams = {
      "query": Uri.encodeQueryComponent(seriesName)
    };

    final seriesResponse = await http.get(seriesUrl.replace(queryParameters: seriesParams), headers: seriesHeaders);
    if (seriesResponse.statusCode == 200) {
      // If the call to the API was successful, get the series
      final series = json.decode(seriesResponse.body);

      console.clearScreen();
      print("Choose a TV series:");
      for (int i = 0; i < series['results'].length; ++i) {
        print("${i + 1}. ${series['results'][i]['name']}");
      }
      stdout.write("\nEnter the number of the TV series: ");
      final choice = stdin.readLineSync();
      console.clearScreen();

      // Validate the user input
      if (choice != null) {
        final index = int.parse(choice);
        if (index > 0 && index <= series['results'].length) {
          final tvId = series['results'][index - 1]['id'];
          final seasonsInfo = await getEpisodesPerSeason(tvId);

          print("Name: ${series['results'][index - 1]['name']}");
          print("Overview: ${series['results'][index - 1]['overview']}");
          print("First Air Date: ${series['results'][index - 1]['first_air_date']}");

          if (seasonsInfo != null) {
            print("Episodes per Season:");
            seasonsInfo.forEach((season, episodes) {
              print("Season $season: $episodes episodes");
            });
          }
        } 
        else {
          print('Invalid choice.');
        }
      }
    }
  }
  catch (e) {
    print("Error: $e");
  }
}

Future<void> tmdbMovies(String movieName) async {
  try
  {
    // Prepare the movie request
    final movieUrl = Uri.parse("https://api.themoviedb.org/3/search/movie");
    final movieParams = {
      "query": Uri.encodeQueryComponent(movieName)
    };
    final movieHeaders = {
      "accept": "application/json",
      "Authorization": "Bearer $accessTokenTMDB"
    };

    final movieResponse = await http.get(movieUrl.replace(queryParameters: movieParams), headers: movieHeaders);
    if (movieResponse.statusCode == 200) {
      // If the call to the API was successful, let the user choose a movie
      final movies = json.decode(movieResponse.body);
        
      console.clearScreen();
      print("Choose a movie:");
      for (int i = 0; i < movies['results'].length; ++i) {
        print("${i + 1}. ${movies['results'][i]['title']}");
      }
      stdout.write("\nEnter the number of the movie: ");
      final choice = stdin.readLineSync();
      console.clearScreen();

      // Validate the user input
      if (choice != null) {
        final index = int.parse(choice);
        if (index > 0 && index <= movies['results'].length) {
          print("Title: ${movies['results'][index - 1]['title']}");
          print("Overview: ${movies['results'][index - 1]['overview']}");
          print("Release Date: ${movies['results'][index - 1]['release_date']}");
          print("Rating: ${movies['results'][index - 1]['vote_average']}");
          print("Vote Count: ${movies['results'][index - 1]['vote_count']}");
        } 
        else {
          print('Invalid choice.');
        }
      }
    } 
    else {
      print("Error: ${movieResponse.statusCode}");
    }
  }
  catch (e) {
    print("Error: $e");
  }
}