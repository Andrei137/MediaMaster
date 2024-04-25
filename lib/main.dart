import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'utils.dart';
import 'package:pair/pair.dart';

import 'Models/media.dart';
import 'Models/game.dart';
import 'Models/database_adapters.dart';

import 'Testing/test_db_relationships.dart';

void main() async {
  await initHiveAndAdapters();

  testAllRelationships();

  runApp(MaterialApp(
    title: 'MediaMaster',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  late Box<Game> gameBox;
  int selectedGameIndex = 0;
  String filterQuery = "";
  TextEditingController searchController = TextEditingController();

  // Placeholder image URL
  static const String placeholderImageUrl =
      'https://uncensoredtactical.com/wp-content/uploads/2021/04/Placeholder-1920x1080-1.jpg';

  @override
  void initState() {
    super.initState();
    gameBox = Hive.box<Game>('games');
  }

  ListView mediaListBuilder(BuildContext context, Box<Game> box, Widget? _)
  {
    List<ListTile> listTiles = List.from([]);
    List<Pair<Game, int> > gamesIndices = List.from([]);

    for(int i = 0;i < box.length;++i) {
      gamesIndices.add(Pair(box.getAt(i)!, i));
    }

    gamesIndices.sort((p0, p1) => p0.key.media.originalName.compareTo(p1.key.media.originalName));

    for(int i = 0;i < gamesIndices.length;++i) {
      final game = gamesIndices[i].key;
      final idx = gamesIndices[i].value;
      if(filterQuery == "" || game.media.originalName.toLowerCase().contains(filterQuery)) {
        listTiles.add(
          ListTile(
            title: Text(game.media.originalName),
            onTap: () {
              setState(() {
                selectedGameIndex = idx;
              });
            },
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _showDeleteConfirmationDialog(context, idx);
              },
            ),
          ),
        );
      }
    }

    return ListView(
      children: listTiles,
    );
  }

  void setSearchText() {
    filterQuery = searchController.text.toLowerCase();
  }

  void clearSearchFilter() {
    filterQuery = '';
  }

  Game? gameAlreadyInLibrary(String gameName) {
    for(Game game in gameBox.values) {
      if(game.media.originalName == gameName) {
        return game;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    setSearchText();

    IconButton? butonReset = IconButton(
                              onPressed: () {
                                setState(() {
                                  clearSearchFilter();
                                  searchController.clear();
                                });
                              },
                              icon: const Icon(Icons.clear),
                            );
    if(filterQuery == "") {
      butonReset = null;
    }

    TextField textField = TextField(
      controller: searchController,
      onChanged: (value) {setState(() {});},
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        hintText: "Search game in library",
        suffixIcon: butonReset,
      ),
    );
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('MediaMaster'),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                SizedBox(
                  child: textField,
                ),
                Expanded(
                  //color: Colors.grey[200],
                  child: ValueListenableBuilder(
                    valueListenable: gameBox.listenable(),
                    builder: mediaListBuilder,
                  ),
                ),
              ],
            )
          ),
          Expanded(
            flex: 10,
            child: Container(
              decoration: const /*We currently don't have "backgroundImage", thus the following is const. Remove const when we add the image*/ BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    // gameBox.isNotEmpty ? gameBox.getAt(selectedGameIndex)!.backgroundImage : placeholderImageUrl
                    placeholderImageUrl
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Text(
                    gameBox.isNotEmpty ? gameBox.getAt(selectedGameIndex)!.media.originalName : '',
                    style: const TextStyle(color: Colors.white, fontSize: 24.0),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showSearchGameDialog(context);
        },
        tooltip: 'Add Game to Library',
        child: const Icon(Icons.download),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  Future<void> _showSearchGameDialog(BuildContext context) async {
    TextEditingController searchController = TextEditingController();
    List<dynamic> searchResults = [];

    bool noSearch = true; // Flag to track if there are no search results

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Search for a Game'),
              content: SizedBox(
                height: noSearch ? 100 : 400, // Set height based on the presence of search results
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        labelText: 'Game Name',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () async {
                            String query = searchController.text;
                            if (query.isNotEmpty) {
                              searchResults = await _searchGame(query);
                              setState(() {
                                noSearch = searchResults.isEmpty; // Update noSearch flag
                              }); // Trigger rebuild to show results and update flag
                            }
                          },
                        ),
                      ),
                    ),
                    if (searchResults.isNotEmpty)
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              const SizedBox(height: 2),
                              ...searchResults.map((result) {
                                String gameName = result['title'];

                                if(gameAlreadyInLibrary(gameName) != null /*Add here a check that the game is actually in the user's library, not the general one*/) {
                                    return ListTile(
                                    title: Text(gameName),
                                    subtitle: const Text(
                                      "Game is already in library",
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 255, 0, 0),
                                      ),
                                    ),
                                    onTap: () {
                                      _addGame(gameName);
                                      Navigator.of(context).pop();
                                    },
                                  );
                                }
                                else {
                                  return ListTile(
                                    title: Text(gameName),
                                    onTap: () {
                                      _addGame(gameName);
                                      Navigator.of(context).pop();
                                    },
                                  );
                                }
                              }),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<List<dynamic>> _searchGame(String query) async {

    final String url =
        'https://www.pcgamingwiki.com/w/api.php?action=query&format=json&list=search&srsearch=${Utils.httpify(query)}';

    try {
      final http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['query']['search'];
      } else {
        throw Exception('Failed to search for game: ${response.statusCode}');
      }
    } catch (error) {
      print('Error searching game: $error');
      return [];
    }
  }

  Future<void> _addGame(String gameName) async {
    Game? nullableGame = gameAlreadyInLibrary(gameName);

    if(nullableGame == null) {
      Game newGame = Game(
        media: Media(
          originalName: gameName,
          description: "Add parameter/call to API for description here.",
          releaseDate: DateTime.now() /*Add parameter/call to API for release date here.*/,
          criticScore: -1 /*Add parameter/call to API for critic score here.*/,
          communityScore: -1 /*Add parameter/call to API for comunity score here.*/,
          mediaType: "Game",
        ),
        parentGame: null /*Add parameter/call to API to check if this is a DLC*/,
        OSMinimum: "Minimum OS not implemented yet" /*Add parameter/call to System Requirement service API*/,
        OSRecommended: "Recommended OS not implemented yet" /*Add parameter/call to System Requirement service API*/,
        CPUMinimum: "Minimum CPU not implemented yet" /*Add parameter/call to System Requirement service API*/,
        CPURecommended: "Recommended CPU not implemented yet" /*Add parameter/call to System Requirement service API*/,
        RAMMinimum: "Minimum RAM not implemented yet" /*Add parameter/call to System Requirement service API*/,
        RAMRecommended: "Recommended RAM not implemented yet" /*Add parameter/call to System Requirement service API*/,
        HDDMinimum: "Minimum HDD not implemented yet" /*Add parameter/call to System Requirement service API*/,
        HDDRecommended: "Recommended HDD not implemented yet" /*Add parameter/call to System Requirement service API*/,
        GPUMinimum: "Minimum GPU not implemented yet" /*Add parameter/call to System Requirement service API*/,
        GPURecommended: "Recommended GPU not implemented yet" /*Add parameter/call to System Requirement service API*/,
        HLTBMainInSeconds: -1 /*Add parameter/call to HLTB service API*/,
        HLTBMainSideInSeconds: -1 /*Add parameter/call to HLTB service API*/,
        HLTBCompletionistInSeconds: -1 /*Add parameter/call to HLTB service API*/,
        HLTBAllStylesInSeconds: -1 /*Add parameter/call to HLTB service API*/,
        HLTBSoloInSeconds: -1 /*Add parameter/call to HLTB service API*/,
        HLTBCoopInSeconds: -1 /*Add parameter/call to HLTB service API*/,
        HLTBVersusInSeconds: -1 /*Add parameter/call to HLTB service API*/,
        HLTBSingleplayerInSeconds: -1 /*Add parameter/call to HLTB service API*/,
      );
      gameBox.add(newGame);
      nullableGame = newGame;
    }

    // TODO: Decoment the following lines when "Current User System" is implemented

    // Game game = nullableGame;

    // if(true/*Add a check that the user does not have the game in the personal library*/) {
    //   Box<MediaUser> box = Hive.box('media-users');
    //   box.add(
    //     MediaUser(
    //       media: game.media,
    //       user: currentUser /*We currently don't have this, so decoment when we do*/,
    //       name: game.media.originalName,
    //       userScore: 0,
    //       addedDate: DateTime.now(),
    //       coverImage: "placeholder.png" /*Add a basic cover image*/,
    //       status: "Plan To Play",
    //       series: game.media.originalName /*Add parameter/call to game series API*/,
    //       icon: "placeholder.png" /*Add a basic cover image*/,
    //       backgroundImage: "placeholder.png" /*Add a basic cover image*/,
    //       lastInteracted: DateTime.now(),
    //     ),
    //   );
    // }
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context, int index) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Game'),
          content: const Text('Are you sure you want to delete this game?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                gameBox.deleteAt(index);
                setState(() {
                  selectedGameIndex = 0; // Move to the first game
                });
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
