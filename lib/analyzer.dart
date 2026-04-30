import 'models.dart';

class KannadaChandasIdentifier {
  KannadaChandasIdentifier() {
    LAGHU = 'U';
    GURU = '-';
  }

  late final String LAGHU;
  late final String GURU;
  final Set<String> VOWELS_SHORT = {'ಅ', 'ಇ', 'ಉ', 'ಋ', 'ಎ', 'ಒ'};
  final Set<String> VOWELS_LONG = {'ಆ', 'ಈ', 'ಊ', 'ಏ', 'ಐ', 'ಓ', 'ಔ', 'ೠ', 'ೡ'};
  final Set<String> YOGAVAHAS = {'ಂ', 'ः', 'ಃ'};
  final String VIRAMA = '್';
  final Set<String> VS_SHORT = {'ಿ', 'ು', 'ೃ', 'ೆ', 'ೊ'};
  final Set<String> VS_LONG = {'ಾ', 'ೀ', 'ೂ', 'ೇ', 'ೈ', 'ೋ', 'ೌ', 'ೄ'};

  final Map<String, List<String>> GANAS = {
    'Ma': ['-', '-', '-'],
    'Ya': ['U', '-', '-'],
    'Ra': ['-', 'U', '-'],
    'Sa': ['U', 'U', '-'],
    'Ta': ['-', '-', 'U'],
    'Ja': ['U', '-', 'U'],
    'Bha': ['-', 'U', 'U'],
    'Na': ['U', 'U', 'U'],
  };

  String cleanText(String text) {
    // keep Kannada range and whitespace
    final buffer = StringBuffer();
    for (var r in text.runes) {
      final ch = String.fromCharCode(r);
      if ((ch.codeUnitAt(0) >= 0x0C80 && ch.codeUnitAt(0) <= 0x0CFF) || ch.trim().isEmpty) {
        buffer.write(ch);
      } else {
        buffer.write(' ');
      }
    }
    return buffer.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  List<String> getLaghuGuruSequence(String text) {
    final clean = text;
    final chars = clean.split('');
    final List<String> weights = [];
    var i = 0;
    while (i < chars.length) {
      final char = chars[i];
      if (char.trim().isEmpty) {
        i++;
        continue;
      }
      var current = LAGHU;
      if (VOWELS_LONG.contains(char)) current = GURU;
      else if (VOWELS_SHORT.contains(char)) current = LAGHU;
      else {
        // consonant range heuristic
        if (i + 1 < chars.length) {
          final next = chars[i + 1];
          if (VS_LONG.contains(next)) {
            current = GURU;
            i += 1;
          } else if (VS_SHORT.contains(next)) {
            current = LAGHU;
            i += 1;
          } else if (next == VIRAMA) {
            if (weights.isNotEmpty) weights[weights.length - 1] = GURU;
            i += 2;
            continue;
          }
        }
      }
      if (i + 1 < chars.length && YOGAVAHAS.contains(chars[i + 1])) {
        current = GURU;
        i += 1;
      }
      if (i + 1 < chars.length) {
        final peek = chars[i + 1];
        if (peek.codeUnitAt(0) >= 0x0C90 && peek.codeUnitAt(0) <= 0x0CB9 && i + 2 < chars.length && chars[i + 2] == VIRAMA) {
          current = GURU;
        }
      }
      weights.add(current);
      i += 1;
    }
    return weights;
  }

  String identifyGanas(List<String> weights) {
    final ganas = <String>[];
    final rem = weights.length % 3;
    for (var i = 0; i < weights.length - rem; i += 3) {
      final chunk = weights.sublist(i, i + 3);
      final match = GANAS.entries.firstWhere(
          (e) => _listEquals(e.value, chunk),
          orElse: () => const MapEntry('?', <String>['?','?','?']));
      ganas.add(match.key);
    }
    var res = ganas.join('-');
    if (rem != 0) {
      final tail = weights.sublist(weights.length - rem).map((w) => w == LAGHU ? 'La' : 'Ga');
      res = res.isEmpty ? tail.join('-') : (res + '-' + tail.join('-'));
    }
    return res;
  }

  bool _listEquals(List a, List b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) if (a[i] != b[i]) return false;
    return true;
  }

  Map<String, dynamic> analyzeSingleStanza(String textBlock) {
    final cleaned = textBlock.trim();
    final lines = cleaned.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    final analysis = <Map<String, dynamic>>[];
    for (var line in lines) {
      final w = getLaghuGuruSequence(line);
      final g = identifyGanas(w);
      final m = w.fold<int>(0, (p, e) => p + (e == LAGHU ? 1 : 2));
      final cnt = w.length;
      var match = 'Unknown';
      // heuristic matches ported from python (kept simple)
      if (cnt == 20 && g.startsWith('Bha-Ra-Na')) match = 'Utpalamala';
      else if (cnt == 21 && g.contains('Ma-Ra-Bha-Na')) match = 'Sragdhara';
      analysis.add({'line': line, 'pattern': w, 'ganas': g, 'matras': m, 'match': match});
    }

    var overall = 'Unknown / Vruttha';
    if (lines.length == 4) {
      final ms = analysis.map((e) => e['matras'] as int).toList();
      if ((ms[0] >= 11 && ms[0] <= 13) && (ms[1] >= 19 && ms[1] <= 21) && (ms[2] >= 11 && ms[2] <= 13) && (ms[3] >= 19 && ms[3] <= 21)) {
        overall = 'Kanda Padya (ಕಂದ ಪದ್ಯ)';
      }
    }

    final vrutthaCounts = <String, int>{};
    for (var l in analysis) {
      if (l['match'] != 'Unknown') vrutthaCounts[l['match'] as String] = (vrutthaCounts[l['match'] as String] ?? 0) + 1;
    }
    if (vrutthaCounts.isNotEmpty) {
      final mostCommon = vrutthaCounts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
      final count = vrutthaCounts[mostCommon] ?? 0;
      if (count >= (lines.length / 2)) overall = mostCommon;
    }

    return {'overallType': overall, 'lines': analysis};
  }

  ChandasResult analyzeFullPoem(String text) {
    final rawStanzas = text.split(RegExp(r'\n\s*\n'));
    final results = <Stanza>[];
    var index = 0;
    for (var raw in rawStanzas) {
      index += 1;
      if (raw.trim().isEmpty) continue;
      final stanza = analyzeSingleStanza(raw);
      final lines = (stanza['lines'] as List<dynamic>).map((ln) {
        final m = ln as Map<String, dynamic>;
        return LineResult(
          line: m['line'] as String,
          pattern: (m['pattern'] as List<dynamic>).map((e) => e.toString()).toList(),
          ganas: m['ganas'] as String,
          matras: (m['matras'] as num).toInt(),
          match: m['match'] as String,
        );
      }).toList();
      results.add(Stanza(overallType: stanza['overallType'] as String, lines: lines));
    }
    return ChandasResult(stanzas: results);
  }
}

// Convenience wrapper
ChandasResult analyzeTextLocally(String text) => KannadaChandasIdentifier().analyzeFullPoem(text);
