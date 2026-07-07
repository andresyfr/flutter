# PokéFlutter

Aplicación Pokédex construida con Flutter que consume la [PokéAPI](https://pokeapi.co/).

## Características

- Lista de Pokémon en formato `ListView` con tarjetas horizontales
- Búsqueda en vivo por nombre o número de Pokémon
- Scroll infinito (carga 20 Pokémon por página)
- Imágenes oficiales con caché (`cached_network_image`)
- Tipos de Pokémon con colores distintivos

## Árbol de widgets

```
MaterialApp
└── Scaffold
    ├── AppBar → Text("PokéFlutter")
    └── Body → Column
        ├── TextField (búsqueda en vivo)
        └── ListView
            └── PokemonCard(id, nombre, imagen, tipos)
```

## Estructura del proyecto

```
pokedesk/
├── android/
├── ios/
├── web/
├── lib/
│   ├── models/
│   │   └── pokemon.dart          # Modelo de datos Pokemon
│   ├── services/
│   │   └── pokemon_service.dart  # Consumo de PokéAPI
│   ├── screens/
│   │   └── home_screen.dart      # Pantalla principal con búsqueda y lista
│   ├── widgets/
│   │   └── pokemon_card.dart     # Tarjeta horizontal de Pokémon
│   └── main.dart                 # Punto de entrada
├── test/
│   └── widget_test.dart          # Smoke test básico
├── pubspec.yaml
└── README.md
```

## Dependencias

```yaml
dependencies:
  http: ^1.1.0                    # Peticiones HTTP a PokéAPI
  cached_network_image: ^3.3.0    # Caché de imágenes

# Próximas sesiones del bootcamp:
# dio: ^5.7.0                     (HTTP — Sesión 7)
# go_router: ^14.0.0              (Navegación — Sesión 4)
# shared_preferences: ^2.3.0      (Favoritos locales — Sesión 6)
```

## Instalación

```bash
flutter pub get
flutter run
```
