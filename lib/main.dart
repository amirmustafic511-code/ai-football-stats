
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

void main() => runApp(const FootballApp());

class FootballApp extends StatelessWidget {
  const FootballApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Football Intelligence AI',
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

class Match {
  final String home, away, date;
  final int? homeGoals, awayGoals;

  const Match(
    this.home,
    this.away,
    this.date,
    this.homeGoals,
    this.awayGoals,
  );

  bool get played => homeGoals != null && awayGoals != null;

  factory Match.fromJson(Map<String, dynamic> json) {
    final score = json['score'];
    dynamic ft;

    if (score is Map) ft = score['ft'];
    if (score is List) ft = score;

    int? h, a;

    if (ft is List &&
        ft.length >= 2 &&
        ft[0] is num &&
        ft[1] is num) {
      h = (ft[0] as num).toInt();
      a = (ft[1] as num).toInt();
    }

    return Match(
      (json['team1'] ?? '').toString(),
      (json['team2'] ?? '').toString(),
      (json['date'] ?? '').toString(),
      h,
      a,
    );
  }
}

class TeamRow {
  final String name;

  int played = 0;
  int won = 0;
  int drawn = 0;
  int lost = 0;
  int gf = 0;
  int ga = 0;

  TeamRow(this.name);

  int get points => won * 3 + drawn;
  int get difference => gf - ga;
}

class League {
  final String name;
  final String file;

  const League(this.name, this.file);
}

class FootballData {
  static const leagues = [
    League('Premier League', 'en.1.json'),
    League('La Liga', 'es.1.json'),
    League('Serie A', 'it.1.json'),
    League('Bundesliga', 'de.1.json'),
    League('Ligue 1', 'fr.1.json'),
  ];

  static Future<List<Match>> load(String file) async {
    final source =
        'https://raw.githubusercontent.com/openfootball/football.json/master/2026-27/$file';

    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15);

    try {
      final request = await client.getUrl(Uri.parse(source));
      final response = await request.close();

      if (response.statusCode != 200) {
        throw Exception(
          'Izvor podataka nije dostupan (${response.statusCode}).',
        );
      }

      final body = await response.transform(utf8.decoder).join();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final entries = data['matches'] as List<dynamic>;

      final matches = entries
          .map(
            (item) => Match.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .where((m) => m.home.isNotEmpty && m.away.isNotEmpty)
          .toList();

      matches.sort((a, b) => a.date.compareTo(b.date));

      return matches;
    } finally {
      client.close(force: true);
    }
  }

  static List<TeamRow> table(List<Match> matches) {
    final rows = <String, TeamRow>{};

    for (final match in matches) {
      final home = rows.putIfAbsent(
        match.home,
        () => TeamRow(match.home),
      );

      final away = rows.putIfAbsent(
        match.away,
        () => TeamRow(match.away),
      );

      if (!match.played) continue;

      final hg = match.homeGoals!;
      final ag = match.awayGoals!;

      home.played++;
      away.played++;

      home.gf += hg;
      home.ga += ag;

      away.gf += ag;
      away.ga += hg;

      if (hg > ag) {
        home.won++;
        away.lost++;
      } else if (hg < ag) {
        away.won++;
        home.lost++;
      } else {
        home.drawn++;
        away.drawn++;
      }
    }

    final result = rows.values.toList();

    result.sort((a, b) {
      final p = b.points.compareTo(a.points);
      if (p != 0) return p;

      final d = b.difference.compareTo(a.difference);
      if (d != 0) return d;

      final g = b.gf.compareTo(a.gf);

      return g != 0 ? g : a.name.compareTo(b.name);
    });

    return result;
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedTab = 0;

  League league = FootballData.leagues.first;

  late Future<List<Match>> futureMatches;

  @override
  void initState() {
    super.initState();
    futureMatches = FootballData.load(league.file);
  }

  void refresh() {
    setState(() {
      futureMatches = FootballData.load(league.file);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FOOTBALL INTELLIGENCE AI',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF17232D),
        actions: [
          IconButton(
            tooltip: 'Osvježi podatke',
            icon: const Icon(Icons.refresh),
            onPressed: refresh,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
            child: DropdownButtonFormField<String>(
              value: league.file,
              decoration: const InputDecoration(
                labelText: 'Izaberi ligu',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: FootballData.leagues.map((l) {
                return DropdownMenuItem<String>(
                  value: l.file,
                  child: Text(l.name),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  league = FootballData.leagues.firstWhere(
                    (l) => l.file == value,
                  );

                  futureMatches = FootballData.load(league.file);
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Match>>(
              future: futureMatches,
              builder: (context, snapshot) {
                if (snapshot.connectionState !=
                    ConnectionState.done) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return ListView(
                    children: [
                      const SizedBox(height: 90),
                      const Icon(
                        Icons.cloud_off_outlined,
                        size: 46,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Podaci nisu dostupni za ovu ligu.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          '${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white60,
                          ),
                        ),
                      ),
                      Center(
                        child: ElevatedButton(
                          onPressed: refresh,
                          child: const Text('Pokušaj ponovo'),
                        ),
                      ),
                    ],
                  );
                }

                final matches = snapshot.data ?? [];
                final table = FootballData.table(matches);

                return IndexedStack(
                  index: selectedTab,
                  children: [
                    _matches(matches),
                    _analysis(matches, table),
                    _table(table),
                    _info(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedTab,
        onDestinationSelected: (i) {
          setState(() {
            selectedTab = i;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Utakmice',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome),
            label: 'Analiza',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart),
            label: 'Tabela',
          ),
          NavigationDestination(
            icon: Icon(Icons.info_outline),
            label: 'Info',
          ),
        ],
      ),
    );
  }

  Widget _notice() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 14),
      child: Text(
        'OpenFootball • 2026/27 • podaci mogu kasniti, nisu uživo.',
        style: TextStyle(
          color: Colors.amberAccent,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _matches(List<Match> matches) {
    final now = DateTime.now();

    final today =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';

    final upcoming = matches
        .where(
          (m) => !m.played && m.date.compareTo(today) >= 0,
        )
        .take(20);

    final recent = matches
        .where((m) => m.played)
        .toList()
        .reversed
        .take(20);

    final selected = [...upcoming, ...recent];

    return RefreshIndicator(
      onRefresh: () async {
        refresh();

        try {
          await futureMatches;
        } catch (_) {}
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            league.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _notice(),
          const Text(
            'Raspored i posljednji dostupni rezultati',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (selected.isEmpty)
            const Text(
              'Nema dostupnih utakmica za ovu sezonu.',
            ),
          ...selected.map((m) {
            return Card(
              color: const Color(0xFF1D2B36),
              child: ListTile(
                leading: const Icon(
                  Icons.sports_soccer,
                  color: Color(0xFF00D68F),
                ),
                title: Text('${m.home} – ${m.away}'),
                subtitle: Text(m.date),
                trailing: Text(
                  m.played
                      ? '${m.homeGoals}:${m.awayGoals}'
                      : '– : –',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _table(List<TeamRow> rows) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text(
          'Tabela: ${league.name}',
          style: const TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        _notice(),
        const Text(
          'U = utakmice  P = pobjede  N = neriješeno  '
          'I = porazi  GR = gol-razlika  B = bodovi',
          style: TextStyle(fontSize: 12),
        ),
        const SizedBox(height: 10),
        if (rows.isEmpty)
          const Text('Tabela nije dostupna.'),
        ...rows.asMap().entries.map((entry) {
          final r = entry.value;

          return Card(
            child: ListTile(
              dense: true,
              title: Text('${entry.key + 1}. ${r.name}'),
              subtitle: Text(
                'U ${r.played}  P ${r.won}  N ${r.drawn}  '
                'I ${r.lost}  GR ${r.difference >= 0 ? '+' : ''}${r.difference}',
              ),
              trailing: Text(
                '${r.points} B',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _analysis(
    List<Match> matches,
    List<TeamRow> rows,
  ) {
    final played = matches.where((m) => m.played).length;

    final totalGoals = matches
        .where((m) => m.played)
        .fold<int>(
          0,
          (sum, m) => sum + m.homeGoals! + m.awayGoals!,
        );

    final homeWins = matches.where((m) {
      return m.played && m.homeGoals! > m.awayGoals!;
    }).length;

    final draws = matches.where((m) {
      return m.played && m.homeGoals == m.awayGoals;
    }).length;

    final awayWins = played - homeWins - draws;

    final avg = played == 0 ? 0.0 : totalGoals / played;

    final leader = rows.isEmpty ? null : rows.first;

    final strongestAttack = [...rows]
      ..sort((a, b) => b.gf.compareTo(a.gf));

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(
          'Statistička analiza: ${league.name}',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _notice(),
        const Text(
          'Automatska analiza stvarnih dostupnih rezultata. '
          'Ovo je statistički model, a ne generativni AI.',
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 20),
        _metric('Odigrane utakmice', '$played'),
        _metric('Ukupno golova', '$totalGoals'),
        _metric(
          'Prosječno golova po utakmici',
          avg.toStringAsFixed(2),
        ),
        _metric('Pobjede domaćina', '$homeWins'),
        _metric('Neriješeno', '$draws'),
        _metric('Pobjede gostiju', '$awayWins'),
        if (leader != null)
          _metric(
            'Prvoplasirana ekipa',
            '${leader.name} (${leader.points} bodova)',
          ),
        if (strongestAttack.isNotEmpty)
          _metric(
            'Najviše postignutih golova',
            '${strongestAttack.first.name} '
                '(${strongestAttack.first.gf})',
          ),
        const SizedBox(height: 16),
        const Text(
          'Napomena: analiza zavisi od potpunosti i ažurnosti izvora. '
          'Ne predstavlja prognozu niti savjet za klađenje.',
          style: TextStyle(
            color: Colors.amberAccent,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _metric(String title, String value) {
    return Card(
      color: const Color(0xFF1D2B36),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        child: Row(
          children: [
            Expanded(child: Text(title)),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00D68F),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _info() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        Text(
          'Football Intelligence AI',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 14),
        Text(
          'Podaci: OpenFootball (CC0, javno dostupni).',
        ),
        SizedBox(height: 10),
        Text(
          'Aplikacija preuzima podatke prilikom otvaranja '
          'i na dugme za osvježavanje. Ne traži API ključ.',
        ),
        SizedBox(height: 10),
        Text(
          'Rezultati nisu uživo i mogu biti nepotpuni. '
          'Tabela je izračunata iz dostupnih rezultata, '
          'bez posebnih ligaških pravila i kaznenih bodova.',
        ),
        SizedBox(height: 10),
        Text(
          'Liga prvaka, Europa liga i Premijer liga BiH '
          'još nisu povezane jer izvor nije potvrđen.',
        ),
        SizedBox(height: 10),
        Text(
          'Pretplate i korisnički računi još nisu uključeni.',
        ),
      ],
    );
  }
}
