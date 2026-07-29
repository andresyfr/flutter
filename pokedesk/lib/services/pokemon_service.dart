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

  /// Índice completo (nombre + url) de todos los Pokémon, cacheado en memoria
  /// para no re-descargarlo en cada búsqueda.
  static List<dynamic>? _indexCache;

  Future<List<Pokemon>> getPokemons(int limit, int offset) async {
    final response = await http.get(
      Uri.parse('$baseUrl/pokemon?limit=$limit&offset=$offset'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;
      final urls = results.map((r) => r['url'] as String).toList();
      return _fetchDetailsInParallel(urls);
    }
    throw Exception('Error al cargar pokemones');
  }

  /// Descarga los detalles de varias URLs en paralelo (en lotes para no
  /// saturar la API), preservando el orden original.
  Future<List<Pokemon>> _fetchDetailsInParallel(
    List<String> urls, {
    int concurrency = 12,
  }) async {
    final List<Pokemon> pokemons = [];
    for (var i = 0; i < urls.length; i += concurrency) {
      final batch = urls.skip(i).take(concurrency);
      final fetched = await Future.wait(batch.map(getPokemonDetails));
      pokemons.addAll(fetched);
    }
    return pokemons;
  }

  /// Obtiene (y cachea) el índice completo de nombres de Pokémon.
  Future<List<dynamic>> _getIndex() async {
    if (_indexCache != null) return _indexCache!;
    final response =
        await http.get(Uri.parse('$baseUrl/pokemon?limit=100000&offset=0'));
    if (response.statusCode != 200) {
      throw Exception('Error al cargar el índice de Pokémon');
    }
    final data = json.decode(response.body);
    _indexCache = data['results'] as List;
    return _indexCache!;
  }

  /// Busca Pokémon por nombre directamente contra la API. Prioriza los que
  /// empiezan por la consulta y limita el número de resultados para que la
  /// búsqueda sea rápida.
  Future<List<Pokemon>> searchByName(String query, {int maxResults = 40}) async {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return [];

    final index = await _getIndex();
    final matches = index
        .where((e) => (e['name'] as String).contains(q))
        .toList()
      ..sort((a, b) {
        final an = a['name'] as String;
        final bn = b['name'] as String;
        final aStarts = an.startsWith(q);
        final bStarts = bn.startsWith(q);
        if (aStarts != bStarts) return aStarts ? -1 : 1;
        return an.compareTo(bn);
      });

    final urls = matches
        .take(maxResults)
        .map((e) => e['url'] as String)
        .toList();
    return _fetchDetailsInParallel(urls);
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
