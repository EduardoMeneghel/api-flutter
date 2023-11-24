import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomeScreen(),
  ));
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gerenciador de Jogos'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ListaJogoScreen()),
                );
              },
              child: Text('Ver Lista de Jogos'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AdicionarJogoScreen()),
                );
              },
              child: Text('Adicionar Jogo'),
            ),
          ],
        ),
      ),
    );
  }
}

class ListaJogoScreen extends StatefulWidget {
  @override
  _ListaJogoScreenState createState() => _ListaJogoScreenState();
}

class _ListaJogoScreenState extends State<ListaJogoScreen> {
  List<dynamic> jogos = [];

  @override
  void initState() {
    super.initState();
    _carregarListaDeJogos();
  }

  Future<void> _carregarListaDeJogos() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:3002/game'));

      if (response.statusCode == 200) {
        setState(() {
          jogos = json.decode(response.body);
        });
      } else {
        print('Erro ao carregar a lista de jogos');
      }
    } catch (e) {
      print('Erro de conexão: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Jogos'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            for (var jogo in jogos)
              ListTile(
                title: Text(jogo['name']),
                subtitle: Text(jogo['platform']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditarJogoScreen(jogoId: jogo['ID']),
                          ),
                        ).then((_) {
                          _carregarListaDeJogos();
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        await _excluirJogo(jogo['ID']);
                        _carregarListaDeJogos();
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _excluirJogo(int id) async {
    try {
      final response =
          await http.delete(Uri.parse('http://10.0.2.2:3002/game/$id'));
      if (response.statusCode == 200) {
        print('Jogo excluído com sucesso');
      } else {
        print('Erro ao excluir jogo');
      }
    } catch (e) {
      print('Erro de conexão: $e');
    }
  }
}

class AdicionarJogoScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController platformController = TextEditingController();
  final TextEditingController genreController = TextEditingController();
  final TextEditingController releaseYearController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar Jogo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: platformController,
              decoration: InputDecoration(labelText: 'Plataforma'),
            ),
            TextField(
              controller: genreController,
              decoration: InputDecoration(labelText: 'Gênero'),
            ),
            TextField(
              controller: releaseYearController,
              decoration: InputDecoration(labelText: 'Ano de Lançamento'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _adicionarJogo();
                Navigator.pop(context);
              },
              child: Text('Adicionar Jogo'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _adicionarJogo() async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3002/game'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': nameController.text,
          'platform': platformController.text,
          'genre': genreController.text,
          'release_year': int.parse(releaseYearController.text),
        }),
      );
      if (response.statusCode == 201) {
        print('Jogo adicionado com sucesso');
      } else {
        print('Erro ao adicionar jogo');
      }
    } catch (e) {
      print('Erro de conexão: $e');
    }
  }
}

class EditarJogoScreen extends StatefulWidget {
  final int jogoId;

  EditarJogoScreen({required this.jogoId});

  @override
  _EditarJogoScreenState createState() => _EditarJogoScreenState();
}

class _EditarJogoScreenState extends State<EditarJogoScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController platformController = TextEditingController();
  final TextEditingController genreController = TextEditingController();
  final TextEditingController releaseYearController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarDetalhesDoJogo();
  }

  Future<void> _carregarDetalhesDoJogo() async {
    try {
      final response = await http
          .get(Uri.parse('http://10.0.2.2:3002/game/${widget.jogoId}'));
      if (response.statusCode == 200) {
        final jogo = json.decode(response.body);
        nameController.text = jogo['name'];
        platformController.text = jogo['platform'];
        genreController.text = jogo['genre'];
        releaseYearController.text = jogo['release_year'].toString();
      } else {
        print('Erro ao carregar detalhes do jogo');
      }
    } catch (e) {
      print('Erro de conexão: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Jogo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: platformController,
              decoration: InputDecoration(labelText: 'Plataforma'),
            ),
            TextField(
              controller: genreController,
              decoration: InputDecoration(labelText: 'Gênero'),
            ),
            TextField(
              controller: releaseYearController,
              decoration: InputDecoration(labelText: 'Ano de Lançamento'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _editarJogo(widget.jogoId);
                Navigator.pop(context);
              },
              child: Text('Editar Jogo'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editarJogo(int id) async {
    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:3002/game/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': nameController.text,
          'platform': platformController.text,
          'genre': genreController.text,
          'release_year': int.parse(releaseYearController.text),
        }),
      );
      if (response.statusCode == 200) {
        print('Jogo editado com sucesso');
      } else {
        print('Erro ao editar jogo');
      }
    } catch (e) {
      print('Erro de conexão: $e');
    }
  }
}
