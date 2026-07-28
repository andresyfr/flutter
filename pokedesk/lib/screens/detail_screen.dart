import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../models/pokemon.dart';
import '../services/favorites_service.dart';
import '../services/theme_service.dart';
import '../widgets/evolution_chain.dart';
import '../widgets/stat_bar.dart';
import '../widgets/type_chip.dart';

class DetailScreen extends StatefulWidget {
  final Pokemon pokemon;

  const DetailScreen({super.key, required this.pokemon});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final FavoritesService _favService = FavoritesService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isFavorite = false;
  bool _showShiny = false;

  static const _statLabels = {
    'hp': 'HP',
    'attack': 'Ataque',
    'defense': 'Defensa',
    'special-attack': 'Sp. Ataque',
    'special-defense': 'Sp. Defensa',
    'speed': 'Velocidad',
  };

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _checkFavorite() async {
    final result = await _favService.isFavorite(widget.pokemon.id);
    if (mounted) setState(() => _isFavorite = result);
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

  Future<void> _playCry() async {
    if (widget.pokemon.cryUrl.isEmpty) return;
    await HapticFeedback.selectionClick();
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(widget.pokemon.cryUrl));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo reproducir el sonido')),
        );
      }
    }
  }

  void _share() {
    final p = widget.pokemon;
    final name = _capitalize(p.name);
    Share.share(
      '¡Mira a $name (#${p.id.toString().padLeft(3, '0')})! '
      'Tipo: ${p.types.join(', ')}. Descúbrelo en PokéFlutter ⚡',
      subject: 'Pokémon $name',
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    final pokemon = widget.pokemon;
    final typeColor = TypeChip.colorFor(pokemon.types.first);
    final currentImage =
        _showShiny && pokemon.shinyImageUrl.isNotEmpty
            ? pokemon.shinyImageUrl
            : pokemon.imageUrl;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 360,
            pinned: true,
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_outline,
                  color: Colors.redAccent,
                ),
                onPressed: _toggleFavorite,
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: _share,
              ),
              IconButton(
                icon: Icon(
                  Theme.of(context).brightness == Brightness.dark
                      ? Icons.light_mode
                      : Icons.dark_mode,
                ),
                onPressed: ThemeService.toggleTheme,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _capitalize(pokemon.name),
                style: const TextStyle(color: Colors.white),
              ),
              background: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      typeColor.withValues(alpha: 0.55),
                      Colors.black,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Stack(
                    children: [
                      Center(
                        child: Hero(
                          tag: 'pokemon-${pokemon.id}',
                          child: CachedNetworkImage(
                            imageUrl: currentImage,
                            height: 220,
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(
                                    color: Colors.white),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.catching_pokemon,
                                    size: 120, color: Colors.white),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        left: 12,
                        child: _CircleButton(
                          icon: Icons.volume_up,
                          label: 'Cry',
                          onTap: _playCry,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 12,
                        child: _CircleButton(
                          icon: Icons.auto_awesome,
                          label: 'Shiny',
                          active: _showShiny,
                          onTap: pokemon.shinyImageUrl.isEmpty
                              ? null
                              : () => setState(() => _showShiny = !_showShiny),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#${pokemon.id.toString().padLeft(3, '0')}',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(pokemon, typeColor),
                  const SizedBox(height: 24),
                  const Text(
                    'Stats base',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ..._statLabels.entries.map(
                    (e) => StatBar(
                      label: e.value,
                      value: pokemon.stats[e.key] ?? 0,
                      color: typeColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Evolución',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  EvolutionChainView(
                    pokemonId: pokemon.id,
                    highlightId: pokemon.id,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _typeIcons = {
    'fire': Icons.local_fire_department,
    'water': Icons.water_drop,
    'grass': Icons.eco,
    'electric': Icons.bolt,
    'ice': Icons.ac_unit,
    'psychic': Icons.psychology,
    'poison': Icons.science,
    'flying': Icons.air,
    'bug': Icons.bug_report,
    'rock': Icons.landscape,
    'ground': Icons.terrain,
    'ghost': Icons.nightlight,
    'dragon': Icons.whatshot,
    'fairy': Icons.auto_awesome,
    'fighting': Icons.sports_mma,
    'steel': Icons.shield,
    'dark': Icons.dark_mode,
    'normal': Icons.circle,
  };

  Widget _buildInfoRow(Pokemon pokemon, Color typeColor) {
    final firstType = pokemon.types.first;
    return Row(
      children: [
        Expanded(
          child: _InfoCard(
            highlight: true,
            color: typeColor,
            icon: _typeIcons[firstType] ?? Icons.catching_pokemon,
            value: firstType.toUpperCase(),
            label: 'Tipo',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _InfoCard(
            value: '${pokemon.heightInMeters.toStringAsFixed(1)} m',
            label: 'Altura',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _InfoCard(
            value: '${pokemon.weightInKg.toStringAsFixed(1)} kg',
            label: 'Peso',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _InfoCard(
            value: '${pokemon.baseExperience}',
            label: 'Exp base',
          ),
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool active;

  const _CircleButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return Material(
      color: active
          ? Colors.amber.withValues(alpha: 0.85)
          : Colors.white.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 16,
                  color: disabled ? Colors.white38 : Colors.white),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: disabled ? Colors.white38 : Colors.white,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData? icon;
  final bool highlight;
  final Color? color;

  const _InfoCard({
    required this.value,
    required this.label,
    this.icon,
    this.highlight = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bg = highlight && color != null
        ? color!.withValues(alpha: 0.15)
        : Theme.of(context).colorScheme.surfaceContainerHighest
            .withValues(alpha: 0.4);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
          ],
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: highlight ? color : null,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
