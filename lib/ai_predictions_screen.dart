
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

class AiPredictionsScreen extends StatefulWidget {
  const AiPredictionsScreen({super.key});

  @override
  State<AiPredictionsScreen> createState() =>
      _AiPredictionsScreenState();
}

class _AiPredictionsScreenState
    extends State<AiPredictionsScreen> {
  static const String apiUrl =
      'https://football-intelligence-api.football-intelligence-ai.workers.dev/test';

  static const Color green = Color(0xFF37DF91);
  static const Color panel = Color(0xFF1D2C3A);

  late Future<Map<String, dynamic>> data;

  @override
  void initState() {
    super.initState();
    data = loadPrediction();
  }

  Future<Map<String, dynamic>> loadPrediction() async {
    final client = HttpClient();

    try {
      final request =
          await client.getUrl(Uri.parse(apiUrl));

      final response = await request.close();

      final body =
          await utf8.decoder.bind(response).join();

      final decoded = jsonDecode(body);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException(
          'Neispravan odgovor servera.',
        );
      }

      if (response.statusCode != 200 ||
          decoded['error'] != null) {
        throw Exception(
          decoded['error'] ?? 'Server nije dostupan.',
        );
      }

      return decoded;
    } finally {
      client.close(force: true);
    }
  }

  void refresh() {
    setState(() {
      data = loadPrediction();
    });
  }

  Map<String, dynamic> object(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    return <String, dynamic>{};
  }

  String percentage(dynamic value) {
    if (value is num) {
      return '${value.round()}%';
    }
    return '—';
  }

  Widget line(String label, dynamic value) {
    final amount =
        value is num ? value.toDouble() : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
              Text(
                percentage(value),
                style: const TextStyle(
                  color: green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          LinearProgressIndicator(
            value: (amount / 100)
                .clamp(0.0, 1.0)
                .toDouble(),
            minHeight: 7,
            color: green,
            backgroundColor:
                const Color(0xFF35475A),
          ),
        ],
      ),
    );
  }

  Widget panelBox(String title, Widget child) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: green,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C1622),
      appBar: AppBar(
        backgroundColor: const Color(0xFF152735),
        title: const Text('Football Intelligence AI'),
        actions: [
          IconButton(
            onPressed: refresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Osvježi',
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: data,
        builder: (context, snapshot) {
          if (snapshot.connectionState !=
              ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(
                color: green,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Nije moguće učitati analizu.\n'
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final info =
              snapshot.data ?? <String, dynamic>{};

          final match = object(info['match']);

          if (match.isEmpty) {
            return Center(
              child: Text(
                '${info['message'] ?? 'Nema prognoze.'}',
              ),
            );
          }

          final result =
              object(info['resultPercent']);

          final goals =
              object(info['overGoalsPercent']);

          final expected =
              object(info['expectedGoals']);

          final score =
              object(info['mostLikelyScore']);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'AI ANALIZA UTAKMICE',
                style: TextStyle(
                  color: green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${match['home']} – ${match['away']}',
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),
              panelBox(
                'Vjerovatnoća ishoda',
                Column(
                  children: [
                    line(
                      'Pobjeda domaćina',
                      result['home'],
                    ),
                    line(
                      'Neriješeno',
                      result['draw'],
                    ),
                    line(
                      'Pobjeda gosta',
                      result['away'],
                    ),
                  ],
                ),
              ),
              panelBox(
                'Prognoza golova',
                Column(
                  children: [
                    line(
                      'Više od 1,5 golova',
                      goals['1.5'],
                    ),
                    line(
                      'Više od 2,5 golova',
                      goals['2.5'],
                    ),
                    line(
                      'Više od 3,5 golova',
                      goals['3.5'],
                    ),
                    line(
                      'Oba tima daju gol',
                      info['bothTeamsScorePercent'],
                    ),
                  ],
                ),
              ),
              panelBox(
                'Očekivani golovi',
                Text(
                  '${expected['home']} + '
                  '${expected['away']} = '
                  '${expected['total']}',
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              panelBox(
                'Najvjerovatniji rezultat',
                Text(
                  '${score['home']} : ${score['away']} '
                  '(${percentage(score['percent'])})',
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Text(
                'Statistička procjena, '
                'nije garancija ishoda.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
