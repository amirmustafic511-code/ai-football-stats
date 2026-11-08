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
