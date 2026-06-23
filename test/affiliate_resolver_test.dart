import 'package:flutter_test/flutter_test.dart';
import 'package:juan_million/services/affiliate_resolver.dart';

void main() {
  group('normalizeAffiliateInput', () {
    test('trims whitespace', () {
      expect(normalizeAffiliateInput('  GLj4F4  '), 'GLj4F4');
    });

    test('strips Referral Code suffix from settings copy-paste', () {
      expect(
        normalizeAffiliateInput('GLj4F4 (Referral Code)'),
        'GLj4F4',
      );
    });

    test('strips suffix case-insensitively', () {
      expect(
        normalizeAffiliateInput('GLj4F4 (referral code)'),
        'GLj4F4',
      );
    });

    test('returns empty for blank input', () {
      expect(normalizeAffiliateInput('   '), '');
    });
  });
}
