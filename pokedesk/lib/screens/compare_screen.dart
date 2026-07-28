import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../widgets/type_chip.dart';

class CompareScreen extends StatefulWidget {
  final List<Pokemon> pokemons;

  const CompareScreen({super.key, required this.pokemons});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  Pokemon? _left;
  Pokemon? _right;

  static const _statLabels = {
    'hp': 'HP',
    'attack': 'Ataque',
    'defense': 'Defensa',
    'special-attack': 'Sp. Ataque',
    'special-defense': 'Sp. Defensa',
    'speed': 'Velocidad',
  };

  @override
  void initState() {
    super.initState();
    if (widget.pokemons.isNotEmpty) _left = widget.pokemons.first;
    if (widget.pokemons.length > 1) _right = widget.pokemons[1];
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comparar Pokémon'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: widget.pokemons.length < 2
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Carga al menos 2 Pokémon en la Pokédex para comparar.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(child: _buildSelector(true)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildSelector(false)),
                  ],
                ),
                const SizedBox(height: 24),
                if (_left != null && _right != null) _buildStatsTable(),
              ],
            ),
    );
  }

  Widget _buildSelector(bool isLeft) {
    final selected = isLeft ? _left : _right;
    return Column(
      children: [
        DropdownButton<Pokemon>(
          isExpanded: true,
          value: selected,
          items: widget.pokemons
              .map((p) => DropdownMenuItem(
                    value: p,
                    child: Text(_capitalize(p.name)),
                  ))
              .toList(),
          onChanged: (p) => setState(() {
            if (isLeft) {
              _left = p;
            } else {
              _right = p;
            }
          }),
        ),
        const SizedBox(height: 8),
        if (selected != null)
          CachedNetworkImage(
            imageUrl: selected.imageUrl,
            height: 110,
            fit: BoxFit.contain,
            errorWidget: (c, u, e) =>
                const Icon(Icons.catching_pokemon, size: 90),
          ),
        const SizedBox(height: 4),
        if (selected != null)
          Text(
            '#${selected.id.toString().padLeft(3, '0')}',
            style: const TextStyle(color: Colors.grey),
          ),
        if (selected != null)
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 4,
            children:
                selected.types.map((t) => TypeChip(type: t)).toList(),
          ),
      ],
    );
  }

  Widget _buildStatsTable() {
    return Column(
      children: _statLabels.entries.map((entry) {
        final leftVal = _left!.stats[entry.key] ?? 0;
        final rightVal = _right!.stats[entry.key] ?? 0;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              SizedBox(
                width: 36,
                child: Text(
                  '$leftVal',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: leftVal > rightVal ? Colors.green : null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 36,
                child: Text(
                  '$rightVal',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: rightVal > leftVal ? Colors.green : null,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
