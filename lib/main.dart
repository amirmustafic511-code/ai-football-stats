Dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

const api = 'https://football-intelligence-api.football-intelligence-ai.workers.dev';
const bg = Color(0xFF08131F);
const panel = Color(0xFF172839);
const green = Color(0xFF38E49B);
const soft = Color(0xFFB8C7D2);

const leagues = {
  'PL': 'Premier League',
  'PD': 'La Liga',
  'SA': 'Serie A',
  'BL1': 'Bundesliga',
  'FL1': 'Ligue 1',
  'CL': 'Liga prvaka',
  'PPL': 'Portugal',
  'ELC': 'Championship',
};

void main() => runApp(const FootballApp());

class FootballApp extends StatelessWidget {
  const FootballApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Football Intelligence AI',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: green,
          brightness: Brightness.dark,
        ),
      ),
      home: const Home(),
    );
  }
}

Future<Map<String, dynamic>> fetch(String path) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse('$api$path'));
    final response = await request.close();
    final text = await utf8.decoder.bind(response).join();
    final json = jsonDecode(text);

    if (response.statusCode != 200 || json is! Map) {
      throw Exception('Server nije dostupan');
    }

    final data = Map<String, dynamic>.from(json);
    if (data['error'] != null) throw Exception(data['error']);
    return data;
  } finally {
    client.close(force: true);
  }
}

Map<String, dynamic> obj(dynamic value) {
  return value is Map ? Map<String, dynamic>.from(value) : {};
}

List<Map<String, dynamic>> records(dynamic value) {
  if (value is! List) return [];
  return value
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
}

String pct(dynamic value) =>
    value is num ? '${value.round()}%' : '—';

String dateText(dynamic value) {
  final d = DateTime.tryParse('$value')?.toLocal();
  if (d == null) return 'Termin nije poznat';
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}.${two(d.month)}.${d.year}. '
      '${two(d.hour)}:${two(d.minute)}';
}

Widget section(String title, Widget child) {
  return Card(
    color: panel,
    margin: const EdgeInsets.only(bottom: 14),
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: green,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    ),
  );
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String league = 'PL';
  int tab = 0;
  late Future<Map<String, dynamic>> data;
  late Future<Map<String, dynamic>> news;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    load();
    timer = Timer.periodic(
      const Duration(hours: 1),
      (_) {
        if (mounted) setState(load);
      },
    );
  }

  void load() {
    data = fetch('/api/league?code=$league');
    news = fetch('/api/news');
  }

  Future<void> refresh() async {
    setState(load);
    try {
      await (tab == 3 ? news : data);
    } catch (_) {}
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Widget probability(String label, dynamic value) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: soft)),
          const SizedBox(height: 4),
          Text(
            pct(value),
            style: const TextStyle(
                color: green,
                fontSize: 21,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget matchCard(Map<String, dynamic> m) {
    final p = obj(m['prediction']);
    final r = obj(p['resultPercent']);

    return Card(
      color: panel,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MatchDetails(
              match: m,
              league: leagues[league] ?? league,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(dateText(m['date']),
                  style: const TextStyle(color: soft)),
              const SizedBox(height: 12),
              Text(
                '${m['home']}  –  ${m['away']}',
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  probability('1', r['home']),
                  probability('X', r['draw']),
                  probability('2', r['away']),
                  const Icon(Icons.chevron_right, color: green),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget matchesPage() {
    return Column(
      children: [
        SizedBox(
          height: 54,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: leagues.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.all(4),
                child: ChoiceChip(
                  label: Text(entry.value),
                  selected: league == entry.key,
                  onSelected: (_) {
                    setState(() {
                      league = entry.key;
                      data = fetch('/api/league?code=$league');
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: FutureBuilder<Map<String, dynamic>>(
            future: data,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Greška: ${snapshot.error}'),
                );
              }
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final result = snapshot.data!;
              final matches = records(result['matches']);

              return RefreshIndicator(
                onRefresh: refresh,
                child: ListView(
                  padding: const EdgeInsets.all(14),
                  children: [
                    section(
                      leagues[league] ?? league,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${matches.length} narednih utakmica',
                            style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${result['finishedMatches'] ?? 0} '
                            'odigranih utakmica za analizu',
                            style: const TextStyle(color: soft),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ažurirano: ${dateText(result['updatedAt'])}',
                            style: const TextStyle(color: soft),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      tab == 2
                          ? 'Statistika utakmica'
                          : tab == 1
                              ? 'AI analize'
                              : 'Naredne utakmice',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (matches.isEmpty)
                      section(
                        'Nema utakmica',
                        Text('${result['note'] ?? 'Nema rasporeda.'}'),
                      ),
                    ...matches.map(matchCard),
                    const SizedBox(height: 12),
                    const Text(
                      'Podaci: Football-Data.org. '
                      'Prognoze nisu garantovani rezultati.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: soft, fontSize: 12),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget newsPage() {
    return FutureBuilder<Map<String, dynamic>>(
      future: news,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final result = snapshot.data!;
        final articles = records(result['articles']);

        return RefreshIndicator(
          onRefresh: refresh,
          child: ListView(
            padding: const EdgeInsets.all(15),
            children: [
              const Text(
                'Fudbalske vijesti',
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              if (articles.isEmpty)
                section(
                  'Vijesti',
                  Text(
                    '${result['message'] ?? 'Izvor vijesti još nije povezan.'}',
                  ),
                ),
              ...articles.map(
                (a) => section(
                  '${a['title'] ?? 'Vijest'}',
                  Text('${a['description'] ?? ''}'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FOOTBALL INTELLIGENCE AI',
          style: TextStyle(fontSize: 17),
        ),
        actions: [
          IconButton(
            onPressed: () => setState(load),
            icon: const Icon(Icons.refresh, color: green),
          ),
        ],
      ),
      body: tab == 3 ? newsPage() : matchesPage(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (n) => setState(() => tab = n),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Početna',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome),
            label: 'Analize',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart),
            label: 'Statistika',
          ),
          NavigationDestination(
            icon: Icon(Icons.article_outlined),
            label: 'Vijesti',
          ),
        ],
      ),
    );
  }
}

class MatchDetails extends StatelessWidget {
  final Map<String, dynamic> match;
  final String league;

  const MatchDetails({
    super.key,
    required this.match,
    required this.league,
  });

  Widget line(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            pct(value),
            style: const TextStyle(
              color: green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = obj(match['prediction']);
    final r = obj(p['resultPercent']);
    final g = obj(p['overGoalsPercent']);
    final x = obj(p['expectedGoals']);
    final s = obj(p['mostLikelyScore']);
    final home = obj(match['homeStats']);
    final away = obj(match['awayStats']);

    return Scaffold(
      appBar: AppBar(title: const Text('Detaljna analiza')),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          Text(
            league,
            textAlign: TextAlign.center,
            style: const TextStyle(color: green),
          ),
          const SizedBox(height: 14),
          Text(
            '${match['home']}\nVS\n${match['away']}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            dateText(match['date']),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          section(
            'Vjerovatnoća ishoda',
            Column(
              children: [
                line('Pobjeda domaćina', r['home']),
                line('Neriješeno', r['draw']),
                line('Pobjeda gosta', r['away']),
              ],
            ),
          ),
          section(
            'Analiza golova',
            Column(
              children: [
                line('Više od 1.5', g['1.5']),
                line('Više od 2.5', g['2.5']),
                line('Više od 3.5', g['3.5']),
                line('Oba tima daju gol',
                    p['bothTeamsScorePercent']),
              ],
            ),
          ),
          section(
            'Očekivani golovi',
            Text(
              '${match['home']}: ${x['home'] ?? '—'}\n'
              '${match['away']}: ${x['away'] ?? '—'}\n'
              'Ukupno: ${x['total'] ?? '—'}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          section(
            'Najvjerovatniji rezultat',
            Text(
              '${s['home'] ?? '—'} : ${s['away'] ?? '—'}'
              '  (${pct(s['percent'])})',
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          section(
            'Statistika ekipa',
            Column(
              children: [
                Text(
                  'Prosjek postignutih golova: '
                  '${home['goalsFor'] ?? '—'} / '
                  '${away['goalsFor'] ?? '—'}',
                ),
                const SizedBox(height: 10),
                Text(
                  'Prosjek primljenih golova: '
                  '${home['goalsAgainst'] ?? '—'} / '
                  '${away['goalsAgainst'] ?? '—'}',
                ),
              ],
            ),
          ),
          const Text(
            'Statistička procjena, ne garancija ishoda.',
            textAlign: TextAlign.center,
            style: TextStyle(color: soft),
          ),
        ],
      ),
    );
  }
}
