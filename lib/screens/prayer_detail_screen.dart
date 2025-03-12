import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/notification_service.dart';
import '../services/tts_service.dart';
import '../models/prayer.dart';
import '../providers/language_provider.dart';
import '../translations.dart';

class PrayerDetailScreen extends StatelessWidget {
  final Prayer prayer;
  final TtsService ttsService;
  final NotificationService notificationService;

  const PrayerDetailScreen({
    required this.prayer,
    required this.ttsService,
    required this.notificationService,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final language = Provider.of<LanguageProvider>(context).language;

    return Scaffold(
      appBar: AppBar(
        title: Text(prayer.getTitle(language)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => Share.share(
              '${prayer.getTitle(language)}\n${prayer.getText(language)}\n\n${translations[language]!['app_name']!}',
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              prayer.getTitle(language),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  prayer.getText(language),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () => ttsService.speak('${prayer.getTitle(language)}\n${prayer.getText(language)}'),
                  tooltip: translations[language]!['play'],
                ),
                IconButton(
                  icon: const Icon(Icons.stop),
                  onPressed: ttsService.isSpeaking ? () => ttsService.stop() : null,
                  tooltip: translations[language]!['stop'],
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
                  tooltip: translations[language]!['schedule'],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}