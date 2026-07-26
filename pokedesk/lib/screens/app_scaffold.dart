import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/favorites_service.dart';
import '../services/theme_service.dart';

class AppScaffold extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AppScaffold({super.key, required this.navigationShell});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  @override
  void initState() {
    super.initState();
    FavoritesService().initializeFavoriteCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: widget.navigationShell.currentIndex,
        onTap: (index) => widget.navigationShell.goBranch(
          index,
          initialLocation: index == widget.navigationShell.currentIndex,
        ),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.catching_pokemon_outlined),
            activeIcon: Icon(Icons.catching_pokemon),
            label: 'Pokédex',
          ),
          BottomNavigationBarItem(
            icon: ValueListenableBuilder<int>(
              valueListenable: FavoritesService.favoriteCount,
              builder: (context, count, _) => count > 0
                  ? Badge(
                      label: Text(count.toString()),
                      child: const Icon(Icons.favorite_outline),
                    )
                  : const Icon(Icons.favorite_outline),
            ),
            activeIcon: ValueListenableBuilder<int>(
              valueListenable: FavoritesService.favoriteCount,
              builder: (context, count, _) => count > 0
                  ? Badge(
                      label: Text(count.toString()),
                      child: const Icon(Icons.favorite),
                    )
                  : const Icon(Icons.favorite),
            ),
            label: 'Favoritos',
          ),
        ],
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ThemeService.toggleTheme,
        tooltip: Theme.of(context).brightness == Brightness.dark
            ? 'Modo claro'
            : 'Modo oscuro',
        mini: true,
        child: Icon(Theme.of(context).brightness == Brightness.dark
            ? Icons.light_mode
            : Icons.dark_mode),
      ),
    );
  }
}
