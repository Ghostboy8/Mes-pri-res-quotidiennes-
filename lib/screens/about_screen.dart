import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/language_provider.dart';
import '../translations.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  void _launchEmail() async {
    final Uri emailLaunchUri = Uri(scheme: 'mailto', path: 'vauguste91@gmail.com');
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    }
  }

  void _launchPhone() async {
    final Uri phoneLaunchUri = Uri(scheme: 'tel', path: '+2250141667165');
    if (await canLaunchUrl(phoneLaunchUri)) {
      await launchUrl(phoneLaunchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = Provider.of<LanguageProvider>(context).language;
    final Map<String, String> aboutText = {
      'fr': '''
Une application dédiée à la prière quotidienne et à la méditation du Rosaire.

Cette application s'inspire du livret "Mes Prières Quotidiennes", un ouvrage de l'Église catholique conçu pour accompagner les croyants dans leur vie spirituelle quotidienne. Le contenu de l'application est tiré du Missel Romain et du Catéchisme de l’Église Catholique, enrichi de prières et de méditations. Elle a été pensée pour vous permettre de prier et méditer où que vous soyez, à tout moment de la journée.

📚 Informations du livret :
• Titre : MES PRIÈRES QUOTIDIENNES (C) Filles de St-Paul
• ISBN : 978-2-918039-95-2
• Choix des prières : Martine Kablan
• Éditions : Paulines, 23 B.P. 3876 Abidjan, Côte d'Ivoire
• Dépôt légal : n° 5048 du 28.04.2000
• Réimpression : 9e en 2018
• Impression : Imprimerie Ivoire HS - Abidjan

Les Filles de St-Paul sont une congrégation internationale apostolique dédiée à la promotion de l'évangélisation et de la communication. Cette application fait partie de leur mission de diffuser la parole de Dieu dans le monde moderne.

👨‍💻 À propos du Développeur
Je suis Vanie Bi Jean Auguste Bile, un étudiant passionné par l'informatique. Après avoir eu le bac, il m'a été difficile de rejoindre une université. Cependant, ma passion pour l'informatique ne m'a jamais quitté. J'ai prié Dieu pour qu'Il m'ouvre une porte et me permette d'étudier l'informatique, une discipline qui me fascine. En retour, je me suis engagé à mettre mes compétences en technologie au service du Seigneur.

Pendant un certain temps, j'ai manqué de connaissances pour prier et pratiquer le Rosaire en tant que catholique. C'est alors que ma grand-mère, une personne profondément investie dans la foi chrétienne, m'a offert le livret "MES PRIÈRES QUOTIDIENNES". Ce livret est devenu une ressource précieuse dans ma vie spirituelle. Après plusieurs années d'utilisation, j'ai décidé de numériser ce livret et de créer une application mobile afin de pouvoir prier à tout moment et de partager cette ressource avec d'autres personnes, tout comme moi, qui cherchent à apprendre à prier et à renforcer leur foi.

📧 Contact :
Email : vauguste91@gmail.com
Téléphone : +225 0141667165
''',
      'en': '''
An application dedicated to daily prayer and Rosary meditation.

This application is inspired by the booklet "My Daily Prayers," a Catholic Church publication designed to accompany believers in their daily spiritual lives. The app's content is drawn from the Roman Missal and the Catechism of the Catholic Church, enriched with prayers and meditations. It was created to allow you to pray and meditate wherever you are, at any time of the day.

📚 Booklet Information:
• Title: MY DAILY PRAYERS (C) Daughters of St. Paul
• ISBN: 978-2-918039-95-2
• Prayer Selection: Martine Kablan
• Publisher: Paulines, 23 B.P. 3876 Abidjan, Côte d'Ivoire
• Legal Deposit: No. 5048 of 28.04.2000
• Reprint: 9th in 2018
• Printer: Imprimerie Ivoire HS - Abidjan

The Daughters of St. Paul are an international apostolic congregation dedicated to promoting evangelization and communication. This application is part of their mission to spread the word of God in the modern world.

👨‍💻 About the Developer
I am Vanie Bi Jean Auguste Bile, a student passionate about computer science. After obtaining my high school diploma, joining a university proved challenging. However, my passion for computer science never wavered. I prayed to God to open a door for me to study this field that fascinates me. In return, I committed to using my technology skills in service to the Lord.

For a time, I lacked the knowledge to pray and practice the Rosary as a Catholic. Then my grandmother, a deeply faithful Christian, gave me the booklet "MY DAILY PRAYERS." It became a precious resource in my spiritual life. After years of use, I decided to digitize this booklet and create a mobile app to pray anytime and share this resource with others like me who seek to learn to pray and strengthen their faith.

📧 Contact:
Email: vauguste91@gmail.com
Phone: +225 0141667165
''',
    };

    return Scaffold(
      appBar: AppBar(title: Text(translations[language]!['about']!)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              translations[language]!['app_name']!,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue[900]),
            ),
            const SizedBox(height: 10),
            Text(
              aboutText[language]!,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 16),
            Center(
              child: Image.asset('assets/images/pauline_logo.png', height: 100, width: 100),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _launchEmail,
              child: Text(
                'Email: vauguste91@gmail.com',
                style: const TextStyle(color: Colors.blue, fontSize: 18, decoration: TextDecoration.underline),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _launchPhone,
              child: Text(
                'Phone: +225 0141667165',
                style: const TextStyle(color: Colors.blue, fontSize: 18, decoration: TextDecoration.underline),
              ),
            ),
          ],
        ),
      ),
    );
  }
}