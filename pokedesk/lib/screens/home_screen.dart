import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/pokemon.dart';
import '../services/pokemon_service.dart';
import '../widgets/pokemon_card.dart';
import '../widgets/type_chip.dart';

class HomeScreen extends StatefulWidget {
  final List<Pokemon> initialPokemons;

  const HomeScreen({super.key, this.initialPokemons = const []});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PokemonService _service = PokemonService();
  final TextEditingController _searchController = TextEditingController();
  late final ScrollController _scrollController;

  List<Pokemon> _allPokemons = [];
  List<Pokemon> _filtered = [];
  bool _isLoading = false;
  int _offset = 0;
  final int _limit = 20;
  bool _sortByName = true;
  final Set<String> _selectedTypes = {};
  late Set<String> _availableTypes;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _availableTypes = {};
    
    if (widget.initialPokemons.isNotEmpty) {
      _allPokemons = List.from(widget.initialPokemons);
      _filtered = _allPokemons;
      _offset = widget.initialPokemons.length;
    } else {
      _loadPokemons();
    }
    _searchController.addListener(_onSearch);
    _extractAvailableTypes();
  }

  void _extractAvailableTypes() {
    _availableTypes.clear();
    for (var pokemon in _allPokemons) {
      _availableTypes.addAll(pokemon.types);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Cargar más cuando está a 200px del final
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _searchController.text.isEmpty) {
      _loadPokemons();
    }
  }

  void _onSearch() {
    final query = _searchController.text.toLowerCase();
    _applyFilters(query);
  }

  void _toggleTypeFilter(String type) {
    setState(() {
      if (_selectedTypes.contains(type)) {
        _selectedTypes.remove(type);
      } else {
        _selectedTypes.add(type);
      }
      _applyFilters(_searchController.text.toLowerCase());
    });
  }

  void _applyFilters(String query) {
    setState(() {
      _filtered = _allPokemons.where((pokemon) {
        // Filtro de búsqueda
        final matchesSearch = query.isEmpty ||
            pokemon.name.toLowerCase().contains(query) ||
            pokemon.id.toString().contains(query);

        // Filtro de tipo
        final matchesType = _selectedTypes.isEmpty ||
            pokemon.types.any((type) => _selectedTypes.contains(type));

        return matchesSearch && matchesType;
      }).toList();

      _applySorting();
    });
  }

  void _applySorting() {
    if (_sortByName) {
      _filtered.sort((a, b) => a.name.compareTo(b.name));
    } else {
      _filtered.sort((a, b) => a.id.compareTo(b.id));
    }
  }

  Future<void> _refresh() async {
    _offset = 0;
    _allPokemons.clear();
    _filtered.clear();
    _selectedTypes.clear();
    await _loadPokemons();
  }

  Future<void> _loadPokemons() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final pokemons = await _service.getPokemons(_limit, _offset);
      setState(() {
        _allPokemons.addAll(pokemons);
        _extractAvailableTypes();
        _applyFilters(_searchController.text.toLowerCase());
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

  Widget _buildTypeFilters() {
    if (_availableTypes.isEmpty) return const SizedBox.shrink();
    final types = _availableTypes.toList()..sort();
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: types.map((type) {
          final selected = _selectedTypes.contains(type);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: FilterChip(
              label: Text(type),
              selected: selected,
              showCheckmark: false,
              backgroundColor: TypeChip.colorFor(type).withValues(alpha: 0.15),
              selectedColor: TypeChip.colorFor(type),
              labelStyle: TextStyle(
                color: selected ? Colors.white : null,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
              onSelected: (_) => _toggleTypeFilter(type),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PokéFlutter'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Comparar Pokémon',
            icon: const Icon(Icons.compare_arrows),
            onPressed: () => context.push('/compare', extra: _allPokemons),
          ),
          IconButton(
            icon: Icon(_sortByName
                ? Icons.sort_by_alpha
                : Icons.numbers),
            onPressed: () {
              setState(() {
                _sortByName = !_sortByName;
                _applySorting();
              });
            },
          ),
        ],
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
          _buildTypeFilters(),
          Expanded(
            child: _filtered.isEmpty && !_isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.catching_pokemon_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay Pokémon',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView.builder(
                      controller: _scrollController,
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
