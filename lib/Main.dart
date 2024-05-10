import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'Utils.dart';
import 'package:pair/pair.dart';

import 'Models/seed_data.dart';
import 'Models/database_adapters.dart';
import 'Models/game.dart';
import 'Models/genre.dart';
import 'Models/media.dart';
import 'Models/media_user.dart';
import 'Models/tag.dart';

import 'UserSystem.dart';

import 'Testing/test_db_relationships.dart';

void main() async {
  await initHiveAndAdapters();
  bool testing = false;

  if(testing) {
    testAllRelationships();
  }
  else {
    addSeedData();

    runApp(
      MaterialApp(
        title: 'MediaMaster',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyApp(),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {  
  int selectedGameIndex = 0;
  String filterQuery = "";
  TextEditingController searchController = TextEditingController();
  bool increasingSorting = true;
  int selectedSortingMethod = 0;
  var gameOrderComparators = [
    Pair<String, dynamic>(
      "By original name",
      (Game a, Game b, int increasing) {
        return increasing * a.media.originalName.compareTo(b.media.originalName);
      },
    ),
    Pair<String, dynamic>(
      "By critic score",
      (Game a, Game b, int increasing) {
        return increasing * a.media.criticScore.compareTo(b.media.criticScore);
      },
    ),
    Pair<String, dynamic>(
      "By comunity score",
      (Game a, Game b, int increasing) {
        return increasing * a.media.communityScore.compareTo(b.media.communityScore);
      },
    ),
    Pair<String, dynamic>(
      "By release date",
      (Game a, Game b, int increasing) {
        return increasing * a.media.releaseDate.compareTo(b.media.releaseDate);
      },
    ),
    Pair<String, dynamic>(
      "By time to beat",
      (Game a, Game b, int increasing) {
        int ta = a.getMinTimeToBeat();
        int tb = b.getMinTimeToBeat();

        if(tb == -1) {
          return -1;
        }
        if(ta == -1) {
          return 1;
        }
        return increasing * ta.compareTo(tb);
      },
    ),
    Pair<String, dynamic>(
      "By time to 100%",
      (Game a, Game b, int increasing) {
        if(b.HLTBCompletionistInSeconds == -1) {
          return -1;
        }
        if(a.HLTBCompletionistInSeconds == -1) {
          return 1;
        }
        return increasing * a.HLTBCompletionistInSeconds.compareTo(b.HLTBCompletionistInSeconds);
      },
    ),
  ];
  bool filterAll = true;
  Set<int> selectedGenres = {}, selectedTags = {};

  // Placeholder image URL
  static const String placeholderImageUrl =
      'https://uncensoredtactical.com/wp-content/uploads/2021/04/Placeholder-1920x1080-1.jpg';

  @override
  void initState() {
    super.initState();
    UserSystem().loadUserContent();
  }

  ListView mediaListBuilder(BuildContext context, Box<MediaUser> _, Widget? __) {
    List<ListTile> listTiles = List.from([]);
    List<Game> userGames = UserSystem().getUserGames();
    List<Pair<Game, int> > gamesIndices = List.from([]);

    for(int i = 0;i < userGames.length;++i) {
      gamesIndices.add(Pair(userGames[i], i));
    }

    gamesIndices.sort(
      (p0, p1) {
        return gameOrderComparators[selectedSortingMethod].value(
          p0.key,
          p1.key,
          increasingSorting ? 1 : -1,
        );
      }
    );

    for(int i = 0;i < gamesIndices.length;++i) {
      final game = gamesIndices[i].key;
      final idx = gamesIndices[i].value;
      if(filterQuery == "" || game.media.originalName.toLowerCase().contains(filterQuery)) {
        listTiles.add(
          ListTile(
            title: Text(
              game.media.originalName
            ),
            onTap: () {
              setState(() {
                selectedGameIndex = idx;
              });
            },
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _showDeleteConfirmationDialog(
                  context,
                  idx,
                );
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

  void _setSearchText() {
    filterQuery = searchController.text.toLowerCase();
  }

  void _clearSearchFilter() {
    filterQuery = '';
  }

  Game? gameAlreadyInDB(String gameName) {
    Box<Game> games = Hive.box<Game>('games');
    for(int i = 0;i < games.length;++i) {
      if(games.getAt(i)!.media.originalName == gameName) {
        return games.getAt(i);
      }
    }

    return null;
  }

  bool gameAlreadyInLibrary(String gameName) {
    for(Game libgame in UserSystem().getUserGames()) {
      if(gameName == libgame.media.originalName) {
        return true;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    _setSearchText();

    IconButton? butonSearchReset;
    if(filterQuery == "") {
      butonSearchReset = IconButton(
        onPressed: () {/*TODO: The search box gets activated only if you hold down at least 2 frames, I do not know the function to activate it when pressing this button. I also do not know if this should be our priority right now*/},
        icon: const Icon(Icons.search),
      );
    }
    else {
      butonSearchReset = IconButton(
        onPressed: () {
          setState(() {
            _clearSearchFilter();
            searchController.clear();
          });
        },
        icon: const Icon(Icons.clear),
      );
    }

    TextField textField = TextField(
      controller: searchController,
      onChanged: (value) {setState(() {});},
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        hintText: "Search game in library",
        suffixIcon: butonSearchReset,
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
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        _showSortGamesDialog(context);
                      },
                      icon: const Icon(Icons.sort),
                      tooltip: 'Sort games',
                    ),
                    IconButton(
                      onPressed: () {
                        _showFilterGamesDialog(context);
                      },
                      icon: const Icon(Icons.filter_alt),
                      tooltip: 'Filter games',
                    ),
                    IconButton(
                      onPressed: () {
                        _darkModeToggle(context);
                      },
                      icon: const Icon(Icons.dark_mode),
                      tooltip: 'Toggle dark mode',
                    ),
                    IconButton(
                      onPressed: () {
                        _showSettingsDialog(context);
                      },
                      icon: const Icon(Icons.settings),
                      tooltip: 'Settings',
                    ),
                  ],
                ),
                  Row(
                    children: [
                      SizedBox(
                        child: IconButton(
                        onPressed: () {
                          _showSearchGameDialog(context);
                        },
                        icon: const Icon(Icons.add_circle),
                        tooltip: 'Add Game to Library',
                      ),
                      ),
                      Expanded(
                        child: textField,
                      ),
                      const SizedBox(
                        width: 5,
                      )
                    ],
                  ),
                Expanded(
                  //color: Colors.grey[200],
                  child: ValueListenableBuilder(
                    valueListenable: Hive.box<MediaUser>('media-users').listenable(),
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
                    UserSystem().getUserGames().isNotEmpty ? UserSystem().getUserGames()[selectedGameIndex].media.originalName : '',
                    style: const TextStyle(color: Colors.white, fontSize: 24.0),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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

                                if(gameAlreadyInLibrary(gameName)) {
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

  Future<void> _showSortGamesDialog(BuildContext context) {
    // Helper function, should be called when a variable gets changed
    void resetState() {
      setState(() {});
    }

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Sort games'),
              content: SizedBox(
                height: 300,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Text(
                        'Sort direction',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: increasingSorting,
                            onChanged: (value) {
                              setState(() {
                                if(value == true) {
                                  increasingSorting = true;
                                  resetState();
                                }
                              });
                            },
                          ),
                          const Text(
                            'Increasing',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: !increasingSorting,
                            onChanged: (value) {
                              setState(() {
                                if(value == true) {
                                  increasingSorting = false;
                                  resetState();
                                }
                              });
                            },
                          ),
                          const Text(
                            'Decreasing',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Sort parameter',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      for(int i = 0;i < gameOrderComparators.length;++i)
                        Row(
                          children: [
                            Checkbox(
                              value: i == selectedSortingMethod,
                              onChanged: (value) {
                                setState(() {
                                  if(value == true) {
                                    selectedSortingMethod = i;
                                    resetState();
                                  }
                                });
                              },
                            ),
                            Text(
                              gameOrderComparators[i].key,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }
    );
  }

  Future<void> _showFilterGamesDialog(BuildContext context) {
    // Helper function, should be called when a variable gets changed
    void resetState() {
      setState(() {});
    }

    var tags = Hive.box<Tag>('tags');
    var genres = Hive.box<Genre>('genres');

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Filter games'),
              content: SizedBox(
                height: 400,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Text(
                        'Filter type',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: filterAll,
                            onChanged: (value) {
                              setState(() {
                                if(value == true) {
                                  filterAll = true;
                                  resetState();
                                }
                              });
                            },
                          ),
                          const Text(
                            'All',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: !filterAll,
                            onChanged: (value) {
                              setState(() {
                                if(value == true) {
                                  filterAll = false;
                                  resetState();
                                }
                              });
                            },
                          ),
                          const Text(
                            'Any',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text(
                            'Genres',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () => setState(() {
                              selectedGenres.clear();
                              resetState();
                            }),
                            icon: const Icon(
                              Icons.clear,
                            ),
                          ),
                        ],
                      ),
                      for(int i = 0;i < genres.length;++i)
                        Row(
                          children: [
                            Checkbox(
                              value: selectedGenres.contains(i),
                              onChanged: (value) {
                                setState(() {
                                  if(value == true) {
                                    selectedGenres.add(i);
                                  }
                                  else {
                                    selectedGenres.remove(i);
                                  }
                                  resetState();
                                });
                              },
                            ),
                            Text(
                              genres.getAt(i)!.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      Row(
                        children: [
                          const Text(
                            'Tags',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () => setState(() {
                              selectedTags.clear();
                              resetState();
                            }),
                            icon: const Icon(
                              Icons.clear,
                            ),
                          ),
                        ],
                      ),
                      for(int i = 0;i < tags.length;++i)
                        Row(
                          children: [
                            Checkbox(
                              value: selectedTags.contains(i),
                              onChanged: (value) {
                                setState(() {
                                  if(value == true) {
                                    selectedTags.add(i);
                                  }
                                  else {
                                    selectedTags.remove(i);
                                  }
                                  resetState();
                                });
                              },
                            ),
                            Text(
                              tags.getAt(i)!.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                    ], // -------------------------------------------------------------------
                  ),
                ),
              ),
            );
          },
        );
      }
    );
  }

  void _darkModeToggle(BuildContext context) {
    // TODO: Implement this
  }

  void _showSettingsDialog(BuildContext context) {
    // TODO: Implement this
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
                Game gameToDelete = UserSystem().getUserGames()[index];
                for(MediaUser mu in UserSystem().currentUserMedia) {
                  if(mu.media == gameToDelete.media) {
                    UserSystem().currentUserMedia.remove(mu);
                    Hive.box<MediaUser>('media-users').delete(mu);
                    break;
                  }
                }
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

  Future<void> _addGame(String gameName) async {
    if(UserSystem().currentUser == null) {
      return;
    }

    Game? nullableGame = gameAlreadyInDB(gameName);

    if(nullableGame == null) {
      print("newForDB");
      Media media = Media(
        originalName: gameName,
        description: "Add parameter/call to API for description here.",
        releaseDate: DateTime.now() /*Add parameter/call to API for release date here.*/,
        criticScore: -1 /*Add parameter/call to API for critic score here.*/,
        communityScore: -1 /*Add parameter/call to API for comunity score here.*/,
        mediaType: "Game",
      );
      Game newGame = Game(
        mediaId: media.id,
        parentGameId: -1 /*Add parameter/call to API to check if this is a DLC*/,
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
      await Hive.box<Media>('media').add(media);
      await Hive.box<Game>('games').add(newGame);
      nullableGame = newGame;
    }

    Game game = nullableGame;

    if(!gameAlreadyInLibrary(game.media.originalName)) {
      print("newForMe");
      MediaUser mu = MediaUser(
        mediaId: game.mediaId,
        userId: UserSystem().currentUser!.id,
        name: game.media.originalName,
        userScore: -1,
        addedDate: DateTime.now(),
        coverImage: "placeholder.png" /*Add a basic cover image*/,
        status: "Plan To Play",
        series: game.media.originalName /*Add parameter/call to game series API*/,
        icon: "placeholder.png" /*Add a basic cover image*/,
        backgroundImage: "placeholder.png" /*Add a basic cover image*/,
        lastInteracted: DateTime.now(),
      );

      UserSystem().currentUserMedia.add(mu);
      await Hive.box<MediaUser>('media-users').add(mu);
    }
  }
}
