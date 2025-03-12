import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../translations.dart';

class HowToPrayRosaryScreen extends StatelessWidget {
  const HowToPrayRosaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = Provider.of<LanguageProvider>(context).language;
    final Map<String, String> guideText = {
      'fr': '''
Voici comment prier le chapelet :

Après chaque *Gloire au Père*, vous pouvez réciter la prière de Fatima :
"Ô mon Jésus, pardonnez-nous nos péchés, préservez-nous du feu de l’enfer et conduisez au Ciel toutes les âmes, surtout celles qui ont le plus besoin de votre miséricorde. Amen."

Ensuite, annoncez le mystère à méditer et récitez les 10 *Je vous salue, Marie*.

À noter que chaque mystère comprend cinq points correspondant aux cinq dizaines du chapelet. De plus, chaque jour est associé à un mystère particulier. Veuillez vous référer à la section *Rosaire* de l’application pour plus de détails.
''',
      'en': '''
Here’s how to pray the Rosary:

After each *Glory Be*, you may recite the Fatima Prayer:
"O my Jesus, forgive us our sins, save us from the fires of hell, and lead all souls to Heaven, especially those in most need of Your mercy. Amen."

Then, announce the mystery to meditate on and recite the 10 *Hail Marys*.

Note that each mystery includes five points corresponding to the five decades of the Rosary. Additionally, each day is associated with a specific mystery. Please refer to the *Rosary* section of the app for more details.
''',
    };

    return Scaffold(
      appBar: AppBar(title: Text(translations[language]!['how_to_pray']!)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width * (9 / 16) + 50,
                child: Image.asset('assets/images/rosary_guide.png', fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              guideText[language]!,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}