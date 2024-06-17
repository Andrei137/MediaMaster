import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:mediamaster/Models/note.dart';
import 'package:pair/pair.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'API/general/ServiceHandler.dart';
import 'API/general/ServiceBuilder.dart';

import 'Models/game.dart';
import 'Models/genre.dart';
import 'Models/creator.dart';
import 'Models/media.dart';
import 'Models/media_user_tag.dart';
import 'Models/media_user_genre.dart';
import 'Models/media_publisher.dart';
import 'Models/media_platform.dart';
import 'Models/media_creator.dart';
import 'Models/platform.dart';
import 'Models/publisher.dart';
import 'Models/tag.dart';
import 'Models/wishlist.dart';

import 'Main.dart';
import 'UserSystem.dart';
import 'GameLibrary.dart';

class MyWishlist extends StatefulWidget {
  const MyWishlist({super.key});

  @override
  MyWishlistState createState() => MyWishlistState();
}

class MyWishlistState extends State<MyWishlist> {
  int selectedGameIndex = 0;
  String filterQuery = "";
  TextEditingController searchController = TextEditingController();
  bool increasingSorting = true;
  int selectedSortingMethod = 0;
  var gameOrderComparators = [
    Pair<String, dynamic>(
      "By original name",
      (Game a, Game b, int increasing) {
        return increasing *
            a.media.originalName.compareTo(b.media.originalName);
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
        return increasing *
            a.media.communityScore.compareTo(b.media.communityScore);
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

        if (tb == -1) {
          return -1;
        }
        if (ta == -1) {
          return 1;
        }
        return increasing * ta.compareTo(tb);
      },
    ),
    Pair<String, dynamic>(
      "By time to 100%",
      (Game a, Game b, int increasing) {
        if (b.HLTBCompletionistInSeconds == -1) {
          return -1;
        }
        if (a.HLTBCompletionistInSeconds == -1) {
          return 1;
        }
        return increasing *
            a.HLTBCompletionistInSeconds.compareTo(
                b.HLTBCompletionistInSeconds);
      },
    ),
  ];
  bool filterAll = true;
  Set<int> selectedGenresIndices = {}, selectedTagsIndices = {};
  late Box<Tag> tags;
  late Box<Genre> genres;

  // Image & Cover URL
  static String imageUrl =
      'https://wallpaperaccess.com/full/5341085.jpg'; // placeholder
  static String coverUrl =
      'https://www.pcgamesarchive.com/wp-content/uploads/2021/07/Hollow-Knight-cover.jpg'; // placeholder

  @override
  void initState() {
    super.initState();
    UserSystem().loadUserContent();
    tags = Hive.box<Tag>('tags');
    genres = Hive.box<Genre>('genres');
  }

  ListView mediaListBuilder(BuildContext context, Box<Wishlist> _, Widget? __) {
    List<ListTile> listTiles = List.from([]);
    List<Game> userGames = UserSystem().getUserWishlistGames();
    List<Pair<Game, int>> gamesIndices = List.from([]);
    Set<Genre> selectedGenres = {};
    Set<Tag> selectedTags = {};

    for (int i in selectedGenresIndices) {
      selectedGenres.add(genres.getAt(i)!);
    }
    for (int i in selectedTagsIndices) {
      selectedTags.add(tags.getAt(i)!);
    }

    for (int i = 0; i < userGames.length; ++i) {
      bool shouldAdd = true;
      if (selectedGenresIndices.isNotEmpty || selectedTagsIndices.isNotEmpty) {
        int conditionsMet = 0;
        for (MediaUserTag mut in UserSystem().getUserTags()) {
          if (userGames[i].media == mut.media &&
              selectedTags.contains(mut.tag)) {
            ++conditionsMet;
            if (!filterAll) {
              break;
            }
          }
        }
        for (MediaUserGenre mug in UserSystem().getUserGenres()) {
          if (userGames[i].media == mug.media &&
              selectedGenres.contains(mug.genre)) {
            ++conditionsMet;
            if (!filterAll) {
              break;
            }
          }
        }

        if (filterAll) {
          shouldAdd =
              (selectedGenres.length + selectedTags.length == conditionsMet);
        } else if (conditionsMet == 0) {
          shouldAdd = false;
        }
      }
      if (shouldAdd) {
        gamesIndices.add(Pair(userGames[i], i));
      }
    }

    gamesIndices.sort((p0, p1) {
      return gameOrderComparators[selectedSortingMethod].value(
        p0.key,
        p1.key,
        increasingSorting ? 1 : -1,
      );
    });

    for (int i = 0; i < gamesIndices.length; ++i) {
      final game = gamesIndices[i].key;
      final idx = gamesIndices[i].value;
      if (filterQuery == "" ||
          game.media.originalName.toLowerCase().contains(filterQuery)) {
        listTiles.add(
          ListTile(
            leading: const Icon(Icons.videogame_asset),
            title: Text(game.media.originalName),
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
    if (gameName[gameName.length - 1] == ')' && gameName.length >= 7) {
      gameName = gameName.substring(0, gameName.length - 7);
    }
    Box<Game> games = Hive.box<Game>('games');
    for (int i = 0; i < games.length; ++i) {
      if (games.getAt(i)!.media.originalName == gameName) {
        return games.getAt(i);
      }
    }

    return null;
  }

  bool gameAlreadyInWishlist(String gameName) {
    if (gameName[gameName.length - 1] == ')' && gameName.length >= 7) {
      gameName = gameName.substring(0, gameName.length - 7);
    }
    for (Wishlist w in UserSystem().getUserWishlist()) {
      if (gameName == w.media.originalName) {
        return true;
      }
    }

    return false;
  }

  bool gameAlreadyInLibrary(String gameName) {
    if (gameName[gameName.length - 1] == ')' && gameName.length >= 7) {
      gameName = gameName.substring(0, gameName.length - 7);
    }
    for (Game libgame in UserSystem().getUserGames()) {
      if (gameName == libgame.media.originalName) {
        return true;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    _setSearchText();

    IconButton? butonSearchReset;
    if (filterQuery == "") {
      butonSearchReset = IconButton(
        onPressed: () {
          /*TODO: The search box gets activated only if you hold down at least 2 frames, I do not know the function to activate it when pressing this button. I also do not know if this should be our priority right now*/
        },
        icon: const Icon(Icons.search),
      );
    } else {
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
      onChanged: (value) {
        setState(() {});
      },
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        hintText: "Search game in wishlist",
        suffixIcon: butonSearchReset,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('MediaMaster'),
        actions: [
          TextButton(
            onPressed: () {}, // TO DO: profile page
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                  const Color.fromARGB(219, 10, 94, 87)),
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            ),
            child: Text(UserSystem().currentUser!.username),
          ),
          IconButton(
              onPressed: () {
                UserSystem().logout();
                Navigator.pop(context);
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const Home()));
              },
              icon: const Icon(Icons.logout),
              tooltip: 'Log out')
        ],
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
                          AdaptiveTheme.of(context).mode ==
                                  AdaptiveThemeMode.light
                              ? AdaptiveTheme.of(context).setDark()
                              : AdaptiveTheme.of(context).setLight();
                        },
                        icon: const Icon(Icons.dark_mode),
                        tooltip: 'Toggle dark mode',
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const GameLibrary()));
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              const Color.fromARGB(219, 10, 94, 87)),
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                        ),
                        child: const Text('Game library'),
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
                          tooltip: 'Add Game to wishlist',
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
                      valueListenable:
                          Hive.box<Wishlist>('wishlists').listenable(),
                      builder: mediaListBuilder,
                    ),
                  ),
                ],
              )),
          Expanded(
            flex: 10,
            child: Container(
              child: _displayGame(UserSystem().getUserWishlistGames().isNotEmpty
                  ? UserSystem().getUserWishlistGames()[selectedGameIndex]
                  : null),
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
                height: noSearch
                    ? 100
                    : 400, // Set height based on the presence of search results
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
                              ServiceBuilder.setIgdb();
                              searchResults =
                                  await ServiceHandler.getOptions(query);
                              setState(() {
                                noSearch = searchResults
                                    .isEmpty; // Update noSearch flag
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
                                String gameName = result['name'];

                                if (gameAlreadyInWishlist(gameName)) {
                                  return ListTile(
                                    title: Text(gameName),
                                    subtitle: const Text(
                                      "Game is already in wishlist.",
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 255, 0, 0),
                                      ),
                                    ),
                                    onTap: () {
                                      _addGame(result);
                                      Navigator.of(context).pop();
                                    },
                                  );
                                } else if (gameAlreadyInLibrary(gameName)) {
                                  return ListTile(
                                    title: Text(gameName),
                                    subtitle: const Text(
                                      "Game is already in library.",
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 255, 0, 0),
                                      ),
                                    ),
                                    onTap: () {
                                      _addGame(result);
                                      Navigator.of(context).pop();
                                    },
                                  );
                                } else {
                                  return ListTile(
                                    title: Text(gameName),
                                    onTap: () {
                                      _addGame(result);
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
                                  if (value == true) {
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
                                  if (value == true) {
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
                        for (int i = 0; i < gameOrderComparators.length; ++i)
                          Row(
                            children: [
                              Checkbox(
                                value: i == selectedSortingMethod,
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
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
        });
  }

  Future<void> _showFilterGamesDialog(BuildContext context) {
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
                                  if (value == true) {
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
                                  if (value == true) {
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
                              'Tags',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () => setState(() {
                                selectedTagsIndices.clear();
                                resetState();
                              }),
                              icon: const Icon(
                                Icons.clear,
                              ),
                            ),
                          ],
                        ),
                        for (int i = 0; i < tags.length; ++i)
                          Row(
                            children: [
                              Checkbox(
                                value: selectedTagsIndices.contains(i),
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
                                      selectedTagsIndices.add(i);
                                    } else {
                                      selectedTagsIndices.remove(i);
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
                                selectedGenresIndices.clear();
                                resetState();
                              }),
                              icon: const Icon(
                                Icons.clear,
                              ),
                            ),
                          ],
                        ),
                        for (int i = 0; i < genres.length; ++i)
                          Row(
                            children: [
                              Checkbox(
                                value: selectedGenresIndices.contains(i),
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
                                      selectedGenresIndices.add(i);
                                    } else {
                                      selectedGenresIndices.remove(i);
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
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        });
  }

  Future<void> _showDeleteConfirmationDialog(
      BuildContext context, int index) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove game from wishlist'),
          content: const Text('Are you sure you want to remove this game?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Game gameToDelete = UserSystem().getUserWishlistGames()[index];
                for (Wishlist w in UserSystem().currentUserWishlist) {
                  if (w.media == gameToDelete.media) {
                    UserSystem().currentUserWishlist.remove(w);
                    Hive.box<Wishlist>('wishlists').delete(w.key);
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

  Future<void> _addGame(Map<String, dynamic> result) async {
    if (UserSystem().currentUser == null) {
      return;
    }

    var selectedGame = await ServiceHandler.getInfo(result);
    String name = selectedGame['name'];

    if (name[name.length - 1] == ')' && name.length >= 7) {
      name = name.substring(0, name.length - 7);
    }

    Game? nullableGame = gameAlreadyInDB(name);

    // Get information from PCGamingWiki
    ServiceBuilder.setPcGamingWiki();
    var optionsPCGW = await ServiceHandler.getOptions(name);
    Map<String, dynamic> resultPCGW = {};
    if (optionsPCGW.isNotEmpty) {
      // This is kind of a hack but we will do it legit in the future
      resultPCGW = await ServiceHandler.getInfo(optionsPCGW[0]);
    }
    Map<String, dynamic> answersPCGW = {};
    if (resultPCGW.containsKey('windows')) {
      if (resultPCGW['windows'].containsKey('OS')) {
        answersPCGW['OSMinimum'] = resultPCGW['windows']['OS']['minimum']
            ?.replaceAll(RegExp(r'\s+'), ' ');
        answersPCGW['OSRecommended'] = resultPCGW['windows']['OS']
                ['recommended']
            ?.replaceAll(RegExp(r'\s+'), ' ');
      }
      if (resultPCGW['windows'].containsKey('CPU')) {
        answersPCGW['CPUMinimum'] = resultPCGW['windows']['CPU']['minimum']
            ?.replaceAll(RegExp(r'\s+'), ' ');
        answersPCGW['CPURecommended'] = resultPCGW['windows']['CPU']
                ['recommended']
            ?.replaceAll(RegExp(r'\s+'), ' ');
      }
      if (resultPCGW['windows'].containsKey('RAM')) {
        answersPCGW['RAMMinimum'] = resultPCGW['windows']['RAM']['minimum']
            ?.replaceAll(RegExp(r'\s+'), ' ');
        answersPCGW['RAMRecommended'] = resultPCGW['windows']['RAM']
                ['recommended']
            ?.replaceAll(RegExp(r'\s+'), ' ');
      }
      if (resultPCGW['windows'].containsKey('HDD')) {
        answersPCGW['HDDMinimum'] = resultPCGW['windows']['HDD']['minimum']
            ?.replaceAll(RegExp(r'\s+'), ' ');
        answersPCGW['HDDRecommended'] = resultPCGW['windows']['HDD']
                ['recommended']
            ?.replaceAll(RegExp(r'\s+'), ' ');
      }
      if (resultPCGW['windows'].containsKey('GPU')) {
        answersPCGW['GPUMinimum'] = resultPCGW['windows']['GPU']['minimum']
            ?.replaceAll(RegExp(r'\s+'), ' ');
        answersPCGW['GPURecommended'] = resultPCGW['windows']['GPU']
                ['recommended']
            ?.replaceAll(RegExp(r'\s+'), ' ');
      }
    }

    // Get information from HLTB
    ServiceBuilder.setHowLongToBeat();
    var optionsHLTB = await ServiceHandler.getOptions(name);
    Map<String, dynamic> resultHLTB = {};
    if (optionsHLTB.isNotEmpty) {
      // This is kind of a hack but we will do it legit in the future
      resultHLTB = await ServiceHandler.getInfo(optionsHLTB[0]);
    }
    Map<String, dynamic> answersHLTB = {};
    if (resultHLTB.containsKey('Main Story')) {
      answersHLTB['Main Story'] =
          (double.parse(resultHLTB['Main Story'].split(' Hours')[0]) * 3600)
              .round();
    }
    if (resultHLTB.containsKey('Main + Sides')) {
      answersHLTB['Main + Sides'] =
          (double.parse(resultHLTB['Main + Sides'].split(' Hours')[0]) * 3600)
              .round();
    }
    if (resultHLTB.containsKey('Completionist')) {
      answersHLTB['Completionist'] =
          (double.parse(resultHLTB['Completionist'].split(' Hours')[0]) * 3600)
              .round();
    }
    if (resultHLTB.containsKey('All Styles')) {
      answersHLTB['All Styles'] =
          (double.parse(resultHLTB['All Styles'].split(' Hours')[0]) * 3600)
              .round();
    }
    if (resultHLTB.containsKey('Co-Op')) {
      answersHLTB['Co-Op'] =
          (double.parse(resultHLTB['Co-Op'].split(' Hours')[0]) * 3600).round();
    }
    if (resultHLTB.containsKey('Vs.')) {
      answersHLTB['Vs.'] =
          (double.parse(resultHLTB['Vs.'].split(' Hours')[0]) * 3600).round();
    }

    if (nullableGame == null) {
      Media media = Media(
        originalName: name,
        description:
            selectedGame['summary'] ?? "There is no summary for this game.",
        releaseDate:
            DateTime.now(), //selectedGame['first_release_date'] as DateTime,
        criticScore: selectedGame['critic_rating'] != 0
            ? selectedGame['critic_rating']
            : 0,
        communityScore:
            selectedGame['user_rating'] != 0 ? selectedGame['user_rating'] : 0,
        mediaType: "Game",
      );
      Game newGame = Game(
        mediaId: media.id,
        parentGameId:
            -1 /*TODO in the next semester: Add parameter/call to API to check if this is a DLC*/,
        IGDBId: selectedGame['id'],
        OSMinimum: answersPCGW.containsKey('OSMinimum') &&
                answersPCGW['OSMinimum'] != null
            ? answersPCGW['OSMinimum']
            : "N/A",
        OSRecommended: answersPCGW.containsKey('OSRecommended') &&
                answersPCGW['OSRecommended'] != null
            ? answersPCGW['OSRecommended']
            : "N/A",
        CPUMinimum: answersPCGW.containsKey('CPUMinimum') &&
                answersPCGW['CPUMinimum'] != null
            ? answersPCGW['CPUMinimum']
            : "N/A",
        CPURecommended: answersPCGW.containsKey('CPURecommended') &&
                answersPCGW['CPURecommended'] != null
            ? answersPCGW['CPURecommended']
            : "N/A",
        RAMMinimum: answersPCGW.containsKey('RAMMinimum') &&
                answersPCGW['RAMMinimum'] != null
            ? answersPCGW['RAMMinimum']
            : "N/A",
        RAMRecommended: answersPCGW.containsKey('RAMRecommended') &&
                answersPCGW['RAMRecommended'] != null
            ? answersPCGW['RAMRecommended']
            : "N/A",
        HDDMinimum: answersPCGW.containsKey('HDDMinimum') &&
                answersPCGW['HDDMinimum'] != null
            ? answersPCGW['HDDMinimum']
            : "N/A",
        HDDRecommended: answersPCGW.containsKey('HDDRecommended') &&
                answersPCGW['HDDRecommended'] != null
            ? answersPCGW['HDDRecommended']
            : "N/A",
        GPUMinimum: answersPCGW.containsKey('GPUMinimum') &&
                answersPCGW['GPUMinimum'] != null
            ? answersPCGW['GPUMinimum']
            : "N/A",
        GPURecommended: answersPCGW.containsKey('GPURecommended') &&
                answersPCGW['GPURecommended'] != null
            ? answersPCGW['GPURecommended']
            : "N/A",
        HLTBMainInSeconds: answersHLTB.containsKey('Main Story')
            ? answersHLTB['Main Story']
            : -1,
        HLTBMainSideInSeconds: answersHLTB.containsKey('Main + Sides')
            ? answersHLTB['Main + Sides']
            : -1,
        HLTBCompletionistInSeconds: answersHLTB.containsKey('Completionist')
            ? answersHLTB['Completionist']
            : -1,
        HLTBAllStylesInSeconds: answersHLTB.containsKey('All Styles')
            ? answersHLTB['All Styles']
            : -1,
        HLTBCoopInSeconds:
            answersHLTB.containsKey('Co-Op') ? answersHLTB['Co-Op'] : -1,
        HLTBVersusInSeconds:
            answersHLTB.containsKey('Vs.') ? answersHLTB['Vs.'] : -1,
      );

      if(selectedGame['publishers'] != null) {
        // get the publishers of the game
        List<dynamic> gamePublishers = selectedGame['publishers'];
        List<Publisher> newPublishers = List.empty(growable: true);
        Box<Publisher> publishers = Hive.box<Publisher>('publishers');
        Box<MediaPublisher> mediaPublishers =
            Hive.box<MediaPublisher>('media-publishers');

        for (dynamic publisher in gamePublishers) {
          bool check = true;
          for (int i = 0; i < publishers.length; i++) {
            // if the creator exists in the DB, add a new entry to MediaPublisher
            if (publishers.getAt(i)!.name == publisher.toString()) {
              check = false;
              mediaPublishers.add(MediaPublisher(
                mediaId: media.id,
                publisherId: publishers.getAt(i)!.id,
              ));
            }
          }
          // add the new creator to the newPublishers list in order to add it to the DB later
          if (check == true) {
            newPublishers.add(Publisher(name: publisher.toString()));
          }
        }

        // add the new creators to the DB and add new entries to MediaPublisher
        for (Publisher publisher in newPublishers) {
          publishers.add(publisher);
          mediaPublishers
              .add(MediaPublisher(mediaId: media.id, publisherId: publisher.id));
        }
      }

      if(selectedGame['developers'] != null) {
        // get the developers of the game
        List<dynamic> gameCreators = selectedGame['developers'];
        List<Creator> newCreators = List.empty(growable: true);
        Box<Creator> creators = Hive.box<Creator>('creators');
        Box<MediaCreator> mediaCreators =
            Hive.box<MediaCreator>('media-creators');

        for (dynamic creator in gameCreators) {
          bool check = true;
          for (int i = 0; i < creators.length; i++) {
            // if the creator exists in the DB, add a new entry to MediaCreator
            if (creators.getAt(i)!.name == creator.toString()) {
              check = false;
              mediaCreators.add(MediaCreator(
                mediaId: media.id,
                creatorId: creators.getAt(i)!.id,
              ));
            }
          }
          // add the new creator to the newCreators list in order to add it to the DB later
          if (check == true) {
            newCreators.add(Creator(name: creator.toString()));
          }
        }

        // add the new creators to the DB and add new entries to MediaCreator
        for (Creator creator in newCreators) {
          creators.add(creator);
          mediaCreators
              .add(MediaCreator(mediaId: media.id, creatorId: creator.id));
        }
      }

      if(selectedGame['platforms'] != null) {
        // get the platforms of the game
        List<dynamic> gamePlatforms = selectedGame['platforms'];
        List<Platform> newPlatforms = List.empty(growable: true);
        Box<Platform> platforms = Hive.box<Platform>('platforms');
        Box<MediaPlatform> mediaPlatforms =
            Hive.box<MediaPlatform>('media-platforms');

        for (dynamic platform in gamePlatforms) {
          bool check = true;
          for (int i = 0; i < platforms.length; i++) {
            // if the creator exists in the DB, add a new entry to MediaPlatform
            if (platforms.getAt(i)!.name == platform.toString()) {
              check = false;
              mediaPlatforms.add(MediaPlatform(
                mediaId: media.id,
                platformId: platforms.getAt(i)!.id,
              ));
            }
          }
          // add the new creator to the newPlatformss list in order to add it to the DB later
          if (check == true) {
            newPlatforms.add(Platform(name: platform.toString()));
          }
        }

        // add the new creators to the DB and add new entries to MediaPublisher
        for (Platform platform in newPlatforms) {
          platforms.add(platform);
          mediaPlatforms
              .add(MediaPlatform(mediaId: media.id, platformId: platform.id));
        }
      }

      await Hive.box<Media>('media').add(media);
      await Hive.box<Game>('games').add(newGame);
      nullableGame = newGame;
    }

    Game game = nullableGame;

    if (!gameAlreadyInWishlist(game.media.originalName)) {
      Wishlist w = Wishlist(
        mediaId: game.mediaId,
        userId: UserSystem().currentUser!.id,
        name: game.media.originalName,
        userScore: -1,
        addedDate: DateTime.now(),
        coverImage: selectedGame["cover"] == null ? '//static.vecteezy.com/system/resources/previews/016/916/479/original/placeholder-icon-design-free-vector.jpg' : selectedGame["cover"],
        status: "Plan To Play",
        series:
            game.media.originalName /*Add parameter/call to game series API*/,
        icon: selectedGame["cover"] == null ? '//static.vecteezy.com/system/resources/previews/016/916/479/original/placeholder-icon-design-free-vector.jpg' : selectedGame["cover"],
        backgroundImage: selectedGame["artworks"] == null ? '//static.vecteezy.com/system/resources/previews/016/916/479/original/placeholder-icon-design-free-vector.jpg' : selectedGame["artworks"][0],
        lastInteracted: DateTime.now(),
      );

      UserSystem().currentUserWishlist.add(w);
      await Hive.box<Wishlist>('wishlists').add(w);
    }
  }

  Widget _displayGame(Game? game) {
    if (game == null) {
      return Container(
          color: Colors.black.withOpacity(0.5),
          child: const Center(
            child: Text(
              "Choose a game",
              style: TextStyle(color: Colors.white, fontSize: 24.0),
            ),
          ));
    }

    Box<Wishlist> items = Hive.box<Wishlist>('wishlists');
    for (int i = 0; i < items.length; i++) {
      if (items.getAt(i)!.mediaId == game.mediaId &&
          items.getAt(i)!.userId == UserSystem().currentUser!.id) {
        imageUrl = 'https:${items.getAt(i)!.backgroundImage}';
        coverUrl = 'https:${items.getAt(i)!.coverImage}';
        break;
      }
    }

    return SizedBox.expand(
      child: Container(
        padding: const EdgeInsets.only(
          top: 200,
        ),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              imageUrl,
            ),
            alignment: Alignment.topCenter,
          ),
          color: Colors.black,
        ),
        child: Container(
          padding: const EdgeInsets.all(10),
          color: const Color.fromARGB(224, 64, 64, 64),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  // Game name;
                  child: Text(
                    game.media.originalName,
                    style: const TextStyle(color: Colors.white, fontSize: 24.0),
                  ),
                ),
                if (gameAlreadyInLibrary(game.media.originalName))
                  const Center(
                    child: Text(
                      "Game is already in library.",
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 0, 0),
                      ),
                    ),
                  ),
                Row(
                  children: [
                    Container(
                      // Play button
                      margin: const EdgeInsets.all(10),
                      child: TextButton(
                        style: ButtonStyle(
                          backgroundColor:
                              const MaterialStatePropertyAll(Colors.lightGreen),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                          ),
                        ),
                        onPressed: () {
                          playGame(game);
                        },
                        child: const Column(
                          children: [
                            Text(
                              "Play",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 24.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              "(currently unnavailable)",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      // HLTB button
                      margin: const EdgeInsets.all(10),
                      child: IconButton(
                        onPressed: () {
                          _showHLTBDialog(
                            game,
                          );
                        },
                        icon: const Icon(
                          Icons.access_alarm_outlined,
                          color: Colors.white,
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              const Color.fromARGB(255, 32, 32, 32)),
                        ),
                      ),
                    ),
                    Container(
                      // Sys Check button
                      margin: const EdgeInsets.all(10),
                      child: IconButton(
                        onPressed: () {
                          _showSysCheck(game);
                        },
                        icon: const Icon(
                          Icons.monitor,
                          color: Colors.white,
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              const Color.fromARGB(255, 32, 32, 32)),
                        ),
                      ),
                    ),
                    Container(
                      // Settings button
                      margin: const EdgeInsets.all(10),
                      child: IconButton(
                        onPressed: () {
                          _showGameSettingsDialog(game);
                        },
                        icon: const Icon(
                          Icons.settings,
                          color: Colors.white,
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              const Color.fromARGB(255, 32, 32, 32)),
                        ),
                      ),
                    ),
                    Container(
                      // Settings button
                      margin: const EdgeInsets.all(10),
                      child: TextButton(
                        onPressed: () {
                          _showGameRecommendationsDialog(game);
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              const Color.fromARGB(255, 32, 32, 32)),
                          foregroundColor:
                              MaterialStateProperty.all(Colors.white),
                          overlayColor: MaterialStateProperty.all(
                              const Color.fromARGB(255, 32, 32, 32)),
                        ),
                        child: const Text('Similar games'),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        // Cover
                        margin: const EdgeInsets.all(
                          20,
                        ),
                        child: Image(
                          image: NetworkImage(
                            coverUrl,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Container(
                        // Description
                        margin: const EdgeInsets.all(10),
                        child: Text(
                          game.media.description,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        // Game data (publisher, retailer, etc.)
                        margin: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            game.media.getPublishersWidget(),
                            game.media.getCreatorsWidget(),
                            game.media.getPlatformsWidget(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                renderNotes(
                  UserSystem().getUserNotes(
                    game.media,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void playGame(Game game) {
    // TODO: This function gets invoked by the play button. For now, until we integrate Steam/Epic/GOG/whatever this will be empty and the play button will do nothing
  }

  Future<void> _showHLTBDialog(Game game) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('How long to beat'),
          content: game.renderHLTB(),
        );
      },
    );
  }

  Future<void> _showSysCheck(Game game) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('System requirements'),
          content: game.renderPCGW(),
        );
      },
    );
  }

  Future<void> _showGameSettingsDialog(Game game) {
    void resetState() {
      setState(() {});
    }

    var userTags = Set.from(UserSystem().currentUserTags.where((mut) {
      return mut.mediaId == game.mediaId;
    }).map((mut) => mut.tagId));
    var userGenres = Set.from(UserSystem().currentUserGenres.where((mug) {
      return mug.mediaId == game.mediaId;
    }).map((mug) => mug.genreId));
    game.mediaId;

    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                title: const Text('Game settings'),
                content: SizedBox(
                  height: 400,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const Text(
                          'Game tags',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        for (int i = 0; i < tags.length; ++i)
                          Row(
                            children: [
                              Checkbox(
                                value: userTags.contains(tags.getAt(i)!.id),
                                onChanged: (value) {
                                  setState(() {
                                    int id = tags.getAt(i)!.id;
                                    MediaUserTag mut = MediaUserTag(
                                      mediaId: game.mediaId,
                                      userId: UserSystem().currentUser!.id,
                                      tagId: id,
                                    );
                                    var box = Hive.box<MediaUserTag>(
                                        'media-user-tags');

                                    if (value == true) {
                                      userTags.add(id);
                                      UserSystem().currentUserTags.add(mut);
                                      Hive.box<MediaUserTag>('media-user-tags')
                                          .add(mut);
                                    } else {
                                      userTags.remove(id);
                                      UserSystem().currentUserTags.remove(mut);
                                      var vals = box.values;
                                      for (i = 0; i < vals.length; ++i) {
                                        if (vals.elementAt(i) == mut) {
                                          box.delete(vals.elementAt(i).key);
                                          break;
                                        }
                                      }
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
                        const Text(
                          'Game genres',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        for (int i = 0; i < genres.length; ++i)
                          Row(
                            children: [
                              Checkbox(
                                value: userGenres.contains(i),
                                onChanged: (value) {
                                  setState(() {
                                    int id = genres.getAt(i)!.id;
                                    MediaUserGenre mug = MediaUserGenre(
                                      mediaId: game.mediaId,
                                      userId: UserSystem().currentUser!.id,
                                      genreId: id,
                                    );
                                    var box = Hive.box<MediaUserGenre>(
                                        'media-user-genres');

                                    if (value == true) {
                                      userGenres.add(id);
                                      UserSystem().currentUserGenres.add(mug);
                                      Hive.box<MediaUserGenre>(
                                              'media-user-genres')
                                          .add(mug);
                                    } else {
                                      userGenres.remove(id);
                                      UserSystem()
                                          .currentUserGenres
                                          .remove(mug);
                                      var vals = box.values;
                                      for (i = 0; i < vals.length; ++i) {
                                        if (vals.elementAt(i) == mug) {
                                          box.delete(vals.elementAt(i).key);
                                          break;
                                        }
                                      }
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
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        });
  }

  Future<void> _showGameRecommendationsDialog(Game game) async {
    void resetState() {
      setState(() {});
    }

    ServiceBuilder.setIgdb();
    var similarGames = await ServiceHandler.getRecommendations(game.IGDBId);
    List<Widget> recommendations = [];

    if (similarGames.isEmpty) {
      return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return const AlertDialog(
                title: Text(
                  'Similar games',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                content: SizedBox(
                  height: 400,
                  width: 300,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.sentiment_dissatisfied,
                            color: Colors.grey,
                            size: 50,
                          ),
                          SizedBox(height: 20),
                          Text(
                            'There are no similar games for this game, sorry!',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    }

    for (var similarGame in similarGames) {
      String name = similarGame['name'];
      if (name[name.length - 1] == ')' && name.length >= 7) {
        name = name.substring(0, name.length - 7);
      }
      recommendations.add(
        ListTile(
          leading: const Icon(Icons.videogame_asset),
          title: Text(
            similarGame['name'],
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          trailing: GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: name));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${name} copied to clipboard')),
              );
            },
            child: const Icon(Icons.copy), // Icon to indicate copying
          ),
        ),
      );
    }

    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                title: const Text('Similar games'),
                content: SizedBox(
                  height: 400,
                  child: SingleChildScrollView(
                    child: Column(
                      children: recommendations,
                    ),
                  ),
                ),
              );
            },
          );
        });
  }

  Future<void> _showNewStickyDialog(int mediaId) {
    TextEditingController controller = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("New sticky note"),
          content: SizedBox(
            width: 350,
            child: TextFormField(
              controller: controller,
              autocorrect: false,
              minLines: 10,
              maxLines: 10,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {});
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Note note = Note(
                  mediaId: mediaId,
                  userId: UserSystem().currentUser!.id,
                  content: controller.text,
                );
                UserSystem().currentUserNotes.add(note);
                Navigator.of(context).pop();
                setState(() {});
                await Hive.box<Note>('notes').add(note);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Widget renderStickyNote(Note? note, int mediaId) {
    Widget textToDisplay = const Text(
      "+",
      style: TextStyle(
        fontSize: 70,
        color: Colors.black26,
      ),
    );
    var onClick = () {
      _showNewStickyDialog(mediaId);
    };

    if (note != null) {
      onClick = () {};
      textToDisplay = Text(
        note.content,
        style: const TextStyle(
          fontSize: 20,
          color: Colors.black87,
        ),
      );
    }

    void removeNote() async {
      note as Note;
      UserSystem().currentUserNotes.remove(note);
      Hive.box<Note>('notes').delete(note.key);
      setState(() {});
    }

    return GestureDetector(
        onTap: onClick,
        child: Stack(
          children: [
            Container(
              color: const Color.fromARGB(255, 216, 216, 151),
              alignment: Alignment.center,
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: textToDisplay,
              ),
            ),
            if (note != null)
              Positioned(
                right: 20,
                top: 20,
                child: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: removeNote,
                  color: const Color.fromARGB(255, 192, 0, 0),
                ),
              ),
          ],
        ));
  }

  Widget renderNotes(Set<Note> notes) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      primary: false,
      children: [
        for (Note note in notes) renderStickyNote(note, -1),
        renderStickyNote(null,
            UserSystem().getUserWishlistGames()[selectedGameIndex].mediaId),
      ],
    );
  }
}
