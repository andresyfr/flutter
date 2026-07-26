import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pokemon.dart';

class FavoritesService {
  static const _key = 'favorites';

  /// Notifica cambios en tiempo real a cualquier listener
  static final notifier = ValueNotifier<int>(0);
  
  /// Notifica el contador de favoritos
  static final favoriteCount = ValueNotifier<int>(0);

  Future<List<Pokemon>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw.map((e) => Pokemon.fromStorage(json.decode(e))).toList();
  }

  Future<void> toggle(Pokemon pokemon) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final isFav = raw.any((e) {
      final decoded = json.decode(e) as Map<String, dynamic>;
      return decoded['id'] == pokemon.id;
    });

    if (isFav) {
      raw.removeWhere((e) {
        final decoded = json.decode(e) as Map<String, dynamic>;
        return decoded['id'] == pokemon.id;
      });
    } else {
      raw.add(json.encode(pokemon.toJson()));
    }

    await prefs.setStringList(_key, raw);
    notifier.value++; // notifica el cambio
    favoriteCount.value = raw.length; // actualiza el contador
  }

  Future<bool> isFavorite(int pokemonId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw.any((e) {
      final decoded = json.decode(e) as Map<String, dynamic>;
      return decoded['id'] == pokemonId;
    });
  }

  /// Inicializa el contador de favoritos (llamar al inicio de la app)
  Future<void> initializeFavoriteCount() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    favoriteCount.value = raw.length;
  }
}
