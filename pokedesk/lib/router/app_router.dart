import 'package:go_router/go_router.dart';
import '../models/pokemon.dart';
import '../screens/app_scaffold.dart';
import '../screens/splash_screen.dart';
import '../screens/home_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/detail_screen.dart';
import '../screens/compare_screen.dart';
import '../screens/profile_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // ── Splash ──────────────────────────────────────────────────────────────
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),

    // ── Shell: tabs con NavigationBar ────────────────────────────────────────
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppScaffold(navigationShell: navigationShell),
      branches: [
        // Branch 0 — Pokédex
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) {
                final pokemons = (state.extra as List<Pokemon>?) ?? [];
                return HomeScreen(initialPokemons: pokemons);
              },
            ),
          ],
        ),
        // Branch 1 — Favoritos
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/favorites',
              builder: (context, state) => const FavoritesScreen(),
            ),
          ],
        ),
      ],
    ),

    // ── Detalle (fuera del shell para ocupar pantalla completa) ──────────────
    GoRoute(
      path: '/detail',
      builder: (context, state) {
        final pokemon = state.extra as Pokemon;
        return DetailScreen(pokemon: pokemon);
      },
    ),
    GoRoute(
      path: '/compare',
      builder: (context, state) {
        final pokemons = (state.extra as List<Pokemon>?) ?? [];
        return CompareScreen(pokemons: pokemons);
      },
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state){
        return const ProfileScreen(); 
      }
    )
  ],
);
