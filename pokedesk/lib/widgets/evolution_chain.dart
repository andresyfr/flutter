import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../services/pokemon_service.dart';

class EvolutionChainView extends StatefulWidget {
  final int pokemonId;
  final int highlightId;

  const EvolutionChainView({
    super.key,
    required this.pokemonId,
    required this.highlightId,
  });

  @override
  State<EvolutionChainView> createState() => _EvolutionChainViewState();
}

class _EvolutionChainViewState extends State<EvolutionChainView> {
  final PokemonService _service = PokemonService();
  late Future<List<EvolutionStage>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getEvolutionChain(widget.pokemonId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EvolutionStage>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasError) {
          return const Text('No se pudo cargar la evolución');
        }
        final stages = snapshot.data ?? [];
        if (stages.length <= 1) {
          return const Text('Este Pokémon no evoluciona');
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < stages.length; i++) ...[
              if (i > 0)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(Icons.arrow_forward, color: Colors.grey),
                ),
              _EvolutionItem(
                stage: stages[i],
                highlighted: stages[i].id == widget.highlightId,
              ),
            ],
          ],
        );
      },
    );
  }
}

class _EvolutionItem extends StatelessWidget {
  final EvolutionStage stage;
  final bool highlighted;

  const _EvolutionItem({required this.stage, required this.highlighted});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: highlighted
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
                  : Colors.transparent,
              border: highlighted
                  ? Border.all(color: Theme.of(context).colorScheme.primary)
                  : null,
            ),
            child: CachedNetworkImage(
              imageUrl: stage.imageUrl,
              width: 64,
              height: 64,
              placeholder: (context, url) => const SizedBox(
                width: 64,
                height: 64,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.catching_pokemon, size: 48),
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stage.name[0].toUpperCase() + stage.name.substring(1),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: highlighted ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
