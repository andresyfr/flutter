import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';

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
}
