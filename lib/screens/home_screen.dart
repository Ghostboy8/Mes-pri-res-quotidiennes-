import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../screens/schedule_screen.dart';
import '../services/notification_service.dart';
import '../services/tts_service.dart';
import '../widgets/navigation_bar.dart';
import 'prayer_screen.dart';
import 'rosary_screen.dart';
import 'favorites_screen.dart';
import 'about_screen.dart';
import '../services/data_service.dart';
import '../models/rosary.dart';
import '../models/prayer.dart';
import 'prayer_detail_screen.dart';
import 'rosary_detail_screen.dart';
import '../translations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late Future<Rosary> _rosaryFuture;
  late Future<List<Prayer>> _prayersFuture;
  List<Prayer>? _allPrayers;
  List<RosaryMystery>? _allMysteries;

  @override
  void initState() {
    super.initState();
    _rosaryFuture = DataService().loadRosary();
    _prayersFuture = DataService().loadPrayersByCategory("Prières du matin");
    DataService().loadAllPrayers().then((prayers) => setState(() => _allPrayers = prayers));
    DataService().loadAllMysteries().then((mysteries) => setState(() => _allMysteries = mysteries));
  }

  @override
  Widget build(BuildContext context) {
    final language = Provider.of<LanguageProvider>(context).language;
    final List<Widget> screens = [
      HomeContent(rosaryFuture: _rosaryFuture, prayersFuture: _prayersFuture),
      const PrayerScreen(),
      const RosaryScreen(),
      const FavoritesScreen(),
      const ScheduleScreen(),
      const AboutScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(translations[language]!['app_name']!),
        actions: [
          if (_currentIndex == 1 && _allPrayers != null)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () async {
                final selectedPrayer = await showSearch<Prayer?>(
                  context: context,
                  delegate: PrayerSearchDelegate(_allPrayers!),
                );
                if (selectedPrayer != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PrayerDetailScreen(
                        prayer: selectedPrayer,
                        ttsService: Provider.of<TtsService>(context, listen: false),
                        notificationService: Provider.of<NotificationService>(context, listen: false),
                      ),
                    ),
                  );
                }
              },
            ),
          if (_currentIndex == 2 && _allMysteries != null)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () async {
                final selectedMystery = await showSearch<RosaryMystery?>(
                  context: context,
                  delegate: RosarySearchDelegate(_allMysteries!),
                );
                if (selectedMystery != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RosaryDetailScreen(
                        mystery: selectedMystery,
                        ttsService: Provider.of<TtsService>(context, listen: false),
                        notificationService: Provider.of<NotificationService>(context, listen: false),
                      ),
                    ),
                  );
                }
              },
            ),
          PopupMenuButton<String>(
            onSelected: (lang) {
              Provider.of<LanguageProvider>(context, listen: false).setLanguage(lang);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'fr', child: Text('Français')),
              const PopupMenuItem(value: 'en', child: Text('English')),
            ],
          ),
        ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  final Future<Rosary> rosaryFuture;
  final Future<List<Prayer>> prayersFuture;

  const HomeContent({required this.rosaryFuture, required this.prayersFuture});

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  late Future<List<Prayer>> _morningPrayersFuture;

  @override
  void initState() {
    super.initState();
    _morningPrayersFuture = DataService().loadPrayersByCategory("Enseignement de l'Église");
  }

  Map<String, dynamic> getTodaysMysteryData(Rosary rosary, String language) {
    final weekday = DateTime.now().weekday;
    String categoryNameFr;
    String categoryNameEn;

    switch (weekday) {
      case DateTime.monday:
      case DateTime.saturday:
        categoryNameFr = 'Le Mystères Joyeux (le lundi et le samedi)';
        categoryNameEn = 'The Joyful Mysteries (Monday and Saturday)';
        break;
      case DateTime.tuesday:
      case DateTime.friday:
        categoryNameFr = 'Le Mystères Douloureux (le mardi et le vendredi)';
        categoryNameEn = 'The Sorrowful Mysteries (Tuesday and Friday)';
        break;
      case DateTime.wednesday:
      case DateTime.sunday:
        categoryNameFr = 'Le Mystères Glorieux (le mercredi et le dimanche)';
        categoryNameEn = 'The Glorious Mysteries (Wednesday and Sunday)';
        break;
      case DateTime.thursday:
        categoryNameFr = 'Le Mystères Lumineux (le jeudi)';
        categoryNameEn = 'The Luminous Mysteries (Thursday)';
        break;
      default:
        categoryNameFr = 'Mystère inconnu';
        categoryNameEn = 'Unknown Mystery';
    }

    final categoryName = language == 'fr' ? categoryNameFr : categoryNameEn;
    if (rosary.mysteries.containsKey(categoryNameFr)) {
      return {
        'category': categoryName,
        'mysteries': rosary.mysteries[categoryNameFr]!,
      };
    } else {
      return {
        'category': categoryName,
        'mysteries': [],
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = Provider.of<LanguageProvider>(context).language;
    final notificationService = Provider.of<NotificationService>(context, listen: false);
    final ttsService = Provider.of<TtsService>(context, listen: false);

    return FutureBuilder<Rosary>(
      future: widget.rosaryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text(translations[language]!['loading_error']!));
        }

        final rosary = snapshot.data!;
        final mysteryData = getTodaysMysteryData(rosary, language);
        final category = mysteryData['category'] as String;
        final mysteries = mysteryData['mysteries'] as List<RosaryMystery>;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${translations[language]!['mystery_of_the_day']!} $category',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      ...mysteries.map((m) => ListTile(
                        title: Text(m.getName(language)),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RosaryDetailScreen(
                                mystery: m,
                                ttsService: ttsService,
                                notificationService: notificationService,
                              ),
                            ),
                          );
                        },
                      )),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                translations[language]!['church_teaching']!,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Prayer>>(
                future: _morningPrayersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text(translations[language]!['loading_error']!));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text(translations[language]!['no_data']!));
                  }

                  final prayers = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: prayers.length,
                    itemBuilder: (context, index) {
                      final prayer = prayers[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
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
                                  ttsService: ttsService,
                                  notificationService: notificationService,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class PrayerSearchDelegate extends SearchDelegate<Prayer?> {
  final List<Prayer> allPrayers;

  PrayerSearchDelegate(this.allPrayers);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));
  }

  @override
  Widget buildResults(BuildContext context) {
    final language = Provider.of<LanguageProvider>(context).language;
    final results = allPrayers.where((prayer) => prayer.getTitle(language).toLowerCase().contains(query.toLowerCase())).toList();
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final prayer = results[index];
        return ListTile(
          title: Text(prayer.getTitle(language)),
          onTap: () => close(context, prayer),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final language = Provider.of<LanguageProvider>(context).language;
    final suggestions = allPrayers.where((prayer) => prayer.getTitle(language).toLowerCase().startsWith(query.toLowerCase())).toList();
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final prayer = suggestions[index];
        return ListTile(
          title: Text(prayer.getTitle(language)),
          onTap: () {
            query = prayer.getTitle(language);
            showResults(context);
          },
        );
      },
    );
  }
}

class RosarySearchDelegate extends SearchDelegate<RosaryMystery?> {
  final List<RosaryMystery> allMysteries;

  RosarySearchDelegate(this.allMysteries);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));
  }

  @override
  Widget buildResults(BuildContext context) {
    final language = Provider.of<LanguageProvider>(context).language;
    final results = allMysteries.where((mystery) => mystery.getName(language).toLowerCase().contains(query.toLowerCase())).toList();
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final mystery = results[index];
        return ListTile(
          title: Text(mystery.getName(language)),
          onTap: () => close(context, mystery),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final language = Provider.of<LanguageProvider>(context).language;
    final suggestions = allMysteries.where((mystery) => mystery.getName(language).toLowerCase().startsWith(query.toLowerCase())).toList();
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final mystery = suggestions[index];
        return ListTile(
          title: Text(mystery.getName(language)),
          onTap: () {
            query = mystery.getName(language);
            showResults(context);
          },
        );
      },
    );
  }
}