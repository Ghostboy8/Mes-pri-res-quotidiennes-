import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../services/tts_service.dart';
import '../models/rosary.dart';
import 'package:share_plus/share_plus.dart';
import '../services/notification_service.dart';
import 'how_to_pray_rosary_screen.dart';
import 'rosary_detail_screen.dart';
import '../providers/language_provider.dart';
import 'package:provider/provider.dart';
import '../translations.dart';

class RosaryScreen extends StatefulWidget {
  const RosaryScreen({super.key});

  @override
  _RosaryScreenState createState() => _RosaryScreenState();
}

class _RosaryScreenState extends State<RosaryScreen> {
  late Future<Rosary> _rosaryFuture;

  @override
  void initState() {
    super.initState();
    _rosaryFuture = DataService().loadRosary();
  }

  @override
  Widget build(BuildContext context) {
    final language = Provider.of<LanguageProvider>(context).language;
    final notificationService = Provider.of<NotificationService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text(translations[language]!['rosary']!)),
      body: Column(
        children: [
          const SizedBox(height: 16.0),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey[900],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const HowToPrayRosaryScreen()));
            },
            child: Text(translations[language]!['how_to_pray']!, style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: FutureBuilder<Rosary>(
              future: _rosaryFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text(translations[language]!['loading_error']!));
                }
                final rosary = snapshot.data!;
                return ListView(
                  padding: const EdgeInsets.all(8.0),
                  children: rosary.mysteries.entries.map((entry) {
                    return ExpansionTile(
                      title: Text(
                        language == 'fr' ? entry.key.toUpperCase() : entry.key.replaceAll('Le ', 'The ').toUpperCase(),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      children: entry.value.map((mystery) => RosaryTile(mystery: mystery, notificationService: notificationService)).toList(),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class RosaryTile extends StatelessWidget {
  final RosaryMystery mystery;
  final NotificationService notificationService;

  const RosaryTile({required this.mystery, required this.notificationService, super.key});

  @override
  Widget build(BuildContext context) {
    final language = Provider.of<LanguageProvider>(context).language;
    final ttsService = Provider.of<TtsService>(context, listen: false);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        title: Text(mystery.getName(language)),
        subtitle: Text(mystery.getMeditation(language), maxLines: 2, overflow: TextOverflow.ellipsis),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RosaryDetailScreen(
                mystery: mystery,
                ttsService: ttsService,
                notificationService: notificationService,
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
                  icon: const Icon(Icons.share),
                  onPressed: () => Share.share(
                    '${mystery.getName(language)}\n${mystery.getMeditation(language)}\n\n${translations[language]!['app_name']!}',
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () => ttsService.speak('${mystery.getName(language)}\n${mystery.getMeditation(language)}'),
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
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}