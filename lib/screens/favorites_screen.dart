import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/favorites_provider.dart';
import 'pokemon_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  String _pokemonName(int id) {
    const names = {
      1: 'bulbasaur',
      2: 'ivysaur',
      3: 'venusaur',
      4: 'charmander',
      5: 'charmeleon',
      6: 'charizard',
      7: 'squirtle',
      8: 'wartortle',
      9: 'blastoise',
      10: 'caterpie',
      11: 'metapod',
      12: 'butterfree',
      13: 'weedle',
      14: 'kakuna',
      15: 'beedrill',
      16: 'pidgey',
      17: 'pidgeotto',
      18: 'pidgeot',
      19: 'rattata',
      20: 'raticate',
    };

    return names[id] ?? id.toString();
  }

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();

    if (favorites.favorites.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Favorites',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: const Center(
          child: Text(
            'No favorites yet',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favorites',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: favorites.favorites.length,
        itemBuilder: (context, index) {
          final id = favorites.favorites.elementAt(index);
          final name = _pokemonName(id);

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            child: ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PokemonDetailScreen(name: name),
                  ),
                );
              },
              leading: Image.network(
                'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png',
                width: 60,
                height: 60,
                errorBuilder: (_, _, _) {
                  return const Icon(Icons.image_not_supported);
                },
              ),
              title: Text(
                name.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('#${id.toString().padLeft(3, '0')}'),
              trailing: IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red),
                onPressed: () {
                  favorites.toggleFavorite(id);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
