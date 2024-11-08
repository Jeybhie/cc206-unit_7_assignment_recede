import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final url =
      Uri.parse("https://www.demonslayer-api.com/api/v1/characters?page=1");
  final ExpandedTileController _tileController = ExpandedTileController();

  // Fetch characters as a list of `Characters` objects
  Future<List<Characters>> fetchCharacters() async {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> content = data['content'] ?? [];

      // Map JSON list to List<Characters>
      return content.map((json) => Characters.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Unit 7 - API Calls"),
      ),
      body: FutureBuilder<List<Characters>>(
        future: fetchCharacters(),
        builder:
            (BuildContext context, AsyncSnapshot<List<Characters>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Error fetching data: ${snapshot.error}'),
              );
            }
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final character = snapshot.data![index];
                  return ExpandedTile(
                    title: Text(character.name, style: TextStyle(fontSize: 20)),
                    leading: character.img.isNotEmpty
                        ? Image.network(character.img, width: 50, height: 50)
                        : const Icon(Icons.person),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Description:', style: TextStyle(fontSize: 20)),
                        Text(character.description),
                        Text('Quote:', style: TextStyle(fontSize: 20)),
                        Text(character.quote),
                      ],
                    ),
                    controller: _tileController,
                  );
                },
              );
            } else {
              return const Center(child: Text('No character data found.'));
            }
          }
          return Container();
        },
      ),
    );
  }
}

class Characters {
  final int id;
  final String name;
  final int age;
  final String gender;
  final String race;
  final String description;
  final String img;
  final String quote;

  const Characters({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.race,
    required this.description,
    required this.img,
    required this.quote,
  });

  factory Characters.fromJson(Map<String, dynamic> json) {
    return Characters(
      id: json['id'],
      name: json['name'],
      age: json['age'],
      gender: json['gender'],
      race: json['race'],
      description: json['description'],
      img: json['img'],
      quote: json['quote'],
    );
  }
}
