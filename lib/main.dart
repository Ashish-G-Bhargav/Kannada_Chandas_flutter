import 'package:flutter/material.dart';

import 'analyzer.dart';
import 'models.dart';

void main() {
  runApp(const ChandasApp());
}

class ChandasApp extends StatelessWidget {
  const ChandasApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFB35A00),
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'Kannada Chandas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: const Color(0xFFFBF7F1),
      ),
      home: const ChandasHomePage(),
    );
  }
}

class ChandasHomePage extends StatefulWidget {
  const ChandasHomePage({super.key});

  @override
  State<ChandasHomePage> createState() => _ChandasHomePageState();
}

class _ChandasHomePageState extends State<ChandasHomePage> {
  final TextEditingController _inputController = TextEditingController();

  ChandasResult? _result;
  bool _isAnalyzing = false;
  String? _error;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isAnalyzing = true;
      _error = null;
    });

    try {
      final data = analyzeTextLocally(text);
      setState(() {
        _result = data;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  void _loadExample(String type) {
    const examples = {
      'kanda':
          'ಕಾವೇರಿಯಿಂದಮಾ ಗೋ\nದಾವರಿವರಮಿರ್ಪನಾಡದಾ ಕನ್ನಡದೊಳ್\nಭಾವಿಸಿದ ಜನಪದಂ ವಸು\nಧಾವಳಯ ವಿಲೀನ ವಿಶದ ವಿಷಯ ವಿಶೇಷಂ',
      'poem':
          'ನೆಲಕಿಟಿವೆನೆಂದು ಬಗೆದಿರೆ\nಚಲಕಿಟಿವೆಂ ಪಾಂಡುಸುತರೋಳೇನಲೆನಿದು ಪಾ||\nಟ್ಟೈಲೆನಗೇ ದಿನಪಸುತನಂ\nಕೊಲಿಸಿದ ನೆಲನೊಡನೆ ಮತ್ತೆ ಪುದುವಾಳ್ವೆಪೇನೇ||,\n\nಎನ್ನಣುಗಾಳನನ್ನಣುಗದಮ್ಮನನಿಕ್ಕಿದ ಪಾರ್ಥಭೀಮರು।\nಳ್ಳನ್ನೆಗಮೊಲ್ಲೆನನ್ನೊಡಲೊಳಿನ್ನಸುವುಳ್ಳಿನಮಜ್ಜ ಸಂಧಿಯಂ||'
    };
    _inputController.text = examples[type] ?? '';
  }

  

  @override
  Widget build(BuildContext context) {
    final stanzas = _result?.stanzas ?? <Stanza>[];

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kannada Chandas'),
            Text(
              'Prosody Analyzer & Identifier',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _inputController,
                        maxLines: 7,
                        decoration: const InputDecoration(
                          labelText: 'Input Text',
                          hintText: 'ಪದ್ಯವನ್ನು ಇಲ್ಲಿ ಬರೆಯಿರಿ...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilledButton.icon(
                            onPressed: _isAnalyzing ? null : _analyze,
                            icon: const Icon(Icons.auto_awesome),
                            label: const Text('Analyze'),
                          ),
                          // OCR disabled for local-only port
                          OutlinedButton(
                            onPressed: () => _loadExample('kanda'),
                            child: const Text('Kanda Example'),
                          ),
                          OutlinedButton(
                            onPressed: () => _loadExample('poem'),
                            child: const Text('Poem Example'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              if (_error != null)
                Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      _error!,
                      style: TextStyle(color: Colors.red.shade900),
                    ),
                  ),
                ),
              if (_isAnalyzing)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (_result != null && !_isAnalyzing)
                Card(
                  color: const Color(0xFF7A3B00),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Analysis Complete',
                                style: TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                              Text(
                                stanzas.length == 1
                                    ? stanzas.first.overallType
                                    : 'Results Ready',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            const SizedBox(height: 6),
                            Text(
                              'Stanzas: ${stanzas.length}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 14),
              for (var s = 0; s < stanzas.length; s++) ...[
                Text(
                  'Stanza ${s + 1}: ${stanzas[s].overallType}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                for (var i = 0; i < stanzas[s].lines.length; i++) ...[
                  _LineCard(index: i + 1, line: stanzas[s].lines[i]),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 12),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

class _LineCard extends StatelessWidget {
  const _LineCard({required this.index, required this.line});

  final int index;
  final LineResult line;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('L$index', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    line.line,
                    style: const TextStyle(fontSize: 17),
                  ),
                ),
                if (line.match != 'Unknown')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      line.match,
                      style: TextStyle(color: Colors.green.shade900, fontSize: 11),
                    ),
                  )
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: line.pattern
                  .map(
                    (p) => Chip(
                      label: Text(p == '-' ? 'G' : 'L'),
                      visualDensity: VisualDensity.compact,
                      backgroundColor:
                          p == '-' ? Colors.red.shade50 : Colors.green.shade50,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),
            Text('Matras: ${line.matras}'),
            Text('Ganas: ${line.ganas}'),
          ],
        ),
      ),
    );
  }
}

// Models live in lib/models.dart and analyzer runs locally.
