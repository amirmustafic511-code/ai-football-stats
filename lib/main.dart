import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

// Football Intelligence AI - Android client v3.
// Only Flutter SDK libraries are used; no pubspec changes are required.
// Predictions are statistical estimates, not guaranteed outcomes.
const apiBase =
    'https://football-intelligence-api.football-intelligence-ai.workers.dev';
const navy = Color(0xFF071320);
const surface = Color(0xFF142537);
const cardBorder = Color(0xFF294154);
const mint = Color(0xFF37E6A0);
const muted = Color(0xFFAFC1D0);
const yellow = Color(0xFFF3C66E);
const blue = Color(0xFF74B8FF);

class League {
  final String code;
  final String name;
  const League(this.code, this.name);
}

const leagues = <League>[
  League('PL', 'Premier League'),
  League('PD', 'La Liga'),
  League('SA', 'Serie A'),
  League('BL1', 'Bundesliga'),
  League('FL1', 'Ligue 1'),
  League('CL', 'Champions League'),
  League('PPL', 'Primeira Liga'),
  League('ELC', 'Championship'),
];

const translations = <String, Map<String, String>>{
  'en': {
    'home': 'Home', 'ai': 'AI Predictions', 'stats': 'Statistics',
    'news': 'News', 'upcoming': 'Upcoming matches', 'matchCenter': 'Match Center',
    'matches': 'matches', 'analyzed': 'completed for analysis',
    'updated': 'Updated', 'details': 'View full analysis',
    'noGames': 'No upcoming matches are currently available.',
    'retry': 'Try again', 'unavailable': 'Data is temporarily unavailable',
    'result': 'Match outcome', 'homeWin': 'Home win', 'draw': 'Draw',
    'awayWin': 'Away win', 'goals': 'Goal probabilities', 'btts': 'Both teams score',
    'xg': 'Expected goals (model)', 'score': 'Most likely score',
    'form': 'Recent team form', 'scored': 'Goals scored / match',
    'conceded': 'Goals conceded / match',
    'info': 'Model probabilities are estimates, not certain results.',
    'month': 'This month', 'won': 'Correct', 'lost': 'Incorrect',
    'pending': 'Awaiting', 'rate': 'Accuracy', 'picks': 'Published AI picks',
    'noPicks': 'No daily picks have been published yet.',
    'preview': 'Model watchlist (not published picks)',
    'previewInfo': 'These are live statistical previews. They do not count toward monthly accuracy.',
    'newsTitle': 'Football news', 'newsMissing': 'News feed not connected yet',
    'newsInfo': 'A licensed news provider must be connected on the server. No invented headlines will be shown.',
    'recent': 'Recent form of teams with upcoming fixtures',
    'noPrediction': 'Not enough historical data for this estimate.',
    'selectLang': 'Language', 'cancelled': 'Cancelled',
    'attribution': 'Match data: Football-Data.org',
  },
  'bs': {
    'home': 'Početna', 'ai': 'AI Prognoze', 'stats': 'Statistika',
    'news': 'Vijesti', 'upcoming': 'Naredne utakmice', 'matchCenter': 'Centar utakmica',
    'matches': 'utakmica', 'analyzed': 'odigranih za analizu',
    'updated': 'Ažurirano', 'details': 'Pogledaj detaljnu analizu',
    'noGames': 'Trenutno nema dostupnih narednih utakmica.',
    'retry': 'Pokušaj ponovo', 'unavailable': 'Podaci trenutno nisu dostupni',
    'result': 'Ishod utakmice', 'homeWin': 'Pobjeda domaćina', 'draw': 'Remi',
    'awayWin': 'Pobjeda gosta', 'goals': 'Vjerovatnoće golova',
    'btts': 'Oba tima daju gol', 'xg': 'Očekivani golovi (model)',
    'score': 'Najvjerovatniji rezultat', 'form': 'Forma ekipa',
    'scored': 'Postignuti golovi / meč', 'conceded': 'Primljeni golovi / meč',
    'info': 'Procjene modela nisu sigurni rezultati.',
    'month': 'Ovaj mjesec', 'won': 'Pogođeno', 'lost': 'Promašeno',
    'pending': 'Na čekanju', 'rate': 'Uspješnost', 'picks': 'Objavljene AI prognoze',
    'noPicks': 'Dnevne prognoze još nisu objavljene.',
    'preview': 'Statistički pregled (nisu objavljene prognoze)',
    'previewInfo': 'Ovo su trenutne procjene. Ne računaju se u mjesečnu uspješnost.',
    'newsTitle': 'Fudbalske vijesti', 'newsMissing': 'Izvor vijesti još nije povezan',
    'newsInfo': 'Na server treba povezati dozvoljen izvor vijesti. Ne prikazujemo izmišljene naslove.',
    'recent': 'Forma timova koji imaju naredne utakmice',
    'noPrediction': 'Nema dovoljno prethodnih utakmica za procjenu.',
    'selectLang': 'Jezik', 'cancelled': 'Otkazano',
    'attribution': 'Podaci o mečevima: Football-Data.org',
  },
};

String tr(String language, String key) =>
    translations[language]?[key] ?? translations['en']?[key] ?? key;

Future<Map<String, dynamic>> getJson(String endpoint) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
  try {
    final request = await client.getUrl(Uri.parse('$apiBase$endpoint'));
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    final response = await request.close().timeout(const Duration(seconds: 22));
    final raw = await utf8.decoder.bind(response).join().timeout(
          const Duration(seconds: 22),
        );
    final decoded = jsonDecode(raw);
    if (decoded is! Map) throw const FormatException('Invalid server response');
    final result = Map<String, dynamic>.from(decoded);
    if (response.statusCode != 200 || result['error'] != null) {
      throw Exception('${result['error'] ?? 'HTTP ${response.statusCode}'}'
          '${result['detail'] == null ? '' : ': ${result['detail']}'}');
    }
    return result;
  } finally {
    client.close(force: true);
  }
}

Map<String, dynamic> asObject(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

List<Map<String, dynamic>> asObjects(dynamic value) => value is List
    ? value.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
    : <Map<String, dynamic>>[];

num? asNumber(dynamic v) => v is num ? v : num.tryParse('$v');
String percent(dynamic v) =>
    asNumber(v) == null ? '—' : '${asNumber(v)!.round()}%';
String decimal(dynamic v) =>
    asNumber(v) == null ? '—' : asNumber(v)!.toStringAsFixed(2);
String twoDigits(int n) => n.toString().padLeft(2, '0');
String formattedDate(dynamic value) {
  final d = DateTime.tryParse('$value')?.toLocal();
  if (d == null) return '—';
  return '${twoDigits(d.day)}.${twoDigits(d.month)}.${d.year}  '
      '${twoDigits(d.hour)}:${twoDigits(d.minute)}';
}

void main() => runApp(const FootballApp());

class FootballApp extends StatefulWidget {
  const FootballApp({super.key});
  @override
  State<FootballApp> createState() => _FootballAppState();
}

class _FootballAppState extends State<FootballApp> {
  String language = 'en';

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Football Intelligence AI',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: navy,
          colorScheme: ColorScheme.fromSeed(
            seedColor: mint,
            brightness: Brightness.dark,
          ),
          appBarTheme: const AppBarTheme(backgroundColor: navy),
        ),
        home: Dashboard(
          language: language,
          onLanguageChanged: (l) => setState(() => language = l),
        ),
      );
}

class Dashboard extends StatefulWidget {
  final String language;
  final ValueChanged<String> onLanguageChanged;
  const Dashboard({
    super.key,
    required this.language,
    required this.onLanguageChanged,
  });

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int tab = 0;
  String league = 'PL';
  late Future<Map<String, dynamic>> fixturesFuture;
  late Future<Map<String, dynamic>> picksFuture;
  late Future<Map<String, dynamic>> newsFuture;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  void _loadAll() {
    fixturesFuture = getJson('/api/league?code=$league');
    picksFuture = getJson('/api/ai-predictions');
    newsFuture = getJson('/api/news');
  }

  Future<void> _refresh() async {
    setState(() {
      if (tab == 1) {
        picksFuture = getJson('/api/ai-predictions');
        fixturesFuture = getJson('/api/league?code=$league');
      } else if (tab == 3) {
        newsFuture = getJson('/api/news');
      } else {
        fixturesFuture = getJson('/api/league?code=$league');
      }
    });
    try {
      if (tab == 1) await picksFuture;
      if (tab == 3) await newsFuture;
      if (tab == 0 || tab == 2) await fixturesFuture;
    } catch (_) {
      // The error state is presented by FutureBuilder.
    }
  }

  void _setLeague(String code) {
    if (league == code) return;
    setState(() {
      league = code;
      fixturesFuture = getJson('/api/league?code=$code');
    });
  }

  Widget _head(String title, String caption) => Padding(
        padding: const EdgeInsets.fromLTRB(17, 12, 17, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.4,
                )),
            const SizedBox(height: 5),
            Text(caption, style: const TextStyle(color: muted, fontSize: 12)),
          ],
        ),
      );

  Widget _leagues() => SizedBox(
        height: 53,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          itemCount: leagues.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final l = leagues[i];
            final active = league == l.code;
            return ChoiceChip(
              label: Text(l.name),
              selected: active,
              onSelected: (_) => _setLeague(l.code),
              backgroundColor: surface,
              selectedColor: mint,
              labelStyle: TextStyle(
                color: active ? navy : Colors.white,
                fontWeight: FontWeight.w700,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            );
          },
        ),
      );

  Widget _loading() => const Center(
        child: CircularProgressIndicator(color: mint),
      );

  Widget _error(Object? error) => Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.cloud_off_outlined, color: mint, size: 46),
            const SizedBox(height: 12),
            Text(tr(widget.language, 'unavailable'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 9),
            Text('$error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: muted, fontSize: 12)),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh),
              label: Text(tr(widget.language, 'retry')),
            ),
          ]),
        ),
      );

  Widget _fixturesPage() => Column(children: [
        _leagues(),
        Expanded(
          child: FutureBuilder<Map<String, dynamic>>(
            future: fixturesFuture,
            builder: (context, snap) {
              if (snap.hasError) return _error(snap.error);
              if (!snap.hasData) return _loading();
              final data = snap.data!;
              final matches = asObjects(data['matches']);
              return RefreshIndicator(
                color: mint,
                onRefresh: _refresh,
                child: ListView(padding: const EdgeInsets.all(15), children: [
                  _leagueHero(data, matches.length),
                  const SizedBox(height: 22),
                  _head(tr(widget.language, 'upcoming'),
                      '${matches.length} ${tr(widget.language, 'matches')}'),
                  if (matches.isEmpty)
                    Panel(child: Text(tr(widget.language, 'noGames'))),
                  for (final m in matches)
                    MatchTile(
                      match: m,
                      language: widget.language,
                      onTap: () => _openMatch(m),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(tr(widget.language, 'attribution'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: muted, fontSize: 11)),
                  ),
                ]),
              );
            },
          ),
        ),
      ]);

  Widget _leagueHero(Map<String, dynamic> data, int count) => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF185744), Color(0xFF10233A)],
          ),
          border: Border.all(color: const Color(0xFF326452)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            Icon(Icons.auto_awesome, color: mint, size: 18),
            SizedBox(width: 8),
            Text('FOOTBALL INTELLIGENCE AI',
                style: TextStyle(
                    color: mint, fontSize: 11, fontWeight: FontWeight.w900)),
          ]),
          const SizedBox(height: 17),
          Text(leagues.firstWhere((l) => l.code == league).name,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 26)),
          const SizedBox(height: 8),
          Text('$count ${tr(widget.language, 'matches')}  •  '
              '${data['finishedMatches'] ?? 0} ${tr(widget.language, 'analyzed')}',
              style: const TextStyle(color: muted, fontSize: 12)),
          const SizedBox(height: 10),
          Text('${tr(widget.language, 'updated')}: '
              '${formattedDate(data['updatedAt'])}',
              style: const TextStyle(color: mint, fontSize: 12)),
        ]),
      );

  void _openMatch(Map<String, dynamic> match) => Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => MatchDetails(
            match: match,
            language: widget.language,
            leagueName: leagues.firstWhere((l) => l.code == league).name,
          ),
        ),
      );

  Widget _aiPage() => FutureBuilder<Map<String, dynamic>>(
        future: picksFuture,
        builder: (context, snap) {
          if (snap.hasError) return _error(snap.error);
          if (!snap.hasData) return _loading();
          final data = snap.data!;
          final records = asObjects(data['matches']);
          final won = asNumber(data['won'])?.toInt() ?? 0;
          final lost = asNumber(data['lost'])?.toInt() ?? 0;
          final pending = asNumber(data['pending'])?.toInt() ?? 0;
          final rate = data['successRate'];
          return RefreshIndicator(
            color: mint,
            onRefresh: _refresh,
            child: ListView(padding: const EdgeInsets.all(15), children: [
              _head(tr(widget.language, 'ai'),
                  '${tr(widget.language, 'month')} • ${data['month'] ?? '—'}'),
              Row(children: [
                Expanded(child: Metric(value: '$won',
                    label: tr(widget.language, 'won'), color: mint)),
                const SizedBox(width: 7),
                Expanded(child: Metric(value: '$lost',
                    label: tr(widget.language, 'lost'),
                    color: const Color(0xFFFF7E88))),
                const SizedBox(width: 7),
                Expanded(child: Metric(value: '$pending',
                    label: tr(widget.language, 'pending'), color: yellow)),
              ]),
              const SizedBox(height: 10),
              Panel(child: Row(children: [
                const Icon(Icons.insights, color: mint, size: 26),
                const SizedBox(width: 12),
                Expanded(child: Text(tr(widget.language, 'rate'),
                    style: const TextStyle(fontWeight: FontWeight.w800))),
                Text(rate == null ? '—' : percent(rate),
                    style: const TextStyle(
                        color: mint, fontSize: 25, fontWeight: FontWeight.w900)),
              ])),
              _head(tr(widget.language, 'picks'),
                  '${records.length} ${tr(widget.language, 'matches')}'),
              if (records.isEmpty)
                Panel(child: Text(tr(widget.language, 'noPicks'),
                    style: const TextStyle(color: muted))),
              for (final pick in records) _pickTile(pick),
              if (records.isEmpty) _previewFromFixtures(),
              const SizedBox(height: 8),
              Text(tr(widget.language, 'info'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: muted, fontSize: 12)),
            ]),
          );
        },
      );

  Widget _pickTile(Map<String, dynamic> item) {
    final status = '${item['status'] ?? 'pending'}';
    final icon = status == 'won'
        ? Icons.check_circle
        : status == 'lost'
            ? Icons.cancel
            : status == 'void'
                ? Icons.remove_circle_outline
                : Icons.schedule;
    final statusColor = status == 'won'
        ? mint
        : status == 'lost'
            ? const Color(0xFFFF7E88)
            : yellow;
    final statusText = status == 'won'
        ? tr(widget.language, 'won')
        : status == 'lost'
            ? tr(widget.language, 'lost')
            : status == 'void'
                ? tr(widget.language, 'cancelled')
                : tr(widget.language, 'pending');
    final pickName = item['pickLabel'] ?? item['prediction_pick'] ?? '—';
    return Panel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: statusColor, size: 24),
          const SizedBox(width: 8),
          Expanded(child: Text('${item['home'] ?? item['home_team'] ?? '—'} – '
              '${item['away'] ?? item['away_team'] ?? '—'}',
              style: const TextStyle(fontWeight: FontWeight.w800))),
          Text(statusText, style: TextStyle(color: statusColor, fontSize: 11)),
        ]),
        const SizedBox(height: 9),
        Text('${item['leagueName'] ?? item['league'] ?? ''}  •  '
            '${formattedDate(item['date'] ?? item['kickoff'])}',
            style: const TextStyle(color: muted, fontSize: 11)),
        const SizedBox(height: 9),
        Text('$pickName  •  ${percent(item['probability'])}',
            style: const TextStyle(color: mint, fontWeight: FontWeight.w800)),
        if (status == 'won' || status == 'lost')
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Text('FT: ${item['home_goals'] ?? '—'} : '
                '${item['away_goals'] ?? '—'}',
                style: const TextStyle(color: muted)),
          ),
      ]),
    );
  }

  Widget _previewFromFixtures() => FutureBuilder<Map<String, dynamic>>(
        future: fixturesFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();
          final matches = asObjects(snapshot.data!['matches'])
              .where((m) => asObject(m['prediction']).isNotEmpty)
              .toList();
          matches.sort((a, b) {
            num top(Map<String, dynamic> m) {
              final p = asObject(asObject(m['prediction'])['resultPercent']);
              final numbers = [p['home'], p['draw'], p['away']]
                  .map(asNumber).whereType<num>().toList();
              numbers.sort((x, y) => y.compareTo(x));
              return numbers.isEmpty ? 0 : numbers.first;
            }
            return top(b).compareTo(top(a));
          });
          if (matches.isEmpty) return const SizedBox.shrink();
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _head(tr(widget.language, 'preview'),
                tr(widget.language, 'previewInfo')),
            for (final m in matches.take(5)) MatchTile(
              match: m,
              language: widget.language,
              onTap: () => _openMatch(m),
            ),
          ]);
        },
      );

  Widget _statsPage() => Column(children: [
        _leagues(),
        Expanded(
          child: FutureBuilder<Map<String, dynamic>>(
            future: fixturesFuture,
            builder: (context, snap) {
              if (snap.hasError) return _error(snap.error);
              if (!snap.hasData) return _loading();
              final data = snap.data!;
              final matches = asObjects(data['matches']);
              final seen = <String, Map<String, dynamic>>{};
              for (final m in matches) {
                final h = '${m['home'] ?? ''}';
                final a = '${m['away'] ?? ''}';
                if (h.isNotEmpty) seen[h] = asObject(m['homeStats']);
                if (a.isNotEmpty) seen[a] = asObject(m['awayStats']);
              }
              final teams = seen.entries.toList();
              teams.sort((a, b) {
                final x = asNumber(a.value['goalsFor']) ?? -1;
                final y = asNumber(b.value['goalsFor']) ?? -1;
                return y.compareTo(x);
              });
              return RefreshIndicator(
                color: mint,
                onRefresh: _refresh,
                child: ListView(padding: const EdgeInsets.all(15), children: [
                  _head(tr(widget.language, 'stats'),
                      '${data['finishedMatches'] ?? 0} '
                      '${tr(widget.language, 'analyzed')}'),
                  Panel(child: Text(tr(widget.language, 'recent'),
                      style: const TextStyle(color: mint,
                          fontWeight: FontWeight.bold))),
                  if (teams.isEmpty)
                    Panel(child: Text(tr(widget.language, 'noGames'))),
                  for (final team in teams)
                    Panel(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(team.key, style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 10),
                        Row(children: [
                          Expanded(child: Text(
                              '${tr(widget.language, 'scored')}: '
                              '${decimal(team.value['goalsFor'])}',
                              style: const TextStyle(color: muted, fontSize: 12))),
                          Expanded(child: Text(
                              '${tr(widget.language, 'conceded')}: '
                              '${decimal(team.value['goalsAgainst'])}',
                              textAlign: TextAlign.end,
                              style: const TextStyle(color: muted, fontSize: 12))),
                        ]),
                        const SizedBox(height: 10),
                        FormDots(values: team.value['form']),
                      ],
                    )),
                ]),
              );
            },
          ),
        ),
      ]);

  Widget _newsPage() => FutureBuilder<Map<String, dynamic>>(
        future: newsFuture,
        builder: (context, snap) {
          if (snap.hasError) return _error(snap.error);
          if (!snap.hasData) return _loading();
          final articles = asObjects(snap.data!['articles']);
          return RefreshIndicator(
            color: mint,
            onRefresh: _refresh,
            child: ListView(padding: const EdgeInsets.all(15), children: [
              _head(tr(widget.language, 'newsTitle'),
                  'Football Intelligence AI'),
              if (articles.isEmpty)
                Panel(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.newspaper_outlined, color: mint, size: 32),
                    const SizedBox(height: 12),
                    Text(tr(widget.language, 'newsMissing'),
                        style: const TextStyle(fontWeight: FontWeight.w900,
                            fontSize: 18)),
                    const SizedBox(height: 10),
                    Text(tr(widget.language, 'newsInfo'),
                        style: const TextStyle(color: muted)),
                  ],
                )),
              for (final a in articles)
                Panel(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${a['title'] ?? ''}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 17)),
                    const SizedBox(height: 8),
                    Text('${a['description'] ?? ''}',
                        style: const TextStyle(color: muted)),
                    const SizedBox(height: 8),
                    Text(formattedDate(a['publishedAt']),
                        style: const TextStyle(color: mint, fontSize: 11)),
                  ],
                )),
            ]),
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    final labels = [
      tr(widget.language, 'home'),
      tr(widget.language, 'ai'),
      tr(widget.language, 'stats'),
      tr(widget.language, 'news'),
    ];
    final page = tab == 0
        ? _fixturesPage()
        : tab == 1
            ? _aiPage()
            : tab == 2
                ? _statsPage()
                : _newsPage();
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('FOOTBALL INTELLIGENCE',
                style: TextStyle(fontSize: 15,
                    fontWeight: FontWeight.w900)),
            Text('AI MATCH CENTER',
                style: TextStyle(fontSize: 10, color: mint,
                    letterSpacing: 2)),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            tooltip: tr(widget.language, 'selectLang'),
            icon: const Icon(Icons.language, color: mint),
            onSelected: widget.onLanguageChanged,
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'en', child: Text('🇬🇧 English')),
              PopupMenuItem(value: 'bs', child: Text('🇧🇦 Bosanski')),
            ],
          ),
          IconButton(
            tooltip: tr(widget.language, 'retry'),
            onPressed: _refresh,
            icon: const Icon(Icons.refresh, color: mint),
          ),
        ],
      ),
      body: page,
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF0F2232),
        indicatorColor: const Color(0xFF215440),
        selectedIndex: tab,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (index) => setState(() => tab = index),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home, color: mint),
              label: labels[0]),
          NavigationDestination(icon: const Icon(Icons.auto_awesome_outlined),
              selectedIcon: const Icon(Icons.auto_awesome, color: mint),
              label: labels[1]),
          NavigationDestination(icon: const Icon(Icons.bar_chart_outlined),
              selectedIcon: const Icon(Icons.bar_chart, color: mint),
              label: labels[2]),
          NavigationDestination(icon: const Icon(Icons.newspaper_outlined),
              selectedIcon: const Icon(Icons.newspaper, color: mint),
              label: labels[3]),
        ],
      ),
    );
  }
}

class Panel extends StatelessWidget {
  final Widget child;
  const Panel({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: cardBorder),
        ),
        child: child,
      );
}

class Metric extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const Metric({super.key, required this.value, required this.label,
    required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: cardBorder),
        ),
        child: Column(children: [
          Text(value, style: TextStyle(
              color: color, fontSize: 27, fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: muted, fontSize: 11)),
        ]),
      );
}

class TeamBadge extends StatelessWidget {
  final String name;
  final String imageUrl;
  const TeamBadge({super.key, required this.name, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0];
    final fallback = CircleAvatar(
      radius: 24,
      backgroundColor: const Color(0xFF204E46),
      child: Text(initial, style: const TextStyle(
          color: mint, fontSize: 22, fontWeight: FontWeight.w900)),
    );
    if (imageUrl.isEmpty || !imageUrl.startsWith('https://')) {
      return fallback;
    }
    return SizedBox(
      height: 48,
      width: 48,
      child: Image.network(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => fallback,
      ),
    );
  }
}

class MatchTile extends StatelessWidget {
  final Map<String, dynamic> match;
  final String language;
  final VoidCallback onTap;
  const MatchTile({super.key, required this.match,
    required this.language, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = asObject(match['prediction']);
    final result = asObject(p['resultPercent']);
    final a = asNumber(result['home'])?.toDouble() ?? 0;
    final b = asNumber(result['draw'])?.toDouble() ?? 0;
    final c = asNumber(result['away'])?.toDouble() ?? 0;
    final total = a + b + c;
    final home = '${match['home'] ?? '—'}';
    final away = '${match['away'] ?? '—'}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(17),
            child: Column(children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(formattedDate(match['date']),
                    style: const TextStyle(color: muted, fontSize: 12)),
              ),
              const SizedBox(height: 16),
              Row(children: [
                TeamBadge(name: home,
                    imageUrl: '${match['homeCrest'] ?? ''}'),
                const SizedBox(width: 11),
                Expanded(child: Text(home,
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800))),
                const Text('VS', style: TextStyle(color: muted,
                    fontWeight: FontWeight.w800)),
                const SizedBox(width: 11),
                Expanded(child: Text(away, textAlign: TextAlign.end,
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800))),
                const SizedBox(width: 11),
                TeamBadge(name: away,
                    imageUrl: '${match['awayCrest'] ?? ''}'),
              ]),
              const SizedBox(height: 15),
              if (p.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Row(children: [
                    Expanded(flex: total > 0 ? (a * 10).round().clamp(1, 1000).toInt() : 1,
                        child: Container(height: 9, color: mint)),
                    Expanded(flex: total > 0 ? (b * 10).round().clamp(1, 1000).toInt() : 1,
                        child: Container(height: 9, color: yellow)),
                    Expanded(flex: total > 0 ? (c * 10).round().clamp(1, 1000).toInt() : 1,
                        child: Container(height: 9, color: blue)),
                  ]),
                ),
                const SizedBox(height: 9),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _label('1', percent(result['home']), mint),
                      _label('X', percent(result['draw']), yellow),
                      _label('2', percent(result['away']), blue),
                    ]),
              ] else
                Text(tr(language, 'noPrediction'),
                    style: const TextStyle(color: muted, fontSize: 12)),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Text(tr(language, 'details'),
                    style: const TextStyle(color: mint, fontSize: 12)),
                const Icon(Icons.chevron_right, color: mint, size: 18),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _label(String name, String value, Color color) => Row(children: [
        Text('$name ', style: const TextStyle(color: muted, fontSize: 12)),
        Text(value, style: TextStyle(
            fontWeight: FontWeight.w900, color: color, fontSize: 17)),
      ]);
}

class FormDots extends StatelessWidget {
  final dynamic values;
  const FormDots({super.key, required this.values});

  @override
  Widget build(BuildContext context) {
    final form = values is List ? values as List : <dynamic>[];
    if (form.isEmpty) {
      return const Text('—', style: TextStyle(color: muted));
    }
    return Wrap(spacing: 5, children: form.map((e) {
      final result = '$e';
      final color = result == 'P' ? mint
          : result == 'N' ? yellow : const Color(0xFFFF7E88);
      return CircleAvatar(
        radius: 13,
        backgroundColor: color,
        child: Text(result, style: const TextStyle(color: navy,
            fontSize: 11, fontWeight: FontWeight.w900)),
      );
    }).toList());
  }
}

class MatchDetails extends StatelessWidget {
  final Map<String, dynamic> match;
  final String leagueName;
  final String language;
  const MatchDetails({super.key, required this.match,
    required this.leagueName, required this.language});

  Widget _row(String label, dynamic value, {Color color = mint}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          Expanded(child: Text(label, style: const TextStyle(color: muted))),
          Text(percent(value), style: TextStyle(
              color: color, fontSize: 19, fontWeight: FontWeight.w900)),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final p = asObject(match['prediction']);
    final result = asObject(p['resultPercent']);
    final goals = asObject(p['overGoalsPercent']);
    final expected = asObject(p['expectedGoals']);
    final score = asObject(p['mostLikelyScore']);
    final homeStats = asObject(match['homeStats']);
    final awayStats = asObject(match['awayStats']);
    final home = '${match['home'] ?? '—'}';
    final away = '${match['away'] ?? '—'}';
    return Scaffold(
      appBar: AppBar(title: Text(leagueName)),
      body: ListView(padding: const EdgeInsets.all(15), children: [
        Panel(child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            TeamBadge(name: home, imageUrl: '${match['homeCrest'] ?? ''}'),
            const Text('VS', style: TextStyle(color: mint,
                fontSize: 19, fontWeight: FontWeight.w900)),
            TeamBadge(name: away, imageUrl: '${match['awayCrest'] ?? ''}'),
          ]),
          const SizedBox(height: 12),
          Text('$home  –  $away', textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(formattedDate(match['date']),
              style: const TextStyle(color: muted)),
        ])),
        if (p.isEmpty)
          Panel(child: Text(tr(language, 'noPrediction')))
        else ...[
          Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text(tr(language, 'result'), style: const TextStyle(
                color: mint, fontSize: 17, fontWeight: FontWeight.w800)),
            _row(tr(language, 'homeWin'), result['home']),
            _row(tr(language, 'draw'), result['draw'], color: yellow),
            _row(tr(language, 'awayWin'), result['away'], color: blue),
          ])),
          Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text(tr(language, 'goals'), style: const TextStyle(
                color: mint, fontSize: 17, fontWeight: FontWeight.w800)),
            _row('Over 1.5', goals['1.5']),
            _row('Over 2.5', goals['2.5']),
            _row('Over 3.5', goals['3.5']),
            _row(tr(language, 'btts'), p['bothTeamsScorePercent']),
          ])),
          Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text(tr(language, 'xg'), style: const TextStyle(
                color: mint, fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Text('$home: ${decimal(expected['home'])}'),
            Text('$away: ${decimal(expected['away'])}'),
            const SizedBox(height: 5),
            Text('Total: ${decimal(expected['total'])}',
                style: const TextStyle(fontWeight: FontWeight.w900)),
          ])),
          Panel(child: Column(children: [
            Text(tr(language, 'score'),
                style: const TextStyle(color: mint,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Text('${score['home'] ?? '—'} : ${score['away'] ?? '—'}',
                style: const TextStyle(
                    fontSize: 32, fontWeight: FontWeight.w900)),
            Text(percent(score['percent']),
                style: const TextStyle(color: muted)),
          ])),
        ],
        Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Text(tr(language, 'form'), style: const TextStyle(
              color: mint, fontWeight: FontWeight.w900, fontSize: 17)),
          const SizedBox(height: 12),
          Text(home, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          FormDots(values: homeStats['form']),
          const SizedBox(height: 10),
          Text('${tr(language, 'scored')}: '
              '${decimal(homeStats['goalsFor'])}   •   '
              '${tr(language, 'conceded')}: '
              '${decimal(homeStats['goalsAgainst'])}',
              style: const TextStyle(color: muted, fontSize: 12)),
          const Divider(height: 28),
          Text(away, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          FormDots(values: awayStats['form']),
          const SizedBox(height: 10),
          Text('${tr(language, 'scored')}: '
              '${decimal(awayStats['goalsFor'])}   •   '
              '${tr(language, 'conceded')}: '
              '${decimal(awayStats['goalsAgainst'])}',
              style: const TextStyle(color: muted, fontSize: 12)),
        ])),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(tr(language, 'info'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: muted, fontSize: 12)),
        ),
      ]),
    );
  }
}
