import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/pokemon.dart';

class PokemonApi {
  static const String baseUrl = 'https://pokeapi.co/api/v2';

  Future<PokemonResponse> getPokemon({String? url}) async {
    final response = await http.get(
      Uri.parse(url ?? '$baseUrl/pokemon?limit=20&offset=0'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load Pokémon');
    }

    final data = jsonDecode(response.body);

    final pokemonList = (data['results'] as List)
        .map((item) => Pokemon.fromJson(item))
        .toList();

    return PokemonResponse(pokemon: pokemonList, nextUrl: data['next']);
  }

  Future<Map<String, dynamic>> getPokemonDetails(String name) async {
    final response = await http.get(Uri.parse('$baseUrl/pokemon/$name'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load Pokémon details');
    }

    return jsonDecode(response.body);
  }
}

class PokemonResponse {
  final List<Pokemon> pokemon;
  final String? nextUrl;

  PokemonResponse({required this.pokemon, required this.nextUrl});
}
