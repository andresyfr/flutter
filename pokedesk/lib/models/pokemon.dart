class Pokemon {
  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;

  const Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      id: json['id'],
      name: json['name'],
      imageUrl: json['sprites']['other']['official-artwork']['front_default'] ??
          json['sprites']['front_default'] ??
          '',
      types: (json['types'] as List)
          .map((t) => t['type']['name'] as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'imageUrl': imageUrl,
        'types': types,
      };

  factory Pokemon.fromStorage(Map<String, dynamic> json) => Pokemon(
        id: json['id'],
        name: json['name'],
        imageUrl: json['imageUrl'],
        types: List<String>.from(json['types']),
      );
}
