import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pokemon.dart';
import '../services/pokemon_api.dart';
import '../state/favorites_provider.dart';
import 'pokemon_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PokemonApi _api = PokemonApi();
  final TextEditingController _searchController = TextEditingController();

  final List<Pokemon> _pokemon = [];

  String? _nextUrl;
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPokemon();
  }

  Future<void> _loadPokemon() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _api.getPokemon();

      setState(() {
        _pokemon
          ..clear()
          ..addAll(result.pokemon);

        _nextUrl = result.nextUrl;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Failed to load Pokémon';
      });
    }
  }

  Future<void> _loadMore() async {
    if (_nextUrl == null || _loadingMore) return;

    setState(() {
      _loadingMore = true;
    });

    try {
      final result = await _api.getPokemon(url: _nextUrl);

      setState(() {
        _pokemon.addAll(result.pokemon);
        _nextUrl = result.nextUrl;
        _loadingMore = false;
      });
    } catch (e) {
      setState(() {
        _loadingMore = false;
      });
    }
  }

  List<Pokemon> get _filteredPokemon {
    final query = _searchController.text.toLowerCase().trim();

    if (query.isEmpty) {
      return _pokemon;
    }

    return _pokemon
        .where((pokemon) => pokemon.name.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final pokemon = _filteredPokemon;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),

      appBar: AppBar(
        title: const Text(
          'Pokédex',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _ErrorView(message: _error!, onRetry: _loadPokemon)
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search Pokémon',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: pokemon.isEmpty
                      ? const Center(child: Text('No Pokémon found'))
                      : NotificationListener<ScrollNotification>(
                          onNotification: (notification) {
                            if (notification.metrics.pixels >=
                                notification.metrics.maxScrollExtent - 200) {
                              _loadMore();
                            }

                            return false;
                          },

                          child: GridView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),

                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 0.82,
                                ),

                            itemCount: pokemon.length + (_loadingMore ? 1 : 0),

                            itemBuilder: (context, index) {
                              if (index >= pokemon.length) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              return _PokemonCard(pokemon: pokemon[index]);
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _PokemonCard extends StatelessWidget {
  final Pokemon pokemon;

  const _PokemonCard({required this.pokemon});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();

    final isFavorite = favorites.isFavorite(pokemon.id);

    return InkWell(
      borderRadius: BorderRadius.circular(18),

      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PokemonDetailScreen(name: pokemon.name),
          ),
        );
      },

      child: Card(
        elevation: 0,
        color: Colors.white,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),

        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Expanded(
                    child: Image.network(
                      pokemon.imageUrl,
                      fit: BoxFit.contain,

                      errorBuilder: (_, __, ___) {
                        return const Icon(Icons.image_not_supported);
                      },
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '#${pokemon.id.toString().padLeft(3, '0')}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),

                  Text(
                    pokemon.name.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            // Favorite button
            Positioned(
              top: 6,
              right: 6,

              child: IconButton(
                onPressed: () {
                  favorites.toggleFavorite(pokemon.id);
                },

                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,

                  color: isFavorite ? Colors.red : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,

        children: [
          Text(message),

          const SizedBox(height: 12),

          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
