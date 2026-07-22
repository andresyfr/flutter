import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/pokemon_service.dart';
import '../models/pokemon.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();

    _init();
  }

  Future<void> _init() async {
    await Future.wait([
      SharedPreferences.getInstance(),
      PokemonService().getPokemons(20, 0),
    ]).then((results) {
      final pokemons = results[1] as List<Pokemon>;
      if (mounted) context.go('/home', extra: pokemons);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final pokeballSize =
                (constraints.maxWidth * 0.85).clamp(0.0, constraints.maxHeight * 0.55);
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RotationTransition(
                    turns: _controller,
                    child: SizedBox(
                      width: pokeballSize,
                      height: pokeballSize,
                      child: SvgPicture.asset(
                        'assets/icons/pokeball-pokemon-svgrepo-com.svg',
                        width: pokeballSize,
                        height: pokeballSize,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'PokéFlutter',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const CircularProgressIndicator(color: Colors.white),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
