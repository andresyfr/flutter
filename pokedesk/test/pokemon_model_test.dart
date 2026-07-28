import 'package:flutter_test/flutter_test.dart';
import 'package:pokeflutter/models/pokemon.dart';

void main() {
  group('Pokemon.fromJson', () {
    final sampleJson = {
      'id': 4,
      'name': 'charmander',
      'height': 6,
      'weight': 85,
      'base_experience': 62,
      'types': [
        {
          'type': {'name': 'fire'}
        }
      ],
      'sprites': {
        'front_default': 'https://example.com/front.png',
        'other': {
          'official-artwork': {
            'front_default': 'https://example.com/artwork.png',
            'front_shiny': 'https://example.com/shiny.png',
          }
        }
      },
      'cries': {'latest': 'https://example.com/cry.ogg'},
      'stats': [
        {
          'base_stat': 39,
          'stat': {'name': 'hp'}
        },
        {
          'base_stat': 52,
          'stat': {'name': 'attack'}
        },
        {
          'base_stat': 65,
          'stat': {'name': 'speed'}
        },
      ],
    };

    test('parsea los campos básicos correctamente', () {
      final pokemon = Pokemon.fromJson(sampleJson);

      expect(pokemon.id, 4);
      expect(pokemon.name, 'charmander');
      expect(pokemon.types, ['fire']);
      expect(pokemon.baseExperience, 62);
    });

    test('prefiere el artwork oficial para la imagen', () {
      final pokemon = Pokemon.fromJson(sampleJson);
      expect(pokemon.imageUrl, 'https://example.com/artwork.png');
      expect(pokemon.shinyImageUrl, 'https://example.com/shiny.png');
    });

    test('parsea stats y calcula altura/peso', () {
      final pokemon = Pokemon.fromJson(sampleJson);

      expect(pokemon.stats['hp'], 39);
      expect(pokemon.stats['attack'], 52);
      expect(pokemon.stats['speed'], 65);
      expect(pokemon.heightInMeters, 0.6);
      expect(pokemon.weightInKg, 8.5);
      expect(pokemon.cryUrl, 'https://example.com/cry.ogg');
    });

    test('round-trip toJson/fromStorage conserva los datos', () {
      final original = Pokemon.fromJson(sampleJson);
      final restored = Pokemon.fromStorage(original.toJson());

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.stats['hp'], 39);
      expect(restored.baseExperience, 62);
      expect(restored.shinyImageUrl, original.shinyImageUrl);
    });
  });
}
