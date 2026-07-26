# PokéFlutter

Aplicación Pokédex construida con Flutter que consume la [PokéAPI](https://pokeapi.co/).

## Características

- Splash screen con pokebola animada (rotación) mientras carga
- Lista de Pokémon con búsqueda en vivo por nombre o número
- Scroll infinito (20 Pokémon por página)
- Detalle de Pokémon con imagen expandida y colores por tipo
- Favoritos persistentes con `shared_preferences`
- Navegación con `go_router` y `NavigationBar` inferior

## Árbol de widgets principal

```
PokeFlutterApp (StatelessWidget)
└── MaterialApp.router (GoRouter)
    ├── SplashScreen          → /
    ├── AppScaffold           → StatefulShellRoute
    │   ├── NavigationBar
    │   │   ├── Tab: Pokédex  → /home
    │   │   └── Tab: Favoritos → /favorites
    │   └── body: navigationShell
    │       ├── HomeScreen
    │       │   ├── AppBar → Text("PokéFlutter")
    │       │   └── Body → Column
    │       │       ├── TextField (búsqueda en vivo)
    │       │       └── ListView → PokemonCard(...)
    │       └── FavoritesScreen
    │           ├── AppBar → Text("Favoritos")
    │           └── ListView → PokemonCard(...)
    └── DetailScreen          → /detail  (fuera del shell)
        ├── SliverAppBar (color por tipo + botón favorito)
        └── Imagen + tipos del Pokémon
```

## Rutas (GoRouter)

| Ruta | Screen | Descripción |
|------|--------|-------------|
| `/` | `SplashScreen` | Ruta inicial, redirige a `/home` tras 3s |
| `/home` | `HomeScreen` | Lista principal con búsqueda |
| `/favorites` | `FavoritesScreen` | Pokémon guardados localmente |
| `/detail` | `DetailScreen` | Detalle, recibe `Pokemon` por `extra` |

La ruta `/detail` usa `context.push('/detail', extra: pokemon)` para pasar el objeto directamente sin serializar en la URL.

## Estructura del proyecto

```
pokedesk/
├── android/
├── ios/
├── web/
├── lib/
│   ├── models/
│   │   └── pokemon.dart              # fromJson, toJson, fromStorage
│   ├── services/
│   │   ├── pokemon_service.dart      # Consumo de PokéAPI (http)
│   │   └── favorites_service.dart    # Persistencia con shared_preferences
│   ├── router/
│   │   └── app_router.dart           # GoRouter + StatefulShellRoute
│   ├── screens/
│   │   ├── splash_screen.dart        # Pokebola animada
│   │   ├── app_scaffold.dart         # Shell con NavigationBar
│   │   ├── home_screen.dart          # Lista + búsqueda en vivo
│   │   ├── detail_screen.dart        # Detalle del Pokémon
│   │   └── favorites_screen.dart     # Lista de favoritos
│   ├── widgets/
│   │   ├── pokemon_card.dart         # Tarjeta horizontal con onTap
│   │   └── type_chip.dart            # Chip de tipo reutilizable
│   └── main.dart                     # PokeFlutterApp (StatelessWidget)
├── test/
│   └── widget_test.dart
├── pubspec.yaml
└── README.md
```

## Dependencias

```yaml
dependencies:
  http: ^1.1.0                    # Peticiones HTTP a PokéAPI
  cached_network_image: ^3.3.0    # Caché de imágenes
  go_router: ^14.0.0              # Navegación declarativa
  shared_preferences: ^2.3.0      # Favoritos locales

```

## Instalación

```bash
flutter pub get
flutter run
```