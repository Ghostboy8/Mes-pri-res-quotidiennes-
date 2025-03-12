import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorite_provider.dart';
import '../providers/language_provider.dart';
import '../models/prayer.dart';
import 'package:share_plus/share_plus.dart';
import '../services/notification_service.dart';
import '../services/tts_service.dart';
import 'prayer_detail_screen.dart';
import '../translations.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = Provider.of<LanguageProvider>(context).language;
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    if (favoriteProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final favorites = favoriteProvider.favorites;
    return Scaffold(
      appBar: AppBar(title: Text(translations[language]!['favorites']!)),
      body: favorites.isEmpty
          ? Center(child: Text(translations[language]!['no_data']!))
          : ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final prayer = favorites[index];
          return Card(
            child: ListTile(
              title: Text(prayer.getTitle(language)),
              subtitle: Text(
                prayer.getText(language),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PrayerDetailScreen(
                      prayer: prayer,
                      ttsService: Provider.of<TtsService>(context, listen: false),
                      notificationService: Provider.of<NotificationService>(context, listen: false),
                    ),
                  ),
                );
              },
              trailing: Consumer<TtsService>(
                builder: (context, ttsService, child) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.favorite),
                        onPressed: () => favoriteProvider.removeFavorite(prayer),
                      ),
                      IconButton(
                        icon: const Icon(Icons.share),
                        onPressed: () => Share.share(
                          '${prayer.getTitle(language)}\n${prayer.getText(language)}\n\n${translations[language]!['app_name']!}',
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.play_arrow),
                        onPressed: () => ttsService.speak('${prayer.getTitle(language)}\n${prayer.getText(language)}'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.stop),
                        onPressed: ttsService.isSpeaking ? () => ttsService.stop() : null,
                        color: ttsService.isSpeaking ? Colors.red : Colors.grey,
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}