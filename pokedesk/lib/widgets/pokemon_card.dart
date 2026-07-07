import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/pokemon.dart';

class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;

  const PokemonCard({super.key, required this.pokemon});

  Color _getTypeColor(String type) {
    const colors = {
      'normal': Colors.grey,
      'fire': Colors.orange,
      'water': Colors.blue,
      'electric': Colors.yellow,
      'grass': Colors.green,
      'ice': Colors.lightBlue,
      'fighting': Colors.red,
      'poison': Colors.purple,
      'ground': Colors.brown,
      'flying': Colors.indigo,
      'psychic': Colors.pink,
      'bug': Colors.lightGreen,
      'rock': Colors.brown,
      'ghost': Colors.deepPurple,
      'dragon': Colors.deepOrange,
      'dark': Colors.black87,
      'steel': Colors.blueGrey,
      'fairy': Colors.pinkAccent,
    };
    return colors[type] ?? Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            CachedNetworkImage(
              imageUrl: pokemon.imageUrl,
              width: 80,
              height: 80,
              placeholder: (context, url) =>
                  const SizedBox(width: 80, height: 80, child: Center(child: CircularProgressIndicator())),
              errorWidget: (context, url, error) => const Icon(Icons.catching_pokemon, size: 80),
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#${pokemon.id.toString().padLeft(3, '0')}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    pokemon.name[0].toUpperCase() + pokemon.name.substring(1),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    children: pokemon.types.map((type) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getTypeColor(type),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          type,
                          style: const TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
