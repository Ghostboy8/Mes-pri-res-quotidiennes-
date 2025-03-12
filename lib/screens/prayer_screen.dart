import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/data_service.dart';
import '../services/tts_service.dart';
import '../services/notification_service.dart';
import '../models/prayer.dart';
import '../providers/favorite_provider.dart';
import '../providers/language_provider.dart';
import 'prayer_detail_screen.dart';
import '../translations.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  _PrayerScreenState createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  late Future<List<PrayerCategory>> _prayersFuture;

  @override
  void initState() {
    super.initState();
    _prayersFuture = DataService().loadPrayers();
  }

  @override
  Widget build(BuildContext context) {
    final language = Provider.of<LanguageProvider>(context).language;
    return Scaffold(
      appBar: AppBar(title: Text(translations[language]!['prayers']!)),
      body: FutureBuilder<List<PrayerCategory>>(
        future: _prayersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text(translations[language]!['loading_error']!));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(translations[language]!['no_data']!));
          }
          final categories = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return ExpansionTile(
                title: Text(category.getName(language), style: Theme.of(context).textTheme.headlineMedium),
                children: category.prayers
                    .map(
                      (prayer) => PrayerTile(
                    prayer: prayer,
                    ttsService: Provider.of<TtsService>(context, listen: false),
                    notificationService: Provider.of<NotificationService>(context, listen: false),
                  ),
                )
                    .toList(),
              );
            },
          );
        },
      ),
    );
  }
}

class PrayerTile extends StatelessWidget {
  final Prayer prayer;
  final TtsService ttsService;
  final NotificationService notificationService;

  const PrayerTile({
    required this.prayer,
    required this.ttsService,
    required this.notificationService,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final language = Provider.of<LanguageProvider>(context).language;
    final favoriteProvider = Provider.of<FavoriteProvider>(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        children: [
          ListTile(
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
                    ttsService: ttsService,
                    notificationService: notificationService,
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Consumer<TtsService>(
              builder: (context, ttsService, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(
                        favoriteProvider.isFavorite(prayer) ? Icons.favorite : Icons.favorite_border,
                      ),
                      onPressed: () {
                        if (favoriteProvider.isFavorite(prayer)) {
                          favoriteProvider.removeFavorite(prayer);
                        } else {
                          favoriteProvider.addFavorite(prayer);
                        }
                      },
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
                    IconButton(
                      icon: const Icon(Icons.schedule),
                      onPressed: () async {
                        final TimeOfDay? time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                        if (time != null) {
                          final now = DateTime.now();
                          final scheduledTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
                          await notificationService.scheduleNotification(
                            title: prayer.getTitle(language),
                            body: prayer.getText(language),
                            scheduledTime: scheduledTime,
                            type: 'prayer',
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(translations[language]!['reminder_set']!)),
                          );
                        }
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}