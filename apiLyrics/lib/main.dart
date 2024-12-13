import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const LyricsApp());
}

class LyricsApp extends StatelessWidget {
  const LyricsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lyrics Search',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LyricsSearch(),
    );
  }
}

class LyricsSearch extends StatefulWidget {
  const LyricsSearch({super.key});

  @override
  _LyricsSearchState createState() => _LyricsSearchState();
}

class _LyricsSearchState extends State<LyricsSearch> {
  final TextEditingController _artistController = TextEditingController();
  final TextEditingController _songController = TextEditingController();
  String? _lyrics;
  bool _isLoading = false;
  String? _error;

  Future<void> fetchLyrics(String artist, String song) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _lyrics = null;
    });

    final url = Uri.parse('https://api.lyrics.ovh/v1/$artist/$song');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _lyrics = data['lyrics'];
          _isLoading = false;
        });
      } else {
        throw Exception('Letras no encontradas.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Letras de Canciones'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _artistController,
              decoration: InputDecoration(
                labelText: 'Artista',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _songController,
              decoration: InputDecoration(
                labelText: 'Canción',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              onPressed: () {
                final artist = _artistController.text.trim();
                final song = _songController.text.trim();
                if (artist.isNotEmpty && song.isNotEmpty) {
                  fetchLyrics(artist, song);
                }
              },
              child: const Text(
                'Buscar',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
            if (_error != null)
              Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            if (!_isLoading && _lyrics != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    _lyrics!,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
