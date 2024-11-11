import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<dynamic>> _futureCharacters;

  // Fetch data from the Naruto API
  Future<List<dynamic>> _fetchCharacters() async {
    const apiUrl = 'https://narutodb.xyz/api/character';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['characters'] ?? [];
    } else {
      throw Exception('Failed to fetch characters');
    }
  }

  @override
  void initState() {
    super.initState();
    _futureCharacters = _fetchCharacters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Naruto Characters'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _futureCharacters,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final characters = snapshot.data!;
            return ListView.builder(
              itemCount: characters.length,
              itemBuilder: (context, index) {
                final character = characters[index];
                return NarutoCharacterTile(character: character);
              },
            );
          } else {
            return const Center(child: Text('No characters found'));
          }
        },
      ),
    );
  }
}

class NarutoCharacterTile extends StatelessWidget {
  final Map<String, dynamic> character;
  final ExpandedTileController _controller = ExpandedTileController();

  NarutoCharacterTile({Key? key, required this.character}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 4.0,
      child: ExpandedTile(
        controller: _controller,
        theme: ExpandedTileThemeData(
          headerColor: Colors.grey.shade200,
          contentBackgroundColor: Colors.white,
          contentPadding: const EdgeInsets.all(12.0),
        ),
        title: Row(
          children: [
            character['images'] != null && character['images'].isNotEmpty
                ? Image.network(
                    character['images'][0],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.image_not_supported, size: 50),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                character['name'] ?? 'Unknown Character',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              character['description'] ?? 'No description available',
              style: const TextStyle(fontSize: 14),
            ),
            const Divider(),
            _buildInfoRow('Jutsu', character['jutsu']),
            _buildInfoRow('Traits', character['uniqueTraits']),
            const Divider(),
            const Text(
              'Debut Information:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            _buildDebutInfo(character['debut']),
            const Divider(),
            const Text(
              'Personal Information:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            _buildPersonalInfo(character['personal']),
            const Divider(),
            const Text(
              'Rank Information:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            _buildRankInfo(character['rank']),
            const Divider(),
            const Text(
              'Voice Actors:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            _buildVoiceActors(character['voiceActors']),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, dynamic info) {
    if (info != null && info is List && info.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Text(
          '$title: ${info.join(", ")}',
          style: const TextStyle(fontSize: 14),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildDebutInfo(Map<String, dynamic>? debut) {
    if (debut != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Novel: ${debut['novel'] ?? 'N/A'}'),
          Text('Movie: ${debut['movie'] ?? 'N/A'}'),
          Text('Appears In: ${debut['appearsIn'] ?? 'N/A'}'),
        ],
      );
    }
    return const Text('No debut information available');
  }

  Widget _buildPersonalInfo(Map<String, dynamic>? personal) {
    if (personal != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (personal['birthdate'] != null) Text('Birthdate: ${personal['birthdate']}'),
          if (personal['sex'] != null) Text('Sex: ${personal['sex']}'),
          if (personal['status'] != null) Text('Status: ${personal['status']}'),
          if (personal['affiliation'] != null) Text('Affiliation: ${personal['affiliation']}'),
        ],
      );
    }
    return const Text('No personal information available');
  }

  Widget _buildRankInfo(Map<String, dynamic>? rank) {
    if (rank != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (rank['ninjaRank'] != null) Text('Ninja Rank: ${rank['ninjaRank']}'),
          if (rank['ninjaRegistration'] != null) Text('Registration: ${rank['ninjaRegistration']}'),
        ],
      );
    }
    return const Text('No rank information available');
  }

  Widget _buildVoiceActors(Map<String, dynamic>? voiceActors) {
    if (voiceActors != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (voiceActors['japanese'] != null) Text('Japanese: ${voiceActors['japanese']}'),
          if (voiceActors['english'] != null) Text('English: ${voiceActors['english']}'),
        ],
      );
    }
    return const Text('No voice actor information available');
  }
}
