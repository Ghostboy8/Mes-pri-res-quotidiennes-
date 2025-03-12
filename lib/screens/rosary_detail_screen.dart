import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../services/tts_service.dart';
import '../services/notification_service.dart';
import '../models/rosary.dart';
import '../providers/language_provider.dart';
import 'package:provider/provider.dart';
import '../translations.dart';

class RosaryDetailScreen extends StatelessWidget {
  final RosaryMystery mystery;
  final TtsService ttsService;
  final NotificationService notificationService;

  const RosaryDetailScreen({
    required this.mystery,
    required this.ttsService,
    required this.notificationService,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final language = Provider.of<LanguageProvider>(context).language;

    return Scaffold(
      appBar: AppBar(
        title: Text(mystery.getName(language)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => Share.share(
              '${mystery.getName(language)}\n${mystery.getMeditation(language)}\n\n${translations[language]!['app_name']!}',
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              mystery.getName(language),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 32.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  mystery.getMeditation(language),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 18.0, height: 1.5),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Consumer<TtsService>(
              builder: (context, ttsService, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.play_arrow),
                      onPressed: () => ttsService.speak('${mystery.getName(language)}\n${mystery.getMeditation(language)}'),
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
                            title: mystery.getName(language),
                            body: mystery.getMeditation(language),
                            scheduledTime: scheduledTime,
                            type: 'rosary',
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(translations[language]!['reminder_set']!)),
                          );
                        }
                      },
                      tooltip: translations[language]!['schedule'],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}