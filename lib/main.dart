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
    const primaryColor = Color(0xFFB35A00);
    const backgroundColor = Color(0xFFFBF7F1);
    const headerColor = Color(0xFF8B4513);
    
    final scheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'Kannada Chandas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme.copyWith(
          primary: primaryColor,
          secondary: headerColor,
        ),
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
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
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kannada Chandas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Prosody Analyzer & Identifier',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 20,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Input Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'INPUT TEXT',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF8B4513),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _inputController,
                        maxLines: 6,
                        decoration: InputDecoration(
                          hintText: 'ಪದ್ಯವನ್ನು ಇಲ್ಲಿ ಬರೆಯಿರಿ... (Paste your Kannada poem here)',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFB35A00),
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilledButton.icon(
                            onPressed: _isAnalyzing ? null : _analyze,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFB35A00),
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 16 : 24,
                                vertical: 12,
                              ),
                            ),
                            icon: const Icon(Icons.auto_awesome),
                            label: const Text('Analyze'),
                          ),
                          OutlinedButton(
                            onPressed: () => _loadExample('kanda'),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFB35A00)),
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 12 : 16,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              'Kanda Padya',
                              style: TextStyle(color: Color(0xFFB35A00)),
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () => _loadExample('poem'),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFB35A00)),
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 12 : 16,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              'Full Poem',
                              style: TextStyle(color: Color(0xFFB35A00)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),

              // Error Message
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _error!,
                    style: TextStyle(color: Colors.red.shade900),
                  ),
                ),

              // Loading Indicator
              if (_isAnalyzing)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                ),

              // Results Header
              if (_result != null && !_isAnalyzing) ...[
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B4513),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ANALYSIS COMPLETE',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        stanzas.length == 1
                            ? stanzas.first.overallType
                            : 'Results Ready',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'STANZAS: ${stanzas.length}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Stanzas
                for (var s = 0; s < stanzas.length; s++) ...[
                  Text(
                    'Stanza ${s + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFF8B4513),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stanzas[s].overallType,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Color(0xFFB35A00),
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (var i = 0; i < stanzas[s].lines.length; i++) ...[
                    _LineCard(
                      index: i + 1,
                      line: stanzas[s].lines[i],
                      isMobile: isMobile,
                    ),
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 16),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LineCard extends StatelessWidget {
  const _LineCard({
    required this.index,
    required this.line,
    this.isMobile = true,
  });

  final int index;
  final LineResult line;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Line header with index and text
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2C),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      '$index',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    line.line,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2C2C2C),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Pattern chips (Ganas visualization)
            Text(
              '${line.matras} Matras',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFFB35A00),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: line.pattern
                  .map(
                    (p) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: p == '-'
                            ? const Color(0xFFFEE4D1)
                            : const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: p == '-'
                              ? const Color(0xFFDDBB96)
                              : const Color(0xFFA8D5BA),
                        ),
                      ),
                      child: Text(
                        p == '-' ? 'G' : 'L',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: p == '-'
                              ? const Color(0xFFB35A00)
                              : const Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            
            // Ganas info
            if (line.ganas.isNotEmpty)
              Text(
                'GANAS: ${line.ganas}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF666666),
                  letterSpacing: 0.3,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Models live in lib/models.dart and analyzer runs locally.
