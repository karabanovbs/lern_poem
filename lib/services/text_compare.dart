import 'dart:math';

class TextCompareService {
  static String normalize(String input) {
    // Приводим к нижнему регистру
    final lower = input.toLowerCase();
    // Убираем все знаки препинания и специальные символы
    // \p{P} - все знаки препинания, \p{S} - все символы
    final withoutPunct = lower.replaceAll(
      RegExp(r'[\p{P}\p{S}]', unicode: true),
      ' ',
    );
    // Нормализуем пробелы (заменяем множественные пробелы на один)
    final collapsed = withoutPunct.replaceAll(RegExp(r'\s+'), ' ').trim();
    return collapsed;
  }

  static double levenshteinSimilarity(String a, String b) {
    final s = normalize(a);
    final t = normalize(b);
    if (s.isEmpty && t.isEmpty) return 100.0;
    final dist = _levenshtein(s, t);
    final maxLen = max(s.length, t.length);
    if (maxLen == 0) return 100.0;
    final sim = (1.0 - dist / maxLen) * 100.0;
    return sim.clamp(0.0, 100.0);
  }

  static int _levenshtein(String s, String t) {
    final n = s.length;
    final m = t.length;
    if (n == 0) return m;
    if (m == 0) return n;
    final prev = List<int>.generate(m + 1, (j) => j);
    final curr = List<int>.filled(m + 1, 0);
    for (int i = 1; i <= n; i++) {
      curr[0] = i;
      for (int j = 1; j <= m; j++) {
        final cost = s[i - 1] == t[j - 1] ? 0 : 1;
        curr[j] = min(min(curr[j - 1] + 1, prev[j] + 1), prev[j - 1] + cost);
      }
      for (int j = 0; j <= m; j++) {
        prev[j] = curr[j];
      }
    }
    return prev[m];
  }

  static double werSimilarity(String ref, String hyp) {
    final refTokens = _tokenizeWords(ref);
    final hypTokens = _tokenizeWords(hyp);
    if (refTokens.isEmpty && hypTokens.isEmpty) return 100.0;
    final wer = _wer(refTokens, hypTokens);
    final sim = (1.0 - wer) * 100.0;
    return sim.isFinite ? sim.clamp(0.0, 100.0) : 0.0;
  }

  static List<String> _tokenizeWords(String input) {
    final norm = normalize(input);
    if (norm.isEmpty) return const [];
    return norm.split(' ');
  }

  static double _wer(List<String> ref, List<String> hyp) {
    final n = ref.length;
    final m = hyp.length;
    if (n == 0) return m.toDouble();
    final dp = List.generate(n + 1, (_) => List<int>.filled(m + 1, 0));
    for (int i = 0; i <= n; i++) dp[i][0] = i;
    for (int j = 0; j <= m; j++) dp[0][j] = j;
    for (int i = 1; i <= n; i++) {
      for (int j = 1; j <= m; j++) {
        final cost = ref[i - 1] == hyp[j - 1] ? 0 : 1;
        dp[i][j] = min(
          min(
            dp[i - 1][j] + 1, // deletion
            dp[i][j - 1] + 1, // insertion
          ),
          dp[i - 1][j - 1] + cost, // substitution
        );
      }
    }
    final errors = dp[n][m];
    return errors / n;
  }
}
