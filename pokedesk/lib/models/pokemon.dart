class Pokemon {
  final int id;
  final String name;
  final String imageUrl;
  final String shinyImageUrl;
  final List<String> types;
  final int height; // decímetros
  final int weight; // hectogramos
  final int baseExperience;
  final String cryUrl;
  final Map<String, int> stats; // hp, attack, defense, special-attack, special-defense, speed

  const Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.shinyImageUrl = '',
    required this.types,
    this.height = 0,
    this.weight = 0,
    this.baseExperience = 0,
    this.cryUrl = '',
    this.stats = const {},
  });

  double get heightInMeters => height / 10;
  double get weightInKg => weight / 10;

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final sprites = json['sprites'] as Map<String, dynamic>?;
    final artwork =
        sprites?['other']?['official-artwork'] as Map<String, dynamic>?;

    final Map<String, int> parsedStats = {};
    for (final s in (json['stats'] as List? ?? [])) {
      parsedStats[s['stat']['name'] as String] = s['base_stat'] as int;
    }

    return Pokemon(
      id: json['id'],
      name: json['name'],
      imageUrl: artwork?['front_default'] ?? sprites?['front_default'] ?? '',
      shinyImageUrl: artwork?['front_shiny'] ?? sprites?['front_shiny'] ?? '',
      types: (json['types'] as List)
          .map((t) => t['type']['name'] as String)
          .toList(),
      height: json['height'] ?? 0,
      weight: json['weight'] ?? 0,
      baseExperience: json['base_experience'] ?? 0,
      cryUrl: json['cries']?['latest'] ?? '',
      stats: parsedStats,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'imageUrl': imageUrl,
        'shinyImageUrl': shinyImageUrl,
        'types': types,
        'height': height,
        'weight': weight,
        'baseExperience': baseExperience,
        'cryUrl': cryUrl,
        'stats': stats,
      };

  factory Pokemon.fromStorage(Map<String, dynamic> json) => Pokemon(
        id: json['id'],
        name: json['name'],
        imageUrl: json['imageUrl'],
        shinyImageUrl: json['shinyImageUrl'] ?? '',
        types: List<String>.from(json['types']),
        height: json['height'] ?? 0,
        weight: json['weight'] ?? 0,
        baseExperience: json['baseExperience'] ?? 0,
        cryUrl: json['cryUrl'] ?? '',
        stats: (json['stats'] as Map?)?.map(
              (k, v) => MapEntry(k as String, v as int),
            ) ??
            const {},
      );
}
