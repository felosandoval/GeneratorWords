import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MainApp());
}

List<String>? _saved = <String>[];

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
      ),
      home: const WordGenerator(),
    );
  }
}

class WordGenerator extends StatefulWidget {
  const WordGenerator({super.key});

  @override
  State<WordGenerator> createState() => _WordGeneratorState();
}

class _WordGeneratorState extends State<WordGenerator> {
  List<WordPair> _suggestions = <WordPair>[];

  _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList("guardados", _saved!);
  }

  _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _saved = prefs.getStringList("guardados");

    if (_saved == null) {
      _saved = [];
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Generador de palabras"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.navigate_next),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SecondScreen(),
                ),
              );
              setState(() {
                _loadData();  // Recarga los datos cuando regreses de la segunda pantalla
              });
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          if (index.isOdd) {
            return const Divider();
          }

          _suggestions.addAll(generateWordPairs().take(2));

          bool yaEstaGuardada =
              _saved!.contains(_suggestions[index].asPascalCase);

          return ListTile(
            title: Text(
              '${index ~/ 2 + 1}. ${_suggestions[index].asPascalCase}',
              style: const TextStyle(fontSize: 20),
            ),
            trailing: Icon(
              yaEstaGuardada ? Icons.favorite : Icons.favorite_border,
              color: yaEstaGuardada ? Colors.red : null,
            ),
            onTap: () async {
              setState(() {
                if (yaEstaGuardada) {
                  _saved!.remove(_suggestions[index].asPascalCase);
                } else {
                  _saved!.add(_suggestions[index].asPascalCase);
                }
              });

              _saveData();
            },
          );
        },
      ),
    );
  }
}

class SecondScreen extends StatefulWidget {
  const SecondScreen({super.key});

  @override
  State<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  void _clearSingleSavedData(String word) async {
    final prefs = await SharedPreferences.getInstance();
    _saved!.remove(word);
    await prefs.setStringList('guardados', _saved!);

    setState(() {});
  }

  void _clearAllSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('guardados');

    setState(() {
      _saved = [];
    });
  }

  void _showConfirmationDialog(String word) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar eliminación'),
          content: Text('¿Realmente quieres eliminar "$word"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();  // Cierra el diálogo
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _clearSingleSavedData(word);
                Navigator.of(context).pop();  // Cierra el diálogo
              },
              child: Text('Sí'),
            ),
          ],
        );
      },
    );
  }

  void _showConfirmationDialogAll() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar eliminación de todos'),
          content: Text('¿Realmente quieres eliminar todos los favoritos?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();  // Cierra el diálogo
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _clearAllSavedData();
                Navigator.of(context).pop();  // Cierra el diálogo
              },
              child: Text('Sí'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favoritos'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 25.0),  // Margen derecho
            child: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _showConfirmationDialogAll();
              },
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _saved!.length,
        itemBuilder: (context, i) {
          return ListTile(
            title: Text(_saved![i]),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              color: Colors.red,
              onPressed: () {
                _showConfirmationDialog(_saved![i]);
              },
            ),
          );
        },
      ),
    );
  }
}
