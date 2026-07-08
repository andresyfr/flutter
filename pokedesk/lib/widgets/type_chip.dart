import 'package:flutter/material.dart';

class TypeChip extends StatelessWidget {
  final String type;

  const TypeChip({super.key, required this.type});

  static const _colors = {
    'normal': Colors.grey,
    'fire': Colors.orange,
    'water': Colors.blue,
    'electric': Colors.yellow,
    'grass': Colors.green,
    'ice': Colors.lightBlue,
    'fighting': Colors.red,
    'poison': Colors.purple,
    'ground': Colors.brown,
    'flying': Colors.indigo,
    'psychic': Colors.pink,
    'bug': Colors.lightGreen,
    'rock': Colors.brown,
    'ghost': Colors.deepPurple,
    'dragon': Colors.deepOrange,
    'dark': Colors.black87,
    'steel': Colors.blueGrey,
    'fairy': Colors.pinkAccent,
  };

  static Color colorFor(String type) => _colors[type] ?? Colors.grey;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: colorFor(type),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type,
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
    );
  }
}
