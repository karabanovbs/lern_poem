import 'package:flutter_test/flutter_test.dart';
import 'package:nir_app/services/text_compare.dart';

void main() {
  group('TextCompareService', () {
    test('normalize collapses spaces and removes punctuation', () {
      expect(
        TextCompareService.normalize('  Hello,   world!  '),
        'hello world',
      );
    });

    test('levenshteinSimilarity identical strings 100%', () {
      final sim = TextCompareService.levenshteinSimilarity('abc', 'abc');
      expect(sim, closeTo(100.0, 0.001));
    });

    test('levenshteinSimilarity different strings lower than 100%', () {
      final sim = TextCompareService.levenshteinSimilarity('kitten', 'sitting');
      expect(sim, lessThan(100.0));
    });

    test('werSimilarity identical sentences 100%', () {
      final sim = TextCompareService.werSimilarity(
        'one two three',
        'one two three',
      );
      expect(sim, closeTo(100.0, 0.001));
    });

    test('werSimilarity insertion reduces score', () {
      final sim = TextCompareService.werSimilarity('one two', 'one two three');
      expect(sim, lessThan(100.0));
    });
  });
}
