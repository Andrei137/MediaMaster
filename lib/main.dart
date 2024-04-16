import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'utils.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(GameAdapter());
  await Hive.openBox<Game>('games');

  runApp(MaterialApp(
    title: 'MediaMaster',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: const MyApp(),
  ));
}

class Game {
  int id;
  String name;
  String backgroundImage;

  Game({required this.id, required this.name, required this.backgroundImage});
}

class GameAdapter extends TypeAdapter<Game> {
  @override
  final int typeId = 0;

  @override
  Game read(BinaryReader reader) {
    return Game(
      id: reader.readInt(),
      name: reader.readString(),
      backgroundImage: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Game obj) {
    writer.writeInt(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.backgroundImage);
  }
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
    List<Game> games = List.from(box.values);
    games.sort((g0, g1) => g0.name.compareTo(g1.name));

    for(int i = 0;i < games.length;++i) {
      final game = games[i];
      if(filterQuery == "" || game.name.toLowerCase().contains(filterQuery)) {
        listTiles.add(
          ListTile(
            title: Text(game.name),
            onTap: () {
              setState(() {
                selectedGameIndex = i;
              });
            },
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _showDeleteConfirmationDialog(context, i);
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
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    gameBox.isNotEmpty ? gameBox.getAt(selectedGameIndex)!.backgroundImage : placeholderImageUrl
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Text(
                    gameBox.isNotEmpty ? gameBox.getAt(selectedGameIndex)!.name : '',
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
                height: noSearch ? 100 : 150, // Set height based on the presence of search results
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
                                return ListTile(
                                  title: Text(gameName),
                                  onTap: () {
                                    _addGame(gameName);
                                    Navigator.of(context).pop();
                                  },
                                );
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
    for(int i = 0;i < gameBox.length;++i) {
      Game game = gameBox.getAt(i)!;
      if(game.name == gameName) {
        return;
      }
    }

    Game newGame = Game(
      id: DateTime.now().millisecondsSinceEpoch,
      name: gameName,
      backgroundImage: placeholderImageUrl,
    );
    gameBox.add(newGame);
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
