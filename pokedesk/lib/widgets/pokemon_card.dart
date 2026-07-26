import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../models/pokemon.dart';
import 'type_chip.dart';

class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;

  const PokemonCard({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/detail', extra: pokemon),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Hero(
                tag: 'pokemon-${pokemon.id}',
                child: CachedNetworkImage(
                  imageUrl: pokemon.imageUrl,
                  width: 80,
                  height: 80,
                  placeholder: (context, url) => const SizedBox(
                    width: 80,
                    height: 80,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.catching_pokemon, size: 80),
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${pokemon.id.toString().padLeft(3, '0')}',
                      style:
                          const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      pokemon.name[0].toUpperCase() +
                          pokemon.name.substring(1),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      children: pokemon.types
                          .map((t) => TypeChip(type: t))
                          .toList(),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
