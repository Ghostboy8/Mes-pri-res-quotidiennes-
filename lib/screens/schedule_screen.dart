import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/notification_service.dart';
import '../services/data_service.dart';
import '../models/prayer.dart';
import '../models/rosary.dart';
import '../providers/language_provider.dart';
import '../translations.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late Future<List<PrayerCategory>> _prayerCategoriesFuture;
  late Future<Rosary> _rosaryFuture;
  String? _selectedType = 'prayer';
  PrayerCategory? _selectedPrayerCategory;
  String? _selectedRosaryCategory;

  @override
  void initState() {
    super.initState();
    _prayerCategoriesFuture = DataService().loadPrayers();
    _rosaryFuture = DataService().loadRosary();
  }

  @override
  Widget build(BuildContext context) {
    final language = Provider.of<LanguageProvider>(context).language;
    return Consumer<NotificationService>(
      builder: (context, notificationService, child) {
        final scheduledReminders = notificationService.getScheduledReminders();
        return Scaffold(
          appBar: AppBar(title: Text(translations[language]!['schedule']!)),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: Row(
                                children: [
                                  Radio<String>(
                                    value: 'prayer',
                                    groupValue: _selectedType,
                                    onChanged: (value) => setState(() {
                                      _selectedType = value;
                                      _selectedRosaryCategory = null;
                                    }),
                                    activeColor: Colors.blueGrey[900],
                                  ),
                                  Expanded(child: Text(translations[language]!['prayers']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: Row(
                                children: [
                                  Radio<String>(
                                    value: 'rosary',
                                    groupValue: _selectedType,
                                    onChanged: (value) => setState(() {
                                      _selectedType = value;
                                      _selectedPrayerCategory = null;
                                    }),
                                    activeColor: Colors.blueGrey[900],
                                  ),
                                  Expanded(child: Text(translations[language]!['rosary']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (_selectedType == 'prayer')
                          FutureBuilder<List<PrayerCategory>>(
                            future: _prayerCategoriesFuture,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) return const CircularProgressIndicator();
                              final categories = snapshot.data!;
                              return DropdownButton<PrayerCategory>(
                                hint: Text(translations[language]!['prayer_category']!),
                                value: _selectedPrayerCategory,
                                onChanged: (value) => setState(() => _selectedPrayerCategory = value),
                                isExpanded: true,
                                items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat.getName(language)))).toList(),
                              );
                            },
                          ),
                        if (_selectedType == 'rosary')
                          FutureBuilder<Rosary>(
                            future: _rosaryFuture,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) return const CircularProgressIndicator();
                              final rosary = snapshot.data!;
                              final mysteryCategories = rosary.mysteries.keys.toList();
                              return DropdownButton<String>(
                                hint: Text(translations[language]!['rosary_category']!),
                                value: _selectedRosaryCategory,
                                onChanged: (value) => setState(() => _selectedRosaryCategory = value),
                                isExpanded: true,
                                items: mysteryCategories
                                    .map((cat) => DropdownMenuItem(
                                  value: cat,
                                  child: Text(language == 'fr' ? cat : cat.replaceAll('Le ', 'The ')),
                                ))
                                    .toList(),
                              );
                            },
                          ),
                        const SizedBox(height: 16),
                        Center(
                          child: ElevatedButton(
                            onPressed: () => _scheduleReminder(notificationService, context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueGrey[900],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            child: Text(translations[language]!['schedule_reminder']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: scheduledReminders.isEmpty
                    ? Center(child: Text(translations[language]!['no_reminders']!, style: const TextStyle(fontSize: 16, color: Colors.grey)))
                    : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: scheduledReminders.length,
                  itemBuilder: (context, index) {
                    final reminder = scheduledReminders[index];
                    final timeStr = '${reminder.scheduledTime.hour}:${reminder.scheduledTime.minute.toString().padLeft(2, '0')}';
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: Icon(reminder.type == 'prayer' ? Icons.book : Icons.church, color: Colors.blueGrey[900]),
                        title: Text(reminder.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Text('${translations[language]!['scheduled_for']!} $timeStr', style: const TextStyle(color: Colors.black54)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await notificationService.cancelNotification(reminder.id);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _scheduleReminder(NotificationService notificationService, BuildContext context) async {
    final language = Provider.of<LanguageProvider>(context, listen: false).language;
    if (_selectedType == 'prayer' && _selectedPrayerCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(translations[language]!['select_category']!)));
      return;
    }
    if (_selectedType == 'rosary' && _selectedRosaryCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(translations[language]!['select_category']!)));
      return;
    }

    final TimeOfDay? time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time != null) {
      final now = DateTime.now();
      final scheduledTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
      String title;
      String body;
      String type;

      if (_selectedType == 'prayer') {
        title = _selectedPrayerCategory!.getName(language);
        body = _selectedPrayerCategory!.prayers.isNotEmpty ? _selectedPrayerCategory!.prayers[0].getText(language) : translations[language]!['prayer_category']!;
        type = 'prayer';
      } else {
        title = language == 'fr' ? _selectedRosaryCategory! : _selectedRosaryCategory!.replaceAll('Le ', 'The ');
        body = '${translations[language]!['rosary_category']!} $title';
        type = 'rosary';
      }

      await notificationService.scheduleNotification(
        title: title,
        body: body,
        scheduledTime: scheduledTime,
        type: type,
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(translations[language]!['reminder_set']!)));
    }
  }
}