import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/pokemon.dart';
import '../services/favorites_service.dart';
import '../widgets/pokemon_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: ValueListenableBuilder<int>(
        valueListenable: FavoritesService.notifier,
        builder: (context, _, __) {
          return FutureBuilder<List<Pokemon>>(
            future: FavoritesService().getAll(),
            builder: (context, snapshot) {
              final favorites = snapshot.data ?? [];
              if (favorites.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.favorite_outline,
                          size: 80, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'Aún no tienes favoritos',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => context.go('/home'),
                        child: const Text('Explorar Pokédex'),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                itemCount: favorites.length,
                itemBuilder: (context, index) =>
                    PokemonCard(pokemon: favorites[index]),
              );
            },
          );
        },
      ),
    );
  }
}
