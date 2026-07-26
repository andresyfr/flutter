import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/pokemon.dart';
import '../services/favorites_service.dart';
import '../widgets/type_chip.dart';

class DetailScreen extends StatefulWidget {
  final Pokemon pokemon;

  const DetailScreen({super.key, required this.pokemon});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final FavoritesService _favService = FavoritesService();
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    final result = await _favService.isFavorite(widget.pokemon.id);
    setState(() => _isFavorite = result);
  }

  Future<void> _toggleFavorite() async {
    await HapticFeedback.lightImpact();
    await _favService.toggle(widget.pokemon);
    setState(() => _isFavorite = !_isFavorite);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorite
                ? '${widget.pokemon.name} añadido a favoritos'
                : '${widget.pokemon.name} eliminado de favoritos',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pokemon = widget.pokemon;
    final dominantColor =
        TypeChip.colorFor(pokemon.types.first).withValues(alpha: 0.8);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: dominantColor,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_outline,
                  color: Colors.white,
                ),
                onPressed: _toggleFavorite,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                pokemon.name[0].toUpperCase() + pokemon.name.substring(1),
                style: const TextStyle(color: Colors.white),
              ),
              background: Container(
                color: dominantColor,
                child: Center(
                  child: Hero(
                    tag: 'pokemon-${pokemon.id}',
                    child: CachedNetworkImage(
                      imageUrl: pokemon.imageUrl,
                      height: 200,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(color: Colors.white),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.catching_pokemon, size: 100),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#${pokemon.id.toString().padLeft(3, '0')}',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Tipos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: pokemon.types
                        .map((t) => TypeChip(type: t))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
