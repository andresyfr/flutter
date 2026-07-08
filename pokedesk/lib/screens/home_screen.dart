import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../services/pokemon_service.dart';
import '../widgets/pokemon_card.dart';

class HomeScreen extends StatefulWidget {
  final List<Pokemon> initialPokemons;

  const HomeScreen({super.key, this.initialPokemons = const []});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PokemonService _service = PokemonService();
  final TextEditingController _searchController = TextEditingController();

  List<Pokemon> _allPokemons = [];
  List<Pokemon> _filtered = [];
  bool _isLoading = false;
  int _offset = 0;
  final int _limit = 20;

  @override
  void initState() {
    super.initState();
    if (widget.initialPokemons.isNotEmpty) {
      _allPokemons = List.from(widget.initialPokemons);
      _filtered = _allPokemons;
      _offset = widget.initialPokemons.length;
    } else {
      _loadPokemons();
    }
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filtered = query.isEmpty
          ? _allPokemons
          : _allPokemons
              .where((p) =>
                  p.name.toLowerCase().contains(query) ||
                  p.id.toString().contains(query))
              .toList();
    });
  }

  Future<void> _loadPokemons() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final pokemons = await _service.getPokemons(_limit, _offset);
      setState(() {
        _allPokemons.addAll(pokemons);
        _filtered = _allPokemons;
        _offset += _limit;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PokéFlutter'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar Pokémon por nombre o número...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (scrollInfo) {
                if (!_isLoading &&
                    _searchController.text.isEmpty &&
                    scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent) {
                  _loadPokemons();
                }
                return false;
              },
              child: ListView.builder(
                itemCount: _filtered.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _filtered.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  return PokemonCard(pokemon: _filtered[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
