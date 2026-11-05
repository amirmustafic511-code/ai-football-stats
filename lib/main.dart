
import 'package:flutter/material.dart';

void main() => runApp(const FootballApp());

class FootballApp extends StatelessWidget {
  const FootballApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Football Stats',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00D68F),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF101820),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedTab = 0;
  String selectedLeague = 'Sve lige';

  final leagues = [
    'Sve lige',
    'Premier League',
    'La Liga',
    'Serie A',
    'Bundesliga',
    'Ligue 1',
    'Liga prvaka',
    'Europa liga',
    'Premijer liga BiH',
    'Ostale evropske lige',
  ];

  final matches = [
    {
      'league': 'Premier League',
      'home': 'Arsenal',
      'away': 'Liverpool',
    },
    {
      'league': 'La Liga',
      'home': 'Barcelona',
      'away': 'Real Madrid',
    },
    {
      'league': 'Serie A',
      'home': 'Inter',
      'away': 'Juventus',
    },
    {
      'league': 'Bundesliga',
      'home': 'Bayern',
      'away': 'Dortmund',
    },
    {
      'league': 'Premijer liga BiH',
      'home': 'Sarajevo',
      'away': 'Željezničar',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final visibleMatches = matches.where((match) {
      return selectedLeague == 'Sve lige' ||
          match['league'] == selectedLeague;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI FOOTBALL STATS',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF17232D),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pretraga dolazi uskoro'),
                ),
              );
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: selectedTab == 0
          ? ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Dobrodošli u svijet fudbalske statistike',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Statistika, rezultati i AI analize '
                  'na jednom mjestu.',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Izaberi ligu',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: leagues.map((league) {
                    return ChoiceChip(
                      label: Text(league),
                      selected: selectedLeague == league,
                      onSelected: (_) {
                        setState(() {
                          selectedLeague = league;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Pregled utakmica',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'DEMO PODACI - nisu stvarne utakmice',
                  style: TextStyle(
                    color: Colors.amberAccent,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                if (visibleMatches.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'Utakmice za ovu ligu bit će '
                      'dostupne nakon povezivanja podataka.',
                    ),
                  ),
                ...visibleMatches.map((match) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    color: const Color(0xFF1D2B36),
                    child: ListTile(
                      leading: const Icon(
                        Icons.sports_soccer,
                        color: Color(0xFF00D68F),
                      ),
                      title: Text(
                        '${match['home']} - ${match['away']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(match['league']!),
                      trailing: const Icon(
                        Icons.chevron_right,
                      ),
                      onTap: () {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Detaljna statistika dolazi uskoro',
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          : selectedTab == 1
    ? const FootballAnalysisScreen()
    : Center(
        child: Text(
          selectedTab == 2
              ? 'Statistika dolazi uskoro'
              : 'Tvoj profil dolazi uskoro',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22),
        ),
      ),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedTab,
        onDestinationSelected: (index) {
          setState(() {
            selectedTab = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Početna',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome),
            label: 'AI analiza',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart),
            label: 'Statistika',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );

  }
}

    // AI FOOTBALL STATS - VLASTITI RATING SISTEM

class FootballRating {
  static double calculate({
    required double form,
    required double attack,
    required double defense,
    required double homeAway,
    required double consistency,
  }) {
    final rating =
        form * 0.30 +
        attack * 0.25 +
        defense * 0.25 +
        homeAway * 0.10 +
        consistency * 0.10;

    return rating.clamp(0.0, 100.0).toDouble();
  }

  static String describe(double rating) {
    if (rating >= 85) return 'Izvanredna forma';
    if (rating >= 70) return 'Vrlo dobra forma';
    if (rating >= 55) return 'Dobra forma';
    if (rating >= 40) return 'Prosječna forma';
    return 'Slaba forma';
  }
}
class FootballAnalysisScreen extends StatefulWidget {
  const FootballAnalysisScreen({super.key});

  @override
  State<FootballAnalysisScreen> createState() =>
      _FootballAnalysisScreenState();
}

class _FootballAnalysisScreenState
    extends State<FootballAnalysisScreen> {
  final Map<String, List<double>> teams = {
    'Barcelona': [85, 90, 75, 80],
    'Real Madrid': [88, 87, 82, 85],
    'Arsenal': [82, 84, 86, 80],
    'Liverpool': [84, 88, 78, 82],
    'Bayern Munich': [87, 91, 79, 84],
    'Inter': [83, 82, 89, 85],
  };

  String home = 'Barcelona';
  String away = 'Real Madrid';

  double score(String team, bool isHome) {
    final values = teams[team]!;
    return FootballRating.calculate(
      form: values[0],
      attack: values[1],
      defense: values[2],
      homeAway: isHome ? 65 : 50,
      consistency: values[3],
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeScore = score(home, true);
    final awayScore = score(away, false);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'AI analiza utakmice',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'DEMO: ocjene su testne, nisu stvarna statistika.',
          style: TextStyle(color: Colors.amber),
        ),
        const SizedBox(height: 24),
        const Text('Domaća ekipa'),
        DropdownButton<String>(
          isExpanded: true,
          value: home,
          items: teams.keys.map((team) {
            return DropdownMenuItem(
              value: team,
              child: Text(team),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => home = value);
            }
          },
        ),
        const SizedBox(height: 20),
        const Text('Gostujuća ekipa'),
        DropdownButton<String>(
          isExpanded: true,
          value: away,
          items: teams.keys.map((team) {
            return DropdownMenuItem(
              value: team,
              child: Text(team),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => away = value);
            }
          },
        ),
        const SizedBox(height: 30),
        const Text(
          'Poređenje ekipa',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  '$home: ${homeScore.toStringAsFixed(1)}/100',
                  style: const TextStyle(fontSize: 19),
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: homeScore / 100,
                  minHeight: 12,
                ),
                const SizedBox(height: 25),
                Text(
                  '$away: ${awayScore.toStringAsFixed(1)}/100',
                  style: const TextStyle(fontSize: 19),
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: awayScore / 100,
                  minHeight: 12,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 25),
        const Text(
          'Zaključak naše analize',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          home == away
              ? 'Izaberi dvije različite ekipe.'
              : (homeScore - awayScore).abs() < 3
                  ? 'Ekipe imaju vrlo slične ukupne ocjene.'
                  : homeScore > awayScore
                      ? '$home ima bolju ukupnu ocjenu '
                        'prema našem modelu.'
                      : '$away ima bolju ukupnu ocjenu '
                        'prema našem modelu.',
          style: const TextStyle(fontSize: 17),
        ),
        const SizedBox(height: 20),
        const Text(
          'Ovo nije prognoza rezultata utakmice.',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
