import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';

class EvolutionStage {
  final int id;
  final String name;

  const EvolutionStage({required this.id, required this.name});

  String get imageUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
}

class PokemonService {
  static const String baseUrl = 'https://pokeapi.co/api/v2';

  Future<List<Pokemon>> getPokemons(int limit, int offset) async {
    final response = await http.get(
      Uri.parse('$baseUrl/pokemon?limit=$limit&offset=$offset'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;
      
      List<Pokemon> pokemons = [];
      for (var result in results) {
        final pokemon = await getPokemonDetails(result['url']);
        pokemons.add(pokemon);
      }
      
      return pokemons;
    }
    throw Exception('Error al cargar pokemones');
  }

  Future<Pokemon> getPokemonDetails(String url) async {
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      return Pokemon.fromJson(json.decode(response.body));
    }
    throw Exception('Error al cargar detalles');
  }

  /// Obtiene la cadena de evolución de un Pokémon a partir de su id.
  Future<List<EvolutionStage>> getEvolutionChain(int pokemonId) async {
    final speciesRes =
        await http.get(Uri.parse('$baseUrl/pokemon-species/$pokemonId'));
    if (speciesRes.statusCode != 200) {
      throw Exception('Error al cargar la especie');
    }
    final speciesData = json.decode(speciesRes.body);
    final chainUrl = speciesData['evolution_chain']['url'] as String;

    final chainRes = await http.get(Uri.parse(chainUrl));
    if (chainRes.statusCode != 200) {
      throw Exception('Error al cargar la cadena de evolución');
    }
    final chainData = json.decode(chainRes.body);

    final List<EvolutionStage> stages = [];
    Map<String, dynamic>? node = chainData['chain'] as Map<String, dynamic>?;
    while (node != null) {
      final species = node['species'] as Map<String, dynamic>;
      stages.add(EvolutionStage(
        id: _idFromSpeciesUrl(species['url'] as String),
        name: species['name'] as String,
      ));
      final evolvesTo = node['evolves_to'] as List;
      node = evolvesTo.isNotEmpty
          ? evolvesTo.first as Map<String, dynamic>
          : null;
    }
    return stages;
  }

  int _idFromSpeciesUrl(String url) {
    final parts = url.split('/').where((p) => p.isNotEmpty).toList();
    return int.parse(parts.last);
  }
}
