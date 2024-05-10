import 'dart:io';
import 'dart:async';
import 'package:dart_console/dart_console.dart';
import 'general/Constants.dart';
import 'general/ServiceHandler.dart';
import 'general/ServiceBuilder.dart';

final console = Console();

int getUserInput(List<Map<String, dynamic>> options) {
  try {
    console.clearScreen();
    print("Choose an option:");
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
  String query = "Hollow Knight";
  bool running = true;
  while (running) {
    print("Choose an option:");
    print("[1] IGDB (Games)");
    print("[2] PcGamingWiki (Game System Requirements)");
    print("[3] HowLongToBeat (Game Times)");
    print("[4] Goodreads (Books)");
    print("[5] TMDB (Movies)");
    print("[6] TMDB (TV Series)");
    print("[9] Change query (Current: $query)");
    print("[0] Exit");
    stdout.write("\nEnter your choice: ");
    var choice = stdin.readLineSync() ?? '';
    console.clearScreen();
    switch (choice) {
      case '1':
        ServiceBuilder.setIgdb();
        break;
      case '2':
        ServiceBuilder.setPcGamingWiki();
        break;
      case '3':
        ServiceBuilder.setHowLongToBeat();
        break;
      case '4':
        ServiceBuilder.setGoodReads();
        break;
      case '5':
        ServiceBuilder.setTmdbMovies();
        break;
      case '6':
        ServiceBuilder.setTmdbSeries();
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
    if (running && choice != '9') {
      final options = await ServiceHandler.getOptions(query);
      final index = getUserInput(options);
      if (index != 0) {
        final answer = await ServiceHandler.getInfo(options[index - 1]);
        print(answer);
      }
      stdout.write("\nPress Enter to continue...");
      stdin.readLineSync();
    }
    console.clearScreen();
  }
}
