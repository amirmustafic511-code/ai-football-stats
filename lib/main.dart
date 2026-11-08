
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const Color kBg = Color(0xFF08131F);
const Color kPanel = Color(0xFF172839);
const Color kMint = Color(0xFF38E49B);
const Color kSoft = Color(0xFFB8C7D2);

const String kServer =
    'https://football-intelligence-api.football-intelligence-ai.workers.dev';

void main() => runApp(const FootballIntelligenceApp());

class FootballIntelligenceApp extends StatelessWidget {
  const FootballIntelligenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Football Intelligence AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kMint,
          brightness: Brightness.dark,
          surface: kBg,
        ),
      ),
      home: const DashboardPage(),
    );
  }
}

class LeagueChoice {
  final String code;
  final String name;

  const LeagueChoice(this.code, this.name);
}

const List<LeagueChoice> leagues = [
  LeagueChoice('PL', 'Premier League'),
  LeagueChoice('PD', 'La Liga'),
  LeagueChoice('SA', 'Serie A'),
  LeagueChoice('BL1', 'Bundesliga'),
  LeagueChoice('FL1', 'Ligue 1'),
  LeagueChoice('CL', 'Liga prvaka'),
  LeagueChoice('PPL', 'Portugal'),
  LeagueChoice('ELC', 'Championship'),
];

Future<Map<String, dynamic>> getJson(String path) async {
  final client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 15);

  try {
    final request =
        await client.getUrl(Uri.parse('$kServer$path'));

    final response = await request.close().timeout(
      const Duration(seconds: 20),
    );

    final raw = await utf8.decoder.bind(response).join();
    final decoded = jsonDecode(raw);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'Server nije poslao ispravan odgovor.',
      );
    }

    if (response.statusCode != 200 ||
        decoded['error'] != null) {
      throw Exception(
        decoded['error'] ?? 'HTTP ${response.statusCode}',
      );
    }

    return decoded;
  } finally {
    client.close(force: true);
  }
}

Map<String, dynamic> asMap(dynamic input) {
  if (input is Map<String, dynamic>) return input;
  return <String, dynamic>{};
}

List<Map<String, dynamic>> asMaps(dynamic input) {
  if (input is! List) return [];

  return input
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

String displayDate(dynamic input) {
  final date = DateTime.tryParse('$input')?.toLocal();

  if (date == null) return 'Termin nije potvrđen';

  String n(int v) => v.toString().padLeft(2, '0');

  return '${n(date.day)}.${n(date.month)}.${date.year}. • '
      '${n(date.hour)}:${n(date.minute)}';
}

String percent(dynamic n) =>
    n is num ? '${n.round()}%' : '—';

String number(dynamic n) =>
    n is num ? n.toStringAsFixed(2) : '—';

Widget sectionCard({
  required String title,
  required Widget child,
}) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      color: kPanel,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: const Color(0xFF243A4C),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: kMint,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        child,
      ],
    ),
  );
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() =>
      _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int tab = 0;
  String code = 'PL';

  late Future<Map<String, dynamic>> leagueFuture;
  late Future<Map<String, dynamic>> newsFuture;

  Timer? refreshTimer;

  @override
  void initState() {
    super.initState();
    _reload();

    refreshTimer = Timer.periodic(
      const Duration(hours: 1),
      (_) {
        if (mounted) setState(_reload);
      },
    );
  }

  void _reload() {
    leagueFuture = getJson(
      '/api/league?code=$code',
    );
    newsFuture = getJson('/api/news');
  }

  void _changeLeague(String next) {
    if (next == code) return;

    setState(() {
      code = next;
      leagueFuture = getJson(
        '/api/league?code=$code',
      );
    });
  }

  Future<void> _refresh() async {
    setState(_reload);

    try {
      await leagueFuture;
    } catch (_) {
      // Greska se prikazuje na ekranu.
    }
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }

  Widget _leagueChooser() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        separatorBuilder: (_, unused) =>
            const SizedBox(width: 8),
        itemCount: leagues.length,
        itemBuilder: (context, index) {
          final l = leagues[index];
          final active = l.code == code;

          return ChoiceChip(
            label: Text(l.name),
            selected: active,
            onSelected: (_) => _changeLeague(l.code),
            selectedColor: kMint,
            labelStyle: TextStyle(
              color: active ? kBg : Colors.white,
              fontWeight: FontWeight.w700,
            ),
            backgroundColor: kPanel,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
          );
        },
      ),
    );
  }

  Widget _loading() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(60),
        child: CircularProgressIndicator(
          color: kMint,
        ),
      ),
    );
  }

  Widget _error(Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off,
              size: 40,
              color: kMint,
            ),
            const SizedBox(height: 16),
            const Text(
              'Podaci trenutno nisu dostupni.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: kSoft),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () => setState(_reload),
              child: const Text('Pokušaj ponovo'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _leagueBody() {
    return Column(
      children: [
        const SizedBox(height: 12),
        _leagueChooser(),
        const SizedBox(height: 8),
        Expanded(
          child: FutureBuilder<Map<String, dynamic>>(
            future: leagueFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData &&
                  !snapshot.hasError) {
                return _loading();
              }

              if (snapshot.hasError) {
                return _error(snapshot.error);
              }

              final data = snapshot.data ?? {};
              final matches = asMaps(data['matches']);

              return RefreshIndicator(
                color: kMint,
                onRefresh: _refresh,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _summaryHeader(data, matches),

                    if (tab == 2)
                      _statisticsOverview(data, matches),

                    if (tab != 2) ...[
                      const SizedBox(height: 12),
                      Text(
                        tab == 0
                            ? 'Naredne utakmice'
                            : 'Sve prognoze',
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (matches.isEmpty)
                        sectionCard(
                          title: 'Trenutno nema utakmica',
                          child: Text(
                            '${data['note'] ?? 'Nema dostupnog rasporeda.'}',
                            style: const TextStyle(
                              color: kSoft,
                            ),
                          ),
                        ),

                      ...matches.map(
                        (m) => _matchTile(m),
                      ),
                    ],

                    const SizedBox(height: 16),
                    const Text(
                      'Football data provided by the Football-Data.org API',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: kSoft,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Europa liga i Premijer liga BiH: dodatni izvor podataka tek treba povezati.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: kSoft,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _summaryHeader(
    Map<String, dynamic> data,
    List<Map<String, dynamic>> matches,
  ) {
    final league = asMap(data['league']);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(23),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF134333),
            Color(0xFF142638),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: kMint,
              ),
              SizedBox(width: 8),
              Text(
                'FOOTBALL INTELLIGENCE AI',
                style: TextStyle(
                  color: kMint,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${league['name'] ?? 'Liga'}',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${matches.length} narednih utakmica • '
            '${data['finishedMatches'] ?? 0} odigranih za analizu',
            style: const TextStyle(color: kSoft),
          ),
          const SizedBox(height: 6),
          Text(
            'Posljednje ažuriranje: '
            '${displayDate(data['updatedAt'])}',
            style: const TextStyle(
              color: kSoft,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 13),
          const Text(
            'Naše statističke prognoze • bez LIVE semafora',
            style: TextStyle(
              fontSize: 12,
              color: kMint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _matchTile(Map<String, dynamic> m) {
    final p = asMap(m['prediction']);
    final result = asMap(p['resultPercent']);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: kPanel,
        borderRadius: BorderRadius.circular(19),
        child: InkWell(
          borderRadius: BorderRadius.circular(19),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MatchDetailPage(
                  match: m,
                  league: leagues.firstWhere(
                    (l) => l.code == code,
                  ).name,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayDate(m['date']),
                  style: const TextStyle(
                    color: kSoft,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${m['home']}  –  ${m['away']}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),

                if (p.isNotEmpty)
                  Row(
                    children: [
                      Expanded(
                        child: _miniPercent(
                          '1',
                          result['home'],
                        ),
                      ),
                      Expanded(
                        child: _miniPercent(
                          'X',
                          result['draw'],
                        ),
                      ),
                      Expanded(
                        child: _miniPercent(
                          '2',
                          result['away'],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: kMint,
                      ),
                    ],
                  )
                else
                  const Text(
                    'Nedovoljno podataka za pouzdanu procjenu',
                    style: TextStyle(
                      color: kSoft,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _miniPercent(
    String label,
    dynamic value,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: kSoft,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          percent(value),
          style: const TextStyle(
            color: kMint,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _statisticsOverview(
    Map<String, dynamic> data,
    List<Map<String, dynamic>> matches,
  ) {
    if (matches.isEmpty) {
      return sectionCard(
        title: 'Statistika',
        child: const Text(
          'Nema dostupnih utakmica.',
        ),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 14),
        sectionCard(
          title: 'Statistika lige',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Odigrane utakmice: ${data['finishedMatches']}',
              ),
              const SizedBox(height: 8),
              Text(
                'Naredne utakmice: ${matches.length}',
              ),
              const SizedBox(height: 8),
              const Text(
                'Odaberi utakmicu za formu, napad i odbranu.',
                style: TextStyle(color: kSoft),
              ),
            ],
          ),
        ),
        ...matches.map(_matchTile),
      ],
    );
  }

  Widget _newsBody() {
    return FutureBuilder<Map<String, dynamic>>(
      future: newsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData &&
            !snapshot.hasError) {
          return _loading();
        }

        if (snapshot.hasError) {
          return _error(snapshot.error);
        }

        final data = snapshot.data ?? {};
        final articles = asMaps(data['articles']);

        return RefreshIndicator(
          color: kMint,
          onRefresh: () async {
            setState(() {
              newsFuture = getJson('/api/news');
            });

            try {
              await newsFuture;
            } catch (_) {
              // Greska se prikazuje na ekranu.
            }
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Najnovije fudbalske vijesti',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),

              if (articles.isEmpty)
                sectionCard(
                  title: 'Izvor vijesti nije povezan',
                  child: Text(
                    '${data['message'] ?? 'Vijesti nisu dostupne.'}\n\n'
                    'Za automatske vijesti treba dozvoljen, '
                    'licenciran izvor. '
                    'Ne prikazujemo izmišljene naslove.',
                    style: const TextStyle(
                      color: kSoft,
                    ),
                  ),
                ),

              ...articles.map(
                (a) => sectionCard(
                  title: '${a['source'] ?? 'Izvor'}',
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        (a['title'] ?? '').toString(),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Text(
                        (a['description'] ?? '').toString(),
                        style: const TextStyle(
                          color: kSoft,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Text(
                        displayDate(a['publishedAt']),
                        style: const TextStyle(
                          color: kSoft,
                          fontSize: 12,
                        ),
                      ),

                      TextButton.icon(
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(
                              text: '${a['url'] ?? ''}',
                            ),
                          );

                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Link kopiran. Zalijepi ga u preglednik.',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.link),
                        label: const Text(
                          'Kopiraj link na izvor',
                        ),
                      ),
                    ],
                  ),
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
        backgroundColor: const Color(0xFF122535),
        title: const Text(
          'FOOTBALL INTELLIGENCE AI',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.3,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => setState(_reload),
            icon: const Icon(
              Icons.refresh,
              color: kMint,
            ),
          ),
        ],
      ),
      body: tab == 3
          ? _newsBody()
          : _leagueBody(),

      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF122535),
        selectedIndex: tab,
        onDestinationSelected: (index) {
          setState(() {
            tab = index;
          });
        },
        indicatorColor: const Color(0xFF1C5C46),
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

class MatchDetailPage extends StatelessWidget {
  final Map<String, dynamic> match;
  final String league;

  const MatchDetailPage({
    super.key,
    required this.match,
    required this.league,
  });

  Widget _bar(
    String title,
    dynamic value,
  ) {
    final numeric =
        value is num ? value.toDouble() : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title),
              ),
              Text(
                percent(value),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: kMint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          LinearProgressIndicator(
            value: (numeric / 100)
                .clamp(0.0, 1.0)
                .toDouble(),
            minHeight: 8,
            color: kMint,
            backgroundColor:
                const Color(0xFF345164),
            borderRadius:
                BorderRadius.circular(9),
          ),
        ],
      ),
    );
  }

  Widget _statLine(
    String title,
    dynamic a,
    dynamic b,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              '$a',
              style: const TextStyle(
                color: kMint,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: kSoft,
              ),
            ),
          ),
          SizedBox(
            width: 70,
            child: Text(
              '$b',
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: kMint,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _form(
    String name,
    Map<String, dynamic> stats,
  ) {
    final results = stats['form'] is List
        ? stats['form'] as List
        : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 7),

        Wrap(
          spacing: 6,
          children: results.map((value) {
            final v = '$value';

            final color = v == 'P'
                ? kMint
                : (v == 'N'
                    ? Colors.amber
                    : Colors.redAccent);

            return CircleAvatar(
              radius: 15,
              backgroundColor: color,
              child: Text(
                v,
                style: const TextStyle(
                  color: kBg,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final prediction =
        asMap(match['prediction']);

    final result =
        asMap(prediction['resultPercent']);

    final goals =
        asMap(prediction['overGoalsPercent']);

    final expected =
        asMap(prediction['expectedGoals']);

    final score =
        asMap(prediction['mostLikelyScore']);

    final homeStats =
        asMap(match['homeStats']);

    final awayStats =
        asMap(match['awayStats']);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI analiza utakmice',
        ),
        backgroundColor:
            const Color(0xFF122535),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            league,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: kMint,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 9),

          Text(
            '${match['home']}\n–\n${match['away']}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            displayDate(match['date']),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: kSoft,
            ),
          ),
          const SizedBox(height: 20),

          if (prediction.isEmpty)
            sectionCard(
              title: 'Još nema prognoze',
              child: const Text(
                'Za ovaj susret još nema dovoljno statističkih podataka.',
              ),
            ),

          if (prediction.isNotEmpty) ...[
            sectionCard(
              title: 'Vjerovatnoća ishoda',
              child: Column(
                children: [
                  _bar(
                    'Pobjeda domaćina (1)',
                    result['home'],
                  ),
                  _bar(
                    'Neriješeno (X)',
                    result['draw'],
                  ),
                  _bar(
                    'Pobjeda gosta (2)',
                    result['away'],
                  ),
                ],
              ),
            ),

            sectionCard(
              title: 'Više / manje golova',
              child: Column(
                children: [
                  _bar(
                    'Više od 1,5',
                    goals['1.5'],
                  ),
                  _bar(
                    'Manje od 1,5',
                    goals['1.5'] is num
                        ? 100 - goals['1.5']
                        : null,
                  ),
                  _bar(
                    'Više od 2,5',
                    goals['2.5'],
                  ),
                  _bar(
                    'Manje od 2,5',
                    goals['2.5'] is num
                        ? 100 - goals['2.5']
                        : null,
                  ),
                  _bar(
                    'Više od 3,5',
                    goals['3.5'],
                  ),
                  _bar(
                    'Oba tima daju gol',
                    prediction['bothTeamsScorePercent'],
                  ),
                ],
              ),
            ),

            sectionCard(
              title: 'Očekivani golovi',
              child: Column(
                children: [
                  _statLine(
                    'Očekivani golovi',
                    number(expected['home']),
                    number(expected['away']),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Ukupno ${number(expected['total'])}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            sectionCard(
              title: 'Najvjerovatniji rezultat',
              child: Text(
                '${score['home']} : ${score['away']}'
                '  •  ${percent(score['percent'])}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],

          sectionCard(
            title:
                'Forma i statistika (zadnjih 5 utakmica)',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _statLine(
                  'Prosjek postignutih',
                  homeStats['goalsFor'] ?? '—',
                  awayStats['goalsFor'] ?? '—',
                ),
                _statLine(
                  'Prosjek primljenih',
                  homeStats['goalsAgainst'] ?? '—',
                  awayStats['goalsAgainst'] ?? '—',
                ),
                const Divider(
                  color: Color(0xFF344B5B),
                ),
                _form(
                  '${match['home']}',
                  homeStats,
                ),
                const SizedBox(height: 12),
                _form(
                  '${match['away']}',
                  awayStats,
                ),
                const SizedBox(height: 10),
                const Text(
                  'P = pobjeda  N = neriješeno  I = poraz',
                  style: TextStyle(
                    color: kSoft,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],

          Text(
            '${prediction['confidence'] ?? 'Statistička procjena.'}\n'
            'Brojevi nisu sigurni ishodi ni preporuka za klađenje.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: kSoft,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
