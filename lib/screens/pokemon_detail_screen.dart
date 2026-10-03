import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/pokemon_api.dart';
import '../state/favorites_provider.dart';

class PokemonDetailScreen extends StatefulWidget {
  final String name;

  const PokemonDetailScreen({super.key, required this.name});

  @override
  State<PokemonDetailScreen> createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  final PokemonApi _api = PokemonApi();

  Map<String, dynamic>? _pokemon;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      final data = await _api.getPokemonDetails(widget.name);

      setState(() {
        _pokemon = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load details';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null || _pokemon == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(_error ?? 'Something went wrong')),
      );
    }

    final pokemon = _pokemon!;
    final id = pokemon['id'] as int;
    final name = pokemon['name'] as String;

    final image =
        pokemon['sprites']['other']['official-artwork']['front_default'];

    final types = (pokemon['types'] as List)
        .map((type) => type['type']['name'].toString())
        .toList();

    final abilities = (pokemon['abilities'] as List)
        .map((ability) => ability['ability']['name'].toString())
        .toList();

    final stats = pokemon['stats'] as List;

    final favorites = context.watch<FavoritesProvider>();
    final isFavorite = favorites.isFavorite(id);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: Text(
          name.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              favorites.toggleFavorite(id);
            },
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                image,
                height: 250,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.image_not_supported, size: 80),
              ),
            ),

            Center(
              child: Text(
                '#${id.toString().padLeft(3, '0')}',
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),

            const SizedBox(height: 5),

            Center(
              child: Text(
                name.toUpperCase(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Wrap(
              spacing: 8,
              children: types.map((type) {
                return Chip(
                  label: Text(
                    type.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: _typeColor(type),
                );
              }).toList(),
            ),

            const SizedBox(height: 25),

            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    title: 'Height',
                    value: '${pokemon['height'] / 10} m',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoCard(
                    title: 'Weight',
                    value: '${pokemon['weight'] / 10} kg',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            const Text(
              'Abilities',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            ...abilities.map(
              (ability) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '• ${ability.toUpperCase()}',
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Base Stats',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            ...stats.map(
              (stat) => _StatRow(
                name: stat['stat']['name'].toString(),
                value: stat['base_stat'] as int,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'fire':
        return Colors.red;
      case 'water':
        return Colors.blue;
      case 'grass':
        return Colors.green;
      case 'electric':
        return Colors.orange;
      case 'psychic':
        return Colors.purple;
      case 'ice':
        return Colors.cyan;
      case 'poison':
        return Colors.deepPurple;
      case 'ground':
        return Colors.brown;
      case 'flying':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;

  const _InfoCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String name;
  final int value;

  const _StatRow({required this.name, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(name.toUpperCase())),
          Expanded(
            child: LinearProgressIndicator(value: value / 150, minHeight: 8),
          ),
          const SizedBox(width: 10),
          Text('$value'),
        ],
      ),
    );
  }
}
