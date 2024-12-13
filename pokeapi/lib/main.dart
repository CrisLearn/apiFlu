import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const PokemonApp());
}

class PokemonApp extends StatelessWidget {
  const PokemonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokémon Search',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PokemonSearch(),
    );
  }
}

class PokemonSearch extends StatefulWidget {
  const PokemonSearch({super.key});

  @override
  _PokemonSearchState createState() => _PokemonSearchState();
}

class _PokemonSearchState extends State<PokemonSearch> {
  final TextEditingController _controller = TextEditingController();
  Map<String, dynamic>? _pokemonData;
  bool _isLoading = false;
  String? _error;

  Future<void> fetchPokemon(String name) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final url = Uri.parse('https://pokeapi.co/api/v2/pokemon/$name');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _pokemonData = data;
          _isLoading = false;
        });
      } else {
        throw Exception('Pokémon no encontrado.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error: $e';
      });
    }
  }

  Widget buildPokemonDetails() {
    if (_pokemonData == null) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_pokemonData!['sprites']['front_default'] != null)
              Center(
                child: Image.network(
                  _pokemonData!['sprites']['front_default'],
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              'Nombre: ${_pokemonData!['name']}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('ID: ${_pokemonData!['id']}'),
            Text('Altura: ${_pokemonData!['height'] / 10} m'),
            Text('Peso: ${_pokemonData!['weight'] / 10} kg'),
            const SizedBox(height: 8),
            const Text(
              'Tipos:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ...(_pokemonData!['types'] as List)
                .map((type) => Text('- ${type['type']['name']}')),
            const SizedBox(height: 8),
            const Text(
              'Habilidades:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ...(_pokemonData!['abilities'] as List)
                .map((ability) => Text('- ${ability['ability']['name']}')),
            const SizedBox(height: 8),
            const Text(
              'Estadísticas base:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ...(_pokemonData!['stats'] as List).map(
              (stat) => Text('${stat['stat']['name']}: ${stat['base_stat']}'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Pokémon'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Nombre del Pokémon',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final name = _controller.text.trim().toLowerCase();
                if (name.isNotEmpty) {
                  fetchPokemon(name);
                }
              },
              child: const Text('Buscar'),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
            if (_error != null)
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            if (!_isLoading && _pokemonData != null) buildPokemonDetails(),
          ],
        ),
      ),
    );
  }
}
