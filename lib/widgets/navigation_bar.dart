import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../translations.dart';

class CustomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavigationBar({required this.currentIndex, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final language = Provider.of<LanguageProvider>(context).language;
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: Colors.blueGrey[900],
      unselectedItemColor: Colors.grey,
      items: [
        BottomNavigationBarItem(icon: const Icon(Icons.home), label: translations[language]!['home']!),
        BottomNavigationBarItem(icon: const Icon(Icons.book), label: translations[language]!['prayers']!),
        BottomNavigationBarItem(icon: const Icon(Icons.church), label: translations[language]!['rosary']!),
        BottomNavigationBarItem(icon: const Icon(Icons.favorite), label: translations[language]!['favorites']!),
        BottomNavigationBarItem(icon: const Icon(Icons.schedule), label: translations[language]!['schedule']!),
        BottomNavigationBarItem(icon: const Icon(Icons.info), label: translations[language]!['about']!),
      ],
    );
  }
}