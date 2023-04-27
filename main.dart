import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

getGames() {
  HttpIsolate(category: "pvp").isolateCreation();
  HttpIsolate(category: "shooter").isolateCreation();
  HttpIsolate(category: "mmofps").isolateCreation();
  HttpIsolate(category: "mmorpg").isolateCreation();
}

void main() async {
  getGames();
  runApp(const MyApp());

}
CircularProgressIndicator(
{Key? key,
double? value,
Color? backgroundColor,
Color? color,
Animation<Color?>? valueColor,
String? semanticsLabel,
String? semanticsValue}
) {
  // TODO: implement CircularProgressIndicator
  throw UnimplementedError();
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Games(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Game(
              id: '0',
              title: '0',
              thumbnailUrl: '0',
              shortDescription: '0',
              genre: '0'),
        ),
      ],
      child: MaterialApp(
        routes: {
          "/game_page": (ctx) => const GamePage(),
          "/setting_page": (ctx) => const SettingPage(),
          "/add_game": (ctx) => const GameNew(),
        },
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.purple,
          secondaryHeaderColor: Colors.deepOrange,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void popUpResult(context) {
    Navigator.pushNamed(context, '/setting_page');
  }

  getPreferences() async {
    SettingPage.category = await SharedPreference().getCategory();
  }

  @override
  void initState() {
    getPreferences();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final games = Provider.of<Games>(context);
    games.checkIfFiltered();
    games.setUpGames(SettingPage.category);
    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Container(
                decoration: const BoxDecoration(
                  color: Colors.purple,
                ),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(16.5),
                child: const Text(
                  'Hello Friend!',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text("Add New Games"),
                onTap: () {
                  Navigator.pushNamed(context, "/add_game");
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text("Free-to-Play Games"),
        actions: [
          PopupMenuButton(
            onSelected: (choice) => popUpResult(context),
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: "settings",
                child: const Text("Settings"),
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8),
        shrinkWrap: true,
        itemCount: games.filtered == false
            ? games._items.length
            : games.filteredItems.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              if (games.filtered == false) {
                Provider.of<Game>(context, listen: false).title =
                    games._items[index].title;
                Provider.of<Game>(context, listen: false).id =
                    games._items[index].id;
                Provider.of<Game>(context, listen: false).thumbnailUrl =
                    games._items[index].thumbnailUrl;
                Provider.of<Game>(context, listen: false).shortDescription =
                    games._items[index].shortDescription;
                Provider.of<Game>(context, listen: false).genre =
                    games._items[index].genre;
              } else {
                Provider.of<Game>(context, listen: false).title =
                    games.filteredItems[index].title;
                Provider.of<Game>(context, listen: false).id =
                    games.filteredItems[index].id;
                Provider.of<Game>(context, listen: false).thumbnailUrl =
                    games.filteredItems[index].thumbnailUrl;
                Provider.of<Game>(context, listen: false).shortDescription =
                    games.filteredItems[index].shortDescription;
                Provider.of<Game>(context, listen: false).genre =
                    games.filteredItems[index].genre;
              }
              Navigator.pushNamed(context, '/game_page');
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Card(
                child: GridTile(
                  footer: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: const BoxDecoration(
                      color: Color(0xE1000000),
                    ),
                    child: Text(
                      games.filtered == false
                          ? games._items[index].title
                          : games.filteredItems[index].title,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  child: Image.network(
                    games.filtered == false
                        ? games._items[index].thumbnailUrl
                        : games.filteredItems[index].thumbnailUrl,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class GamePage extends StatelessWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<Game>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(game.title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FittedBox(
            fit: BoxFit.fill,
            child: Image.network(game.thumbnailUrl),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
            child: Text(
              game.genre,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, color: Colors.grey),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              game.shortDescription,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingPage extends StatefulWidget {
  static String? category;
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  List genre = ["PvP","MMORPG","Shooter", "MMOFPS"];

  @override
  Widget build(BuildContext context) {
    final games = Provider.of<Games>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ListView.builder(
            shrinkWrap: true,
            itemCount: genre.length,
            itemBuilder: (context, index) {
              return RadioListTile<String>(
                title: Text(genre[index]),
                value: genre[index],
                groupValue: SettingPage.category,
                onChanged: (value) {
                  setState(
                        () {
                      SettingPage.category = value;
                    },
                  );
                },
              );
            },
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.deepOrange,
              ),
              child: TextButton(
                onPressed: () {
                  SharedPreference().setCategory(SettingPage.category!);
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                        (route) => false,
                  );
                },
                child: const Text(
                  "OK",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Sqlite {
  static Future<sql.Database> database() async {
    final sqlPath = await sql.getDatabasesPath();
    return sql.openDatabase(path.join(sqlPath, 'games.db'),
        onCreate: (db, version) {
          db.execute(
              'CREATE TABLE PVP(id INTEGER PRIMARY KEY, game_id TEXT, title TEXT, thumbnail TEXT, shortDescription TEXT, genre TEXT)');
          db.execute(
              'CREATE TABLE Shooter(id INTEGER PRIMARY KEY, game_id TEXT, title TEXT, thumbnail TEXT, shortDescription TEXT, genre TEXT)');
          db.execute(
              'CREATE TABLE MMOFPS(id INTEGER PRIMARY KEY, game_id TEXT, title TEXT, thumbnail TEXT, shortDescription TEXT, genre TEXT)');
          db.execute(
              'CREATE TABLE MMORPG(id INTEGER PRIMARY KEY, game_id TEXT, title TEXT, thumbnail TEXT, shortDescription TEXT, genre TEXT)');
        }, version: 1);
  }

  static Future<void> insert(String table, Game game) async {

    final db = await Sqlite.database();
    List<Map> result =
    await db.rawQuery("SELECT * FROM $table WHERE (game_id = ${game.id})");
    if (result.isEmpty) {

      db.insert(
        table,
        {
          "game_id": game.id,
          "title": game.title,
          "thumbnail": game.thumbnailUrl,
          "shortDescription": game.shortDescription,
          "genre": game.genre,

        },
      );
      CircularProgressIndicator(
        semanticsLabel: 'Linear progress indicator',
      );
    } else {
      print("It exists");
    }
  }

  static Future<List<Map<String, dynamic>>> getData(String table) async {
    final db = await Sqlite.database();
    return db.query(table);
  }

}

class HttpIsolate {
  final String category;
  HttpIsolate({required this.category});

  Future isolateCreation() async {
    ReceivePort receivePort = ReceivePort();
    final isolate = await Isolate.spawn(getGames, receivePort.sendPort);
    SendPort childPort = await receivePort.first;
    ReceivePort rp = ReceivePort();

    childPort.send([
      "https://www.freetogame.com/api/games?category=$category",
      rp.sendPort
    ]);

    final response = await rp.first;

    for (var element in response) {
      Sqlite.insert(
          category,
          Game(
              id: element['id'].toString(),
              title: element['title'],
              thumbnailUrl: element['thumbnail'],
              shortDescription: element['short_description'],
              genre: element['genre']));
    }
    isolate.kill();
  }

  static void getGames(SendPort mainSendPort) async {
    ReceivePort childPort = ReceivePort();
    mainSendPort.send(childPort.sendPort);
    List message = await childPort.first;
    String URL = message[0];
    SendPort replyPort = message[1];
    final response = await http.get(Uri.parse(URL));
    replyPort.send(jsonDecode(response.body));
  }
}

class GameNew extends StatefulWidget {
  const GameNew({Key? key}) : super(key: key);

  @override
  State<GameNew> createState() => _GameNewState();
}

class _GameNewState extends State<GameNew> {
  final _imageUrlFocusNode = FocusNode();
  List controllers = List.generate(5, (index) => TextEditingController());
  String URL = "";
  final _form = GlobalKey<FormState>();
  List names = ["ID", "Title", "Genre", "shortDescription"];
  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!controllers[4].text.startsWith('http') &&
          !controllers[4].text.startsWith('https')) ||
          (!controllers[4].text.endsWith('.png') &&
              !controllers[4].text.endsWith('.jpg') &&
              !controllers[4].text.endsWith('.jpeg'))) {
        return;
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Game"),
        actions: [
          IconButton(
            onPressed: () {
              if (_form.currentState!.validate()) {
                Provider.of<Games>(context, listen: false).updateList(
                  Game(
                    id: controllers[0].text,
                    title: controllers[1].text,
                    genre: controllers[2].text,
                    shortDescription: controllers[3].text,
                    thumbnailUrl: controllers[4].text,
                  ),
                );
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.save),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                itemCount: names.length - 1,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(15),
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please provide a value.';
                        }
                        return null;
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(RegExp("[-]"))
                      ],
                      decoration: InputDecoration(
                        hintText: names[index],
                      ),
                      controller: controllers[index],
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: TextFormField(
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please provide a description.';
                    }
                    if (value.length < 10) {
                      return 'Should be at least 10 characters long.';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: names[3],
                  ),
                  controller: controllers[3],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.only(
                        top: 8,
                        right: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: Colors.grey,
                        ),
                      ),
                      child: controllers[4].text.isEmpty
                          ? const Text('Enter a URL')
                          : FittedBox(
                        child: Image.network(
                          controllers[4].text,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        onChanged: (_) {
                          _updateImageUrl();
                        },
                        decoration:
                        const InputDecoration(labelText: 'Image URL'),
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.done,
                        controller: controllers[4],
                        focusNode: _imageUrlFocusNode,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an image URL.';
                          }
                          if (!value.startsWith('http') &&
                              !value.startsWith('https')) {
                            return 'Please enter a valid URL.';
                          }
                          if (!value.endsWith('.png') &&
                              !value.endsWith('.jpg') &&
                              !value.endsWith('.jpeg')) {
                            return 'Please enter a valid image URL.';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Games with ChangeNotifier {
  bool? filtered = false;
  List<Game> filteredItems = [];
  final List<Game> _items = [];
  filterList(genre) {
    filtered = true;
    filteredItems = [..._items];
    filteredItems.retainWhere((element) {
      return element.genre.contains(genre);
    });
  }

  setUpGames(String? genre) async {
    if (genre == null || genre.isEmpty) {
      final pvpGames = await Sqlite.getData("pvp");
      final shooterGames = await Sqlite.getData("shooter");
      final mmofpsGames = await Sqlite.getData("mmofps");
      final mmorpgGames = await Sqlite.getData("mmorpg");
      for (var element in pvpGames) {
        _items.add(Game(
            id: element['id'].toString(),
            title: element['title'],
            thumbnailUrl: element['thumbnail'],
            shortDescription: element['shortDescription'],
            genre: element['genre']));
      }
      for (var element in shooterGames) {
        _items.add(Game(
            id: element['id'].toString(),
            title: element['title'],
            thumbnailUrl: element['thumbnail'],
            shortDescription: element['shortDescription'],
            genre: element['genre']));
      }
      for (var element in mmofpsGames) {
        _items.add(Game(
            id: element['id'].toString(),
            title: element['title'],
            thumbnailUrl: element['thumbnail'],
            shortDescription: element['shortDescription'],
            genre: element['genre']));
      }
      for (var element in mmorpgGames) {
        _items.add(Game(
            id: element['id'].toString(),
            title: element['title'],
            thumbnailUrl: element['thumbnail'],
            shortDescription: element['shortDescription'],
            genre: element['genre']));
      }
      notifyListeners();
    } else {
      filterList(genre);
    }
  }

  checkIfFiltered() async {
    filtered = await SharedPreference().getFiltered();
  }

  updateList(Game game) {
    Sqlite.insert(game.genre, game);
    _items.add(game);
    notifyListeners();
  }
}

class SharedPreference {
  setCategory(String category) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString("gameCategory", category);
    pref.setBool("filtered", true);
  }

  Future getFiltered() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getBool("filtered") ?? false;
  }

  getCategory() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String category = pref.getString("gameCategory") ?? "";
    SettingPage.category = category;
    return category;
  }
}

class Game with ChangeNotifier {
  String id;
  String title;
  String thumbnailUrl;
  String shortDescription;
  String genre;

  Game(
      {required this.id,
        required this.title,
        required this.thumbnailUrl,
        required this.shortDescription,
        required this.genre});
}
