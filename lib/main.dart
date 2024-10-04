import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Music Producer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MusicProducerApp(),
    );
  }
}

class MusicProducerApp extends StatefulWidget {
  @override
  _MusicProducerAppState createState() => _MusicProducerAppState();
}

class _MusicProducerAppState extends State<MusicProducerApp>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Music Producer'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.language), text: 'Language'),
            Tab(icon: Icon(Icons.music_note), text: 'Genre'),
            Tab(icon: Icon(Icons.create), text: 'Lyrics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          LanguageTab(),
          GenreTab(),
          LyricsTab(),
        ],
      ),
    );
  }
}

class LanguageTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter the language for the lyrics:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                hintText: 'Type the language...',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GenreTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter the genre of the song:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                hintText: 'Type the genre...',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LyricsTab extends StatefulWidget {
  @override
  _LyricsTabState createState() => _LyricsTabState();
}

class _LyricsTabState extends State<LyricsTab> {
  final TextEditingController descriptionController = TextEditingController();
  String generatedLyrics = '';
  bool isLoading = false;
  String errorMessage = '';

  Future<void> generateLyrics() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
      generatedLyrics = '';
    });

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/generate_lyrics'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'prompt': descriptionController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          generatedLyrics = data['lyrics'] ?? "No lyrics generated.";
        });
      } else {
        setState(() {
          errorMessage = "Error: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Failed to generate lyrics.";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Describe the song you would like to produce lyrics for:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                hintText: 'Describe the song...',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 5,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: generateLyrics,
              child: isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Create/Update Lyrics'),
            ),
            SizedBox(height: 16.0),
            Text(
              'Generated Lyrics:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            errorMessage.isNotEmpty
                ? Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red),
                  )
                : Text(
                    generatedLyrics.isNotEmpty
                        ? generatedLyrics
                        : "Lyrics will appear here...",
                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
          ],
        ),
      ),
    );
  }
}
