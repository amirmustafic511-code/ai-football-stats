import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Football Intelligence AI - premium prototype v6 (five focused screens).
// Only Flutter SDK libraries are used; no pubspec changes are required.
// Predictions are statistical estimates, not guaranteed outcomes.
const apiBase =
    'https://football-intelligence-api.football-intelligence-ai.workers.dev';
const navy = Color(0xFF030E19);
const surface = Color(0xFF0C1C2D);
const cardBorder = Color(0xFF1C3849);
const mint = Color(0xFF22ED83);
const muted = Color(0xFFAFC1D0);
const yellow = Color(0xFFF3C66E);
const blue = Color(0xFF74B8FF);
const electric = Color(0xFF15FF74);
const robotArt = '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';


/// Fallback graphic created by the app; not a photo of a real article.
class FootballNewsArtwork extends StatelessWidget {
  const FootballNewsArtwork({super.key});

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF103E39), Color(0xFF13253E), Color(0xFF081A29)],
          ),
        ),
        child: Stack(children: [
          Positioned.fill(child: CustomPaint(painter: _PitchPainter())),
          const Center(child: Icon(Icons.sports_soccer,
            color: Color(0xBB4CEAB6), size: 77)),
          const Positioned(left: 14, bottom: 12,
            child: Text('FOOTBALL INTELLIGENCE • NEWS',
              style: TextStyle(fontSize: 10, color: Colors.white70,
                fontWeight: FontWeight.w700, letterSpacing: 1.1))),
        ]),
      );
}

class _PitchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0x4464E4B4)
      ..strokeWidth = 1..style = PaintingStyle.stroke;
    final r = Rect.fromLTWH(size.width * .08, size.height * .12,
      size.width * .84, size.height * .76);
    canvas.drawRect(r, p);
    canvas.drawLine(Offset(size.width * .5, r.top),
      Offset(size.width * .5, r.bottom), p);
    canvas.drawCircle(Offset(size.width * .5, size.height * .5),
      size.height * .2, p);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

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
    'featured': 'FEATURED AI MATCH', 'overview': 'League overview',
    'shortcutAI': 'AI analysis', 'shortcutStats': 'Statistics',
    'shortcutNews': 'News', 'viewAll': 'All upcoming fixtures',
    'goalsOver': 'Over 2.5', 'topMatches': 'Next fixtures',
    'noNews': 'News source is not connected yet',
    'newsRegional': 'Bosnian is not available in the provider. Showing original Croatian-language articles.',
    'newsEnglish': 'Original English-language articles. They are not automatically translated.',
    'linkCopy': 'Copy article link', 'linkCopied': 'Article link copied. Open it in your browser.',
    'illustration': 'Illustrative sports graphic',

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
    'featured': 'ISTAKNUTA AI ANALIZA', 'overview': 'Pregled lige',
    'shortcutAI': 'AI analize', 'shortcutStats': 'Statistika',
    'shortcutNews': 'Vijesti', 'viewAll': 'Sve naredne utakmice',
    'goalsOver': 'Više od 2.5', 'topMatches': 'Sljedeće utakmice',
    'noNews': 'Izvor vijesti još nije povezan',
    'newsRegional': 'Izvor ne nudi bosanski jezik. Prikazujemo originalne članke na hrvatskom.',
    'newsEnglish': 'Originalni tekstovi na engleskom; nisu automatski prevedeni.',
    'linkCopy': 'Kopiraj link članka', 'linkCopied': 'Link kopiran. Otvori ga u pregledniku.',
    'illustration': 'Ilustrativna sportska grafika',

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
    newsFuture = getJson('/api/news?lang=${widget.language}');
  }

  @override
  void didUpdateWidget(covariant Dashboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.language != widget.language) {
      setState(() {
        newsFuture = getJson('/api/news?lang=${widget.language}');
      });
    }
  }

  Future<void> _refresh() async {
    setState(_loadAll);
    try {
      await Future.wait([fixturesFuture, picksFuture, newsFuture]);
    } catch (_) { /* Individual screens display errors. */ }
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
        height: 52,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(14, 3, 14, 3),
          itemCount: leagues.length,
          separatorBuilder: (_, __) => const SizedBox(width: 7),
          itemBuilder: (context, i) {
            final l = leagues[i];
            final active = league == l.code;
            return ChoiceChip(
              avatar: active ? const Icon(Icons.check, size: 15, color: navy) : null,
              label: Text(l.name),
              selected: active,
              onSelected: (_) => _setLeague(l.code),
              backgroundColor: surface,
              selectedColor: mint,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              labelStyle: TextStyle(
                fontSize: 12,
                color: active ? navy : Colors.white,
                fontWeight: FontWeight.w800,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: active ? mint : cardBorder),
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

  void _openPicks() => Navigator.push(context, MaterialPageRoute<void>(
      builder: (_) => Scaffold(
        backgroundColor: navy,
        appBar: AppBar(title: Text(widget.language == 'bs'
            ? 'AI Prognoze' : 'AI Predictions')),
        body: _aiPage(),
      )));

  Widget _premiumHome() {
    final bs = widget.language == 'bs';
    return RefreshIndicator(
      color: mint,
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 26),
        children: [
          _heroBanner(bs),
          const SizedBox(height: 13),
          Row(children: [
            Expanded(child: _quickPill(Icons.search, bs ? 'Analiza utakmice' : 'Match analysis',
                () => setState(() => tab = 1))),
            const SizedBox(width: 7),
            Expanded(child: _quickPill(Icons.bar_chart, bs ? 'Forma ekipa' : 'Team form',
                () => setState(() => tab = 2))),
          ]),
          const SizedBox(height: 13),
          Row(children: [
            Expanded(child: _feature(
              Icons.psychology_alt_outlined,
              bs ? 'AI Analitičar' : 'AI Analyst',
              bs ? 'Razgovaraj o fudbalu' : 'Talk football with AI',
              const [Color(0xFF023923), Color(0xFF062016)],
              mint,
              () => setState(() => tab = 3))),
            const SizedBox(width: 10),
            Expanded(child: _feature(
              Icons.track_changes,
              bs ? 'AI Prognoze' : 'AI Predictions',
              bs ? 'Dnevni izbor utakmica' : 'Daily selected matches',
              const [Color(0xFF11255E), Color(0xFF071930)],
              const Color(0xFFB9A3FF),
              _openPicks)),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _feature(
              Icons.bar_chart_rounded,
              bs ? 'AI Statistika' : 'AI Statistics',
              bs ? 'Analize i poređenja' : 'Form and comparisons',
              const [Color(0xFF05374C), Color(0xFF071A2A)],
              const Color(0xFF40D9FF),
              () => setState(() => tab = 2))),
            const SizedBox(width: 10),
            Expanded(child: _feature(
              Icons.article_outlined,
              bs ? 'Vijesti' : 'News',
              bs ? 'Najnovije iz fudbala' : 'Latest football news',
              const [Color(0xFF4E3210), Color(0xFF19142A)],
              yellow,
              () => setState(() => tab = 4))),
          ]),
          const SizedBox(height: 18),
          _sectionHeader('🔥  ${bs ? 'AI Izbor dana' : 'AI Daily Selection'}',
              bs ? 'Prikaži sve' : 'View all', _openPicks),
          const SizedBox(height: 8),
          FutureBuilder<Map<String, dynamic>>(
            future: picksFuture,
            builder: (context, snap) {
              if (snap.hasError) {
                return _infoCard(bs ? 'AI izbor trenutno nije dostupan.'
                  : 'Daily AI selection is unavailable.');
              }
              if (!snap.hasData) return const _ThinLoader();
              final matches = asObjects(snap.data!['matches']);
              if (matches.isEmpty) {
                return _infoCard(bs
                  ? 'Još nema objavljenih prognoza za ovaj mjesec. AI ne izmišlja utakmice.'
                  : 'No published selections yet. We never invent daily picks.');
              }
              return Column(children: [for (final p in matches.take(2)) _premiumPick(p)]);
            }),
          const SizedBox(height: 12),
          FutureBuilder<Map<String, dynamic>>(
            future: picksFuture,
            builder: (context, snap) {
              if (!snap.hasData) return const SizedBox.shrink();
              final d = snap.data!;
              final rate = d['successRate'];
              final won = asNumber(d['won'])?.toInt() ?? 0;
              final lost = asNumber(d['lost'])?.toInt() ?? 0;
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: premiumBox(),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(bs ? '▥ Uspješnost AI prognoza' : '▥ AI prediction record',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: _recordMetric(bs ? 'Ovaj mjesec' : 'This month',
                      rate == null ? '—' : percent(rate), mint)),
                    Expanded(child: _recordMetric(bs ? 'Pogođeno' : 'Correct', '$won', mint)),
                    Expanded(child: _recordMetric(bs ? 'Promašeno' : 'Incorrect', '$lost',
                      const Color(0xFFFF7184))),
                  ]),
                  const SizedBox(height: 8),
                  Text(bs ? 'Samo provjereni završeni mečevi.'
                      : 'Only verified completed matches.',
                      style: const TextStyle(fontSize: 10, color: muted)),
                ]),
              );
            },
          ),
          const SizedBox(height: 20),
          _sectionHeader(bs ? 'Najnovije vijesti' : 'Latest news',
            bs ? 'Prikaži sve' : 'View all', () => setState(() => tab = 4)),
          const SizedBox(height: 9),
          FutureBuilder<Map<String, dynamic>>(
            future: newsFuture,
            builder: (context, snap) {
              if (snap.hasError) return _infoCard(bs ? 'Vijesti nisu dostupne.' : 'News unavailable.');
              if (!snap.hasData) return const _ThinLoader();
              final articles = asObjects(snap.data!['articles']);
              if (articles.isEmpty) return _infoCard(bs ? 'Nema novih vijesti.' : 'No news currently.');
              final a = articles.first;
              final url = '${a['imageUrl'] ?? ''}';
              return GestureDetector(
                onTap: () => setState(() => tab = 4),
                child: Container(
                  decoration: premiumBox(),
                  padding: const EdgeInsets.all(8),
                  child: Row(children: [
                    ClipRRect(borderRadius: BorderRadius.circular(9), child:
                      SizedBox(width: 106, height: 86,
                        child: url.startsWith('https://')
                          ? Image.network(url, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const FootballNewsArtwork())
                          : const FootballNewsArtwork())),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${a['title'] ?? ''}', maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                        const SizedBox(height: 6),
                        Text('${a['source'] ?? ''}  •  ${formattedDate(a['publishedAt'])}',
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 10, color: muted)),
                      ])),
                  ]),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          Text(tr(widget.language, 'attribution'), textAlign: TextAlign.center,
            style: const TextStyle(color: muted, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _heroBanner(bool bs) => Container(
    height: 218,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFF227C68), width: 1.2),
      boxShadow: [BoxShadow(color: mint.withValues(alpha: .13), blurRadius: 22)],
      gradient: const LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xFF073B43), Color(0xFF03111E), Color(0xFF061F2D)],
      ),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(17),
      child: Stack(children: [
        const Positioned.fill(child: CustomPaint(painter: StadiumPatternPainter())),
        Positioned(right: -9, bottom: 0, top: 0, width: 171,
          child: Image.memory(base64Decode(robotArt), fit: BoxFit.cover,
            alignment: Alignment.topCenter)),
        Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [navy.withValues(alpha: .06), navy.withValues(alpha: .0)],
          ),
        ))),
        Positioned(left: 17, top: 22, width: 207,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(bs ? 'Tvoj AI fudbalski' : 'Your AI football',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900,
                shadows: [Shadow(blurRadius: 8, color: Colors.black)])),
            Text(bs ? 'analitičar' : 'analyst',
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900,
                color: mint, shadows: [Shadow(blurRadius: 8, color: Colors.black)])),
            const SizedBox(height: 8),
            Text(bs ? 'Pitaj o utakmicama, formi, statistici i analizama.'
              : 'Explore teams, matches, form and real football data.',
              style: const TextStyle(color: Colors.white, fontSize: 12,
                height: 1.3, shadows: [Shadow(color: Colors.black, blurRadius: 5)])),
          ])),
        Positioned(bottom: 12, left: 12, right: 12,
          child: GestureDetector(
            onTap: () => setState(() => tab = 3),
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xE503291F),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: mint),
                boxShadow: [BoxShadow(color: mint.withValues(alpha: .18), blurRadius: 10)],
              ),
              child: Row(children: [
                const Icon(Icons.chat_bubble_outline, color: mint, size: 19),
                const SizedBox(width: 10),
                Expanded(child: Text(bs ? 'Pitaj AI o bilo kojoj utakmici...'
                    : 'Ask AI about a football match...',
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12))),
                const Icon(Icons.send_rounded, color: mint, size: 21),
              ]),
            ),
          )),
      ]),
    ),
  );

  Widget _quickPill(IconData icon, String title, VoidCallback tap) =>
      InkWell(onTap: tap, borderRadius: BorderRadius.circular(20),
        child: Container(height: 35,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(19),
            color: surface, border: Border.all(color: cardBorder)),
          padding: const EdgeInsets.symmetric(horizontal: 9),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: mint, size: 15),
            const SizedBox(width: 5),
            Flexible(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700))),
          ])));

  Widget _feature(IconData icon, String title, String desc,
      List<Color> colors, Color iconColor, VoidCallback tap) =>
      InkWell(onTap: tap, borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 113,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: iconColor.withValues(alpha: .65)),
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(begin: Alignment.topLeft,
              end: Alignment.bottomRight, colors: colors),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Icon(icon, color: iconColor, size: 25),
              const Icon(Icons.chevron_right, color: Colors.white, size: 20),
            ]),
            const Spacer(),
            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
            Text(desc, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, color: muted)),
          ]),
        ),
      );

  Widget _sectionHeader(String title, String action, VoidCallback tap) =>
      Row(children: [
        Expanded(child: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17))),
        TextButton(onPressed: tap,
          child: Text('$action  ›', style: const TextStyle(color: muted, fontSize: 11))),
      ]);

  Widget _infoCard(String message) => Container(
      padding: const EdgeInsets.all(16), decoration: premiumBox(),
      child: Row(children: [
        const Icon(Icons.info_outline, color: mint, size: 21),
        const SizedBox(width: 10),
        Expanded(child: Text(message, style: const TextStyle(color: muted,
          fontSize: 12))),
      ]));

  Widget _recordMetric(String label, String value, Color color) =>
      Column(children: [
        Text(label, style: const TextStyle(fontSize: 10, color: muted)),
        const SizedBox(height: 3),
        Text(value, style: TextStyle(fontSize: 19,
          fontWeight: FontWeight.w900, color: color)),
      ]);

  Widget _premiumPick(Map<String, dynamic> item) {
    final bs = widget.language == 'bs';
    final status = '${item['status'] ?? 'pending'}';
    final color = status == 'won' ? mint : status == 'lost'
        ? const Color(0xFFFF7184) : yellow;
    final statusIcon = status == 'won' ? Icons.check_circle
        : status == 'lost' ? Icons.cancel : Icons.schedule;
    return GestureDetector(
      onTap: _openPicks,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 7),
        decoration: premiumBox(),
        child: Row(children: [
          const Icon(Icons.sports_soccer, color: mint, size: 21),
          const SizedBox(width: 9),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${item['home'] ?? item['home_team'] ?? '—'}  vs  '
                  '${item['away'] ?? item['away_team'] ?? '—'}',
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
              Text('${item['leagueName'] ?? item['league'] ?? ''} • '
                  '${formattedDate(item['date'] ?? item['kickoff'])}',
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, color: muted)),
            ])),
          const SizedBox(width: 7),
          Column(children: [
            Text(percent(item['probability']),
              style: const TextStyle(color: mint, fontSize: 19,
                fontWeight: FontWeight.w900)),
            Row(children: [
              Icon(statusIcon, size: 13, color: color),
              Text(status == 'won' ? (bs ? 'Pogođeno' : 'Correct') :
                status == 'lost' ? (bs ? 'Promašeno' : 'Incorrect') :
                (bs ? 'Čeka' : 'Pending'),
                style: TextStyle(color: color, fontSize: 9)),
            ]),
          ]),
        ]),
      ),
    );
  }

  Widget _fixturesPage() => Column(children: [
        const SizedBox(height: 7),
        _leagues(),
        const SizedBox(height: 9),
        Expanded(
          child: FutureBuilder<Map<String, dynamic>>(
            future: fixturesFuture,
            builder: (context, snap) {
              if (snap.hasError) return _error(snap.error);
              if (!snap.hasData) return _loading();
              final data = snap.data!;
              final matches = asObjects(data['matches']);
              final leagueName = leagues.firstWhere((l) => l.code == league).name;
              return RefreshIndicator(
                color: mint,
                onRefresh: _refresh,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
                  children: [
                    if (matches.isNotEmpty)
                      SpotlightCard(
                        match: matches.first,
                        league: leagueName,
                        language: widget.language,
                        onTap: () => _openMatch(matches.first),
                      )
                    else
                      Panel(child: Text(tr(widget.language, 'noGames'))),
                    const SizedBox(height: 11),
                    const SizedBox(height: 12),
                    _leagueInfoStrip(data, matches.length, leagueName),
                    const SizedBox(height: 13),
                    _head(tr(widget.language, 'upcoming'),
                        '${matches.length} ${tr(widget.language, 'matches')}'),
                    for (final m in matches.skip(matches.isEmpty ? 0 : 1))
                      CompactFixtureCard(
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
                  ],
                ),
              );
            },
          ),
        ),
      ]);

  Widget _leagueInfoStrip(
    Map<String, dynamic> data, int count, String leagueName,
  ) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF14473A), Color(0xFF12283B)],
      ),
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: const Color(0xFF327461)),
    ),
    child: Row(children: [
      const Icon(Icons.shield_outlined, color: mint, size: 28),
      const SizedBox(width: 9),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(leagueName, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
          Text('${data['finishedMatches'] ?? 0} ${tr(widget.language, 'analyzed')}',
            maxLines: 2, style: const TextStyle(color: muted, fontSize: 10)),
        ],
      )),
      Container(width: 1, height: 29, color: cardBorder),
      const SizedBox(width: 12),
      Column(children: [
        Text('$count', style: const TextStyle(color: mint,
            fontWeight: FontWeight.w900, fontSize: 22)),
        Text(tr(widget.language, 'matches'),
          style: const TextStyle(color: muted, fontSize: 10)),
      ]),
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
          final payload = snap.data!;
          final articles = asObjects(payload['articles']);
          final contentLang = '${payload['contentLanguage'] ?? 'en'}';
          return RefreshIndicator(
            color: mint,
            onRefresh: _refresh,
            child: ListView(padding: const EdgeInsets.all(15), children: [
              _head(tr(widget.language, 'newsTitle'), 'Football Intelligence AI'),
              Panel(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(children: [
                    Icon(Icons.language, size: 18, color: mint),
                    SizedBox(width: 8),
                    Text('Powered by Currents News API',
                      style: TextStyle(color: mint, fontSize: 12,
                        fontWeight: FontWeight.bold)),
                  ]),
                  const SizedBox(height: 8),
                  Text(contentLang == 'hr'
                      ? tr(widget.language, 'newsRegional')
                      : tr(widget.language, 'newsEnglish'),
                    style: const TextStyle(color: muted, fontSize: 12)),
                ],
              )),
              if (articles.isEmpty)
                Panel(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.newspaper_outlined, color: mint, size: 32),
                    const SizedBox(height: 12),
                    Text('${payload['message'] ?? tr(widget.language, 'newsMissing')}',
                      style: const TextStyle(fontWeight: FontWeight.w900,
                        fontSize: 18)),
                  ],
                )),
              for (final a in articles)
                Panel(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // A football illustration is shown when the publisher does
                    // not supply an image. Images in a public release must be
                    // reviewed for publisher usage rights.
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox(
                        width: double.infinity,
                        height: 156,
                        child: Builder(builder: (_) {
                          final image = '${a['imageUrl'] ?? ''}';
                          if (!image.startsWith('https://')) {
                            return const FootballNewsArtwork();
                          }
                          return Image.network(
                            image,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                              const FootballNewsArtwork(),
                            loadingBuilder: (context, child, progress) =>
                              progress == null ? child : const FootballNewsArtwork(),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('${a['title'] ?? ''}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 17)),
                    const SizedBox(height: 8),
                    Text('${a['description'] ?? ''}',
                      style: const TextStyle(color: muted)),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: Text('${a['source'] ?? ''}',
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: mint, fontSize: 11))),
                      Text(formattedDate(a['publishedAt']),
                        style: const TextStyle(color: muted, fontSize: 11)),
                    ]),
                    const SizedBox(height: 6),
                    Align(alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        icon: const Icon(Icons.link, size: 16),
                        label: Text(tr(widget.language, 'linkCopy')),
                        onPressed: () async {
                          await Clipboard.setData(
                            ClipboardData(text: '${a['url'] ?? ''}'));
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(
                              tr(widget.language, 'linkCopied'))));
                        },
                      ),
                    ),
                  ],
                )),
            ]),
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    final bs = widget.language == 'bs';
    final names = bs
      ? ['Početna', 'Utakmice', 'Statistika', 'AI Chat', 'Vijesti']
      : ['Home', 'Matches', 'Statistics', 'AI Chat', 'News'];
    final page = tab == 0 ? _premiumHome()
      : tab == 1 ? _fixturesPage()
      : tab == 2 ? _statsPage()
      : tab == 3 ? AiChatScreen(language: widget.language)
      : _newsPage();
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 71,
        titleSpacing: 10,
        title: Row(children: [
          Container(width: 43, height: 43,
            decoration: BoxDecoration(shape: BoxShape.circle,
              border: Border.all(color: electric, width: 2),
              boxShadow: [BoxShadow(color: electric.withValues(alpha: .23),
                blurRadius: 12)]),
            child: const Icon(Icons.sports_soccer, color: Colors.white, size: 27)),
          const SizedBox(width: 9),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Football', style: TextStyle(fontSize: 21,
                fontWeight: FontWeight.w900, height: 1.0)),
              Text('Intelligence AI', style: TextStyle(color: mint,
                fontSize: 17, fontWeight: FontWeight.w900, height: 1.1)),
              Text('AI FOOTBALL ANALYST', style: TextStyle(fontSize: 9,
                color: muted, letterSpacing: 1.0)),
            ])),
        ]),
        actions: [
          PopupMenuButton<String>(
            tooltip: bs ? 'Jezik' : 'Language',
            icon: const Icon(Icons.language, color: mint),
            onSelected: widget.onLanguageChanged,
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'en', child: Text('🇬🇧 English')),
              PopupMenuItem(value: 'bs', child: Text('🇧🇦 Bosanski')),
            ]),
          IconButton(onPressed: _refresh,
            tooltip: bs ? 'Osvježi' : 'Refresh',
            icon: const Icon(Icons.refresh, color: Colors.white)),
        ],
      ),
      body: page,
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF04111E),
        indicatorColor: const Color(0xFF0A3A29),
        selectedIndex: tab,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 73,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home, color: mint), label: names[0]),
          NavigationDestination(icon: const Icon(Icons.sports_soccer_outlined),
            selectedIcon: const Icon(Icons.sports_soccer, color: mint), label: names[1]),
          NavigationDestination(icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart, color: mint), label: names[2]),
          NavigationDestination(icon: const Icon(Icons.psychology_outlined),
            selectedIcon: const Icon(Icons.psychology, color: mint), label: names[3]),
          NavigationDestination(icon: const Icon(Icons.article_outlined),
            selectedIcon: const Icon(Icons.article, color: mint), label: names[4]),
        ],
      ),
    );
  }

}


BoxDecoration premiumBox() => BoxDecoration(
  color: const Color(0xFF091B2B),
  borderRadius: BorderRadius.circular(16),
  border: Border.all(color: const Color(0xFF254154)),
);

class _ThinLoader extends StatelessWidget {
  const _ThinLoader();
  @override Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 14),
    child: LinearProgressIndicator(color: mint, backgroundColor: surface));
}

/// AI answers are generated by Workers AI and grounded in football-data.org
/// match data. No fabricated local chatbot replies are displayed.
class AiChatScreen extends StatefulWidget {
  final String language;
  const AiChatScreen({super.key, required this.language});
  @override State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final controller = TextEditingController();
  final scroll = ScrollController();
  final messages = <({bool isUser, String text})>[];
  bool waiting = false;
  @override void dispose() { controller.dispose(); scroll.dispose(); super.dispose(); }

  Future<void> send([String? shortcut]) async {
    final text = (shortcut ?? controller.text).trim();
    if (text.isEmpty || waiting) return;
    setState(() {
      messages.add((isUser: true, text: text));
      waiting = true;
      controller.clear();
    });
    try {
      final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
      try {
        final req = await client.postUrl(Uri.parse('$apiBase/api/ai-chat'));
        req.headers.contentType = ContentType.json;
        req.add(utf8.encode(jsonEncode({'question': text, 'language': widget.language})));
        final resp = await req.close().timeout(const Duration(seconds: 45));
        final raw = await utf8.decoder.bind(resp).join().timeout(
          const Duration(seconds: 45));
        final parsed = asObject(jsonDecode(raw));
        if (resp.statusCode != 200 || parsed['error'] != null) {
          throw Exception('${parsed['error'] ?? 'HTTP ${resp.statusCode}'}');
        }
        final answer = '${parsed['answer'] ?? ''}'.trim();
        if (answer.isEmpty) throw Exception('Empty AI response');
        if (!mounted) return;
        setState(() => messages.add((isUser: false, text: answer)));
      } finally { client.close(force: true); }
    } catch (e) {
      if (!mounted) return;
      setState(() => messages.add((isUser: false,
        text: widget.language == 'bs'
          ? 'AI trenutno nije dostupan. Provjeri internet ili AI vezu na serveru. ($e)'
          : 'AI is temporarily unavailable. Check the server AI binding. ($e)')));
    } finally {
      if (mounted) setState(() => waiting = false);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scroll.hasClients) scroll.animateTo(scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    });
  }

  @override Widget build(BuildContext context) {
    final bs = widget.language == 'bs';
    return Column(children: [
      Expanded(child: ListView(controller: scroll,
        padding: const EdgeInsets.all(14), children: [
        Container(padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(17),
            gradient: const LinearGradient(colors: [Color(0xFF07372A), navy]),
            border: Border.all(color: mint.withValues(alpha: .5))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.psychology_alt, size: 34, color: mint),
            const SizedBox(height: 8),
            Text(bs ? 'Tvoj AI fudbalski analitičar' : 'Your AI football analyst',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 7),
            Text(bs ? 'Postavi pitanje o ligi, formi i mečevima. AI odgovara na osnovu dostupnih stvarnih podataka.'
              : 'Ask about leagues, fixtures and team form. Answers use available real data.',
              style: const TextStyle(color: muted, fontSize: 12)),
          ])),
        const SizedBox(height: 13),
        if (messages.isEmpty) ...[
          _suggestion(bs ? 'Analiziraj Manchester City – Fulham' : 'Analyze Manchester City vs Fulham'),
          _suggestion(bs ? 'Kakva je forma Real Madrida?' : 'How is Real Madrid performing?'),
          _suggestion(bs ? 'Objasni šta znači xG' : 'Explain expected goals (xG)'),
        ],
        for (final msg in messages)
          Align(alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 335),
              margin: const EdgeInsets.only(bottom: 9),
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: msg.isUser ? const Color(0xFF064C35) : surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: msg.isUser ? mint : cardBorder)),
              child: SelectableText(msg.text,
                style: const TextStyle(height: 1.45, fontSize: 13)))),
        if (waiting) const Row(children: [
          SizedBox(width: 22, height: 22,
            child: CircularProgressIndicator(strokeWidth: 2, color: mint)),
          SizedBox(width: 9),
          Text('AI...', style: TextStyle(color: muted)),
        ]),
      ])),
      Container(padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
        decoration: const BoxDecoration(color: Color(0xFF061827),
          border: Border(top: BorderSide(color: cardBorder))),
        child: Row(children: [
          Expanded(child: TextField(
            controller: controller, enabled: !waiting,
            minLines: 1, maxLines: 3,
            onSubmitted: (_) => send(),
            textInputAction: TextInputAction.send,
            decoration: InputDecoration(
              hintText: bs ? 'Pitaj o fudbalu...' : 'Ask about football...',
              hintStyle: const TextStyle(color: muted),
              filled: true, fillColor: surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: cardBorder),
                borderRadius: BorderRadius.circular(15)),
            ),
          )),
          const SizedBox(width: 9),
          IconButton.filled(onPressed: waiting ? null : () => send(),
            style: IconButton.styleFrom(backgroundColor: mint,
              foregroundColor: navy),
            icon: const Icon(Icons.send_rounded)),
        ])),
      Padding(padding: const EdgeInsets.only(bottom: 5),
        child: Text(bs ? 'AI može pogriješiti. Provjeri važne podatke.'
          : 'AI may make mistakes. Verify important claims.',
          style: const TextStyle(fontSize: 10, color: muted))),
    ]);
  }
  Widget _suggestion(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: OutlinedButton.icon(onPressed: () => send(text),
      icon: const Icon(Icons.auto_awesome, color: mint, size: 17),
      label: Text(text, maxLines: 2, style: const TextStyle(fontSize: 12)),
      style: OutlinedButton.styleFrom(foregroundColor: Colors.white,
        side: const BorderSide(color: cardBorder),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(12))),
  );
}

class SpotlightCard extends StatelessWidget {
  final Map<String, dynamic> match;
  final String league;
  final String language;
  final VoidCallback onTap;
  const SpotlightCard({super.key, required this.match,
    required this.league, required this.language, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final prediction = asObject(match['prediction']);
    final result = asObject(prediction['resultPercent']);
    final goals = asObject(prediction['overGoalsPercent']);
    final expected = asObject(prediction['expectedGoals']);
    final home = '${match['home'] ?? '—'}';
    final away = '${match['away'] ?? '—'}';
    final a = (asNumber(result['home']) ?? 0).toDouble();
    final b = (asNumber(result['draw']) ?? 0).toDouble();
    final c = (asNumber(result['away']) ?? 0).toDouble();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(23),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFF153C46), Color(0xFF071A2A), Color(0xFF0C3F36)],
            ),
            borderRadius: BorderRadius.circular(23),
            border: Border.all(color: const Color(0xFF2C9F7A), width: 1.2),
            boxShadow: [BoxShadow(color: mint.withValues(alpha: .09),
              blurRadius: 20, offset: const Offset(0, 5))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(children: [
              const Positioned.fill(child: CustomPaint(
                painter: StadiumPatternPainter())),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 15, 15, 17),
                child: Column(children: [
                  Row(children: [
                    Expanded(child: Text('$league  •  ${formattedDate(match['date'])}',
                      maxLines: 2,
                      style: const TextStyle(color: muted, fontSize: 11,
                        fontWeight: FontWeight.w600))),
                    const SizedBox(width: 8),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xFF104535),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: mint),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.memory, color: mint, size: 13),
                          SizedBox(width: 4),
                          Text('AI', style: TextStyle(color: mint,
                            fontSize: 11, fontWeight: FontWeight.w900)),
                        ]),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                    Expanded(child: _team(home, '${match['homeCrest'] ?? ''}')),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Text('VS', style: TextStyle(color: mint,
                        fontSize: 22, fontWeight: FontWeight.w900)),
                    ),
                    Expanded(child: _team(away, '${match['awayCrest'] ?? ''}')),
                  ]),
                  const SizedBox(height: 17),
                  Container(height: 1, color: Colors.white12),
                  const SizedBox(height: 13),
                  Row(children: [
                    Expanded(child: _prob('1', result['home'], mint)),
                    Expanded(child: _prob('X', result['draw'], yellow)),
                    Expanded(child: _prob('2', result['away'], blue)),
                  ]),
                  const SizedBox(height: 10),
                  ProbabilityBar(home: a, draw: b, away: c, height: 10),
                  const SizedBox(height: 17),
                  Row(children: [
                    Expanded(child: _miniStat(Icons.sports_soccer,
                      tr(language, 'goalsOver'), percent(goals['2.5']))),
                    const SizedBox(width: 5),
                    Expanded(child: _miniStat(Icons.groups_2_outlined,
                      'BTTS', percent(prediction['bothTeamsScorePercent']))),
                    const SizedBox(width: 5),
                    Expanded(child: _miniStat(Icons.bar_chart,
                      'xG', decimal(expected['total']))),
                  ]),
                  const SizedBox(height: 14),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Text(tr(language, 'details'),
                      style: const TextStyle(color: mint,
                        fontSize: 12, fontWeight: FontWeight.w800)),
                    const Icon(Icons.chevron_right, color: mint, size: 20),
                  ]),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _team(String name, String crest) => Column(children: [
    TeamBadge(name: name, imageUrl: crest),
    const SizedBox(height: 10),
    Text(name, maxLines: 2, overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center, softWrap: true,
      style: const TextStyle(fontWeight: FontWeight.w900,
        fontSize: 13, height: 1.2)),
  ]);

  Widget _prob(String tag, dynamic value, Color color) => Column(children: [
    Text(tag, style: const TextStyle(color: muted, fontSize: 11)),
    const SizedBox(height: 3),
    Text(percent(value), style: TextStyle(fontSize: 25,
      color: color, fontWeight: FontWeight.w900)),
  ]);

  Widget _miniStat(IconData icon, String label, String value) => Container(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 3),
    decoration: BoxDecoration(
      color: const Color(0xD0112C35),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFF32665D)),
    ),
    child: Column(children: [
      Icon(icon, size: 18, color: mint),
      const SizedBox(height: 4),
      Text(label, textAlign: TextAlign.center,
        maxLines: 1, overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: muted, fontSize: 10)),
      Text(value, style: const TextStyle(color: mint,
        fontSize: 16, fontWeight: FontWeight.w900)),
    ]),
  );
}

class StadiumPatternPainter extends CustomPainter {
  const StadiumPatternPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final outline = Paint()
      ..color = const Color(0x3353FBC4)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawOval(Rect.fromCenter(
      center: Offset(size.width / 2, size.height * .51),
      width: size.width * 1.35, height: size.height * .43), outline);
    canvas.drawOval(Rect.fromCenter(
      center: Offset(size.width / 2, size.height * .49),
      width: size.width * 1.11, height: size.height * .29), outline);
    final paint = Paint()..color = const Color(0x2654DDB2)
      ..strokeWidth = 1.0;
    for (var i = 0; i < 17; i++) {
      final x = size.width * i / 16;
      canvas.drawLine(Offset(x, size.height * .36),
        Offset(size.width / 2 + (x - size.width/2) * .55,
          size.height * .64), paint);
    }
    final shine = Paint()
      ..shader = RadialGradient(
        colors: [mint.withValues(alpha: .20), Colors.transparent],
      ).createShader(Rect.fromLTWH(size.width * .4, 0,
        size.width * .6, size.height * .55));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), shine);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ProbabilityBar extends StatelessWidget {
  final double home, draw, away;
  final double height;
  const ProbabilityBar({super.key,
    required this.home, required this.draw, required this.away,
    this.height = 8});
  @override
  Widget build(BuildContext context) {
    final total = home + draw + away;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Row(children: [
        Expanded(flex: total == 0 ? 1 : (home * 10).round().clamp(1, 1000).toInt(),
          child: Container(height: height, color: mint)),
        Expanded(flex: total == 0 ? 1 : (draw * 10).round().clamp(1, 1000).toInt(),
          child: Container(height: height, color: yellow)),
        Expanded(flex: total == 0 ? 1 : (away * 10).round().clamp(1, 1000).toInt(),
          child: Container(height: height, color: blue)),
      ]),
    );
  }
}

class CompactFixtureCard extends StatelessWidget {
  final Map<String, dynamic> match;
  final String language;
  final VoidCallback onTap;
  const CompactFixtureCard({super.key,
    required this.match, required this.language, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = asObject(match['prediction']);
    final results = asObject(p['resultPercent']);
    final home = '${match['home'] ?? '—'}';
    final away = '${match['away'] ?? '—'}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Material(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
            decoration: BoxDecoration(
              border: Border.all(color: cardBorder),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(children: [
              Row(children: [
                const Icon(Icons.calendar_today_outlined,
                  size: 13, color: mint),
                const SizedBox(width: 5),
                Text(formattedDate(match['date']),
                  style: const TextStyle(color: muted, fontSize: 11)),
                const Spacer(),
                const Icon(Icons.chevron_right, size: 20, color: mint),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                SizedBox(width: 32, height: 32,
                  child: FittedBox(child: TeamBadge(name: home,
                    imageUrl: '${match['homeCrest'] ?? ''}'))),
                const SizedBox(width: 10),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(home, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13,
                        fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(away, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13,
                        fontWeight: FontWeight.w800)),
                  ],
                )),
                const SizedBox(width: 9),
                Column(crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('1   ${percent(results['home'])}',
                      style: const TextStyle(color: mint,
                        fontWeight: FontWeight.w800, fontSize: 12)),
                    Text('X   ${percent(results['draw'])}',
                      style: const TextStyle(color: yellow, fontSize: 11)),
                    Text('2   ${percent(results['away'])}',
                      style: const TextStyle(color: blue, fontSize: 11)),
                  ],
                ),
              ]),
            ]),
          ),
        ),
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
  final String language;
  final String leagueName;
  const MatchDetails({super.key, required this.match,
    required this.language, required this.leagueName});

  Widget _pbox(String title, dynamic value, {Color color = mint}) =>
    Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 3),
      decoration: premiumBox(),
      child: Column(children: [
        Text(title, style: const TextStyle(color: muted, fontSize: 11)),
        const SizedBox(height: 5),
        Text(percent(value), style: TextStyle(color: color,
          fontSize: 24, fontWeight: FontWeight.w900)),
      ])));

  Widget _reason(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Icon(Icons.check_circle, color: mint, size: 18),
      const SizedBox(width: 9),
      Expanded(child: Text(text, style: const TextStyle(fontSize: 12, height: 1.3))),
    ]));

  @override Widget build(BuildContext context) {
    final bs = language == 'bs';
    final home = '${match['home'] ?? '—'}';
    final away = '${match['away'] ?? '—'}';
    final pred = asObject(match['prediction']);
    final result = asObject(pred['resultPercent']);
    final goals = asObject(pred['overGoalsPercent']);
    final expected = asObject(pred['expectedGoals']);
    final score = asObject(pred['mostLikelyScore']);
    final h = asObject(match['homeStats']);
    final a = asObject(match['awayStats']);
    final homeP = asNumber(result['home']) ?? 0;
    final drawP = asNumber(result['draw']) ?? 0;
    final awayP = asNumber(result['away']) ?? 0;
    final values = [homeP, drawP, awayP];
    final biggest = values.reduce((x, y) => x > y ? x : y);
    final best = biggest == homeP ? (bs ? 'Pobjeda domaćina' : 'Home victory')
      : biggest == awayP ? (bs ? 'Pobjeda gosta' : 'Away victory')
      : (bs ? 'Neriješeno' : 'Draw');
    final hGF = asNumber(h['goalsFor']);
    final aGF = asNumber(a['goalsFor']);
    final hGA = asNumber(h['goalsAgainst']);
    final aGA = asNumber(a['goalsAgainst']);
    final facts = <String>[];
    if (hGF != null && aGF != null) {
      facts.add('$home: ${decimal(hGF)} ${bs ? 'golova po meču' : 'goals / match'}; '
        '$away: ${decimal(aGF)}.');
    }
    if (hGA != null && aGA != null) {
      facts.add('$home: ${decimal(hGA)} ${bs ? 'primljenih po meču' : 'conceded / match'}; '
        '$away: ${decimal(aGA)}.');
    }
    if (expected.isNotEmpty) {
      facts.add('${bs ? 'Očekivani golovi modela' : 'Model expected goals'}: '
        '$home ${decimal(expected['home'])}, '
        '$away ${decimal(expected['away'])}.');
    }
    return Scaffold(
      backgroundColor: navy,
      appBar: AppBar(title: Text(bs ? 'AI Analiza utakmice' : 'AI Match Analysis',
        style: const TextStyle(fontWeight: FontWeight.w900))),
      body: ListView(padding: const EdgeInsets.all(12), children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: cardBorder),
            gradient: const LinearGradient(colors: [Color(0xFF062E43), navy]),
          ),
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 16),
          child: Stack(children: [
            const Positioned.fill(child: CustomPaint(painter: StadiumPatternPainter())),
            Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(leagueName, style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 13)),
                Text(formattedDate(match['date']),
                  style: const TextStyle(color: muted, fontSize: 11)),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: TeamBadge(name: home,
                  imageUrl: '${match['homeCrest'] ?? ''}')),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 3),
                  child: Text('VS', style: TextStyle(fontWeight: FontWeight.w900,
                    fontSize: 24, color: mint))),
                Expanded(child: TeamBadge(name: away,
                  imageUrl: '${match['awayCrest'] ?? ''}')),
              ]),
            ]),
          ]),
        ),
        const SizedBox(height: 11),
        if (pred.isEmpty)
          Panel(child: Text(tr(language,'noPrediction')))
        else ...[
          Container(padding: const EdgeInsets.all(15), decoration: premiumBox(),
            child: Row(children: [
              SizedBox(height: 90, width: 90,
                child: Stack(alignment: Alignment.center, children: [
                  SizedBox(height: 90, width: 90, child: CircularProgressIndicator(
                    value: biggest.toDouble() / 100,
                    strokeWidth: 10, color: mint, backgroundColor: cardBorder)),
                  Text(percent(biggest), style: const TextStyle(
                    fontSize: 23, fontWeight: FontWeight.w900)),
                ])),
              const SizedBox(width: 15),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(bs ? 'AI STATISTIČKA PROGNOZA' : 'AI STATISTICAL FORECAST',
                    style: const TextStyle(fontSize: 10, color: muted)),
                  const SizedBox(height: 6),
                  Text(best, style: const TextStyle(color: mint,
                    fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 5),
                  Text(bs ? 'Procjena modela • Nije garancija'
                    : 'Model estimate • Not guaranteed',
                    style: const TextStyle(fontSize: 10, color: muted)),
                ])),
            ])),
          const SizedBox(height: 10),
          Row(children: [
            _pbox('1', homeP), const SizedBox(width: 7),
            _pbox('X', drawP, color: yellow), const SizedBox(width: 7),
            _pbox('2', awayP, color: blue),
          ]),
          const SizedBox(height: 12),
          Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(bs ? '◎ Zašto ovakva prognoza?' : '◎ Why this estimate?',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              if (facts.isEmpty) Text(tr(language,'noPrediction'),
                style: const TextStyle(color: muted)),
              for (final fact in facts) _reason(fact),
              const SizedBox(height: 6),
              Text(bs ? 'Ovo su statistički faktori, ne automatski potvrđene vijesti o ekipi.'
                : 'These are model factors, not verified team news.',
                style: const TextStyle(color: muted, fontSize: 10)),
            ])),
          Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(bs ? '◎ Najvjerovatniji rezultat' : '◎ Most likely score',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              const SizedBox(height: 13),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _scoreTile('${score['home'] ?? '—'} : ${score['away'] ?? '—'}',
                  percent(score['percent'])),
                _scoreTile('${decimal(expected['home'])} xG', home),
                _scoreTile('${decimal(expected['away'])} xG', away),
              ]),
            ])),
        ],
        Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(bs ? '▥ Forma ekipa (zadnjih 5)' : '▥ Team form (last 5)',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 13),
          Row(children: [
            Expanded(child: Text(home, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            FormDots(values: h['form']),
          ]),
          const Divider(height: 22, color: cardBorder),
          Row(children: [
            Expanded(child: Text(away, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            FormDots(values: a['form']),
          ]),
        ])),
        Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(bs ? '▥ Ključni podaci' : '▥ Key data',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 12),
          _statRow(bs ? 'Postignuti golovi / meč' : 'Goals scored / match',
            decimal(hGF), decimal(aGF)),
          _statRow(bs ? 'Primljeni golovi / meč' : 'Goals conceded / match',
            decimal(hGA), decimal(aGA)),
          _statRow('BTTS', percent(pred['bothTeamsScorePercent']), '—'),
          _statRow(bs ? 'Više od 2.5 golova' : 'Over 2.5 goals',
            percent(goals['2.5']), '—'),
        ])),
        Padding(padding: const EdgeInsets.all(14),
          child: Text(tr(language,'info'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: muted, fontSize: 11))),
      ]),
    );
  }
  Widget _scoreTile(String score, String label) => Expanded(
    child: Column(children: [
      Text(score, style: const TextStyle(color: mint,
        fontSize: 15, fontWeight: FontWeight.w900)),
      const SizedBox(height: 4),
      Text(label, maxLines: 2, overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: const TextStyle(color: muted, fontSize: 10)),
    ]));
  Widget _statRow(String title, String h, String a) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(children: [
      SizedBox(width: 65, child: Text(h,
        style: const TextStyle(color: mint, fontWeight: FontWeight.bold))),
      Expanded(child: Text(title, textAlign: TextAlign.center,
        style: const TextStyle(color: muted, fontSize: 11))),
      SizedBox(width: 65, child: Text(a, textAlign: TextAlign.end,
        style: const TextStyle(fontWeight: FontWeight.bold))),
    ]));
}
