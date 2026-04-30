class ChandasResult {
  ChandasResult({required this.stanzas});

  final List<Stanza> stanzas;

  factory ChandasResult.fromMap(Map<String, dynamic> json) {
    final stanzas = (json['stanzas'] as List<dynamic>? ?? <dynamic>[]) 
        .map((e) => Stanza.fromMap(e as Map<String, dynamic>))
        .toList();
    return ChandasResult(stanzas: stanzas);
  }

  Map<String, dynamic> toMap() => {
        'stanzas': stanzas.map((e) => e.toMap()).toList(),
      };
}

class Stanza {
  Stanza({required this.overallType, required this.lines});

  final String overallType;
  final List<LineResult> lines;

  factory Stanza.fromMap(Map<String, dynamic> json) {
    final lines = (json['lines'] as List<dynamic>? ?? <dynamic>[]) 
        .map((e) => LineResult.fromMap(e as Map<String, dynamic>))
        .toList();
    return Stanza(
      overallType: (json['overallType'] ?? 'Unknown').toString(),
      lines: lines,
    );
  }

  Map<String, dynamic> toMap() => {
        'overallType': overallType,
        'lines': lines.map((e) => e.toMap()).toList(),
      };
}

class LineResult {
  LineResult({
    required this.line,
    required this.pattern,
    required this.ganas,
    required this.matras,
    required this.match,
  });

  final String line;
  final List<String> pattern;
  final String ganas;
  final int matras;
  final String match;

  factory LineResult.fromMap(Map<String, dynamic> json) {
    return LineResult(
      line: (json['line'] ?? '').toString(),
      pattern: (json['pattern'] as List<dynamic>? ?? <dynamic>[]) 
          .map((e) => e.toString())
          .toList(),
      ganas: (json['ganas'] ?? '').toString(),
      matras: (json['matras'] as num?)?.toInt() ?? 0,
      match: (json['match'] ?? 'Unknown').toString(),
    );
  }

  Map<String, dynamic> toMap() => {
        'line': line,
        'pattern': pattern,
        'ganas': ganas,
        'matras': matras,
        'match': match,
      };
}
