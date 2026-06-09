import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_otp/utils/constants.dart';

void main() {
  const secret = 'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ';

  group('isValidOtpUri', () {
    test('accepts a valid totp URI', () {
      expect(isValidOtpUri('otpauth://totp/Example?secret=$secret'), isTrue);
    });

    test('accepts a valid hotp URI', () {
      expect(isValidOtpUri('otpauth://hotp/Example?secret=$secret&counter=0'),
          isTrue);
    });

    test('accepts lowercase base32 secrets', () {
      expect(
          isValidOtpUri(
              'otpauth://totp/Example?secret=${secret.toLowerCase()}'),
          isTrue);
    });

    test('rejects a missing secret', () {
      expect(isValidOtpUri('otpauth://totp/Example'), isFalse);
      expect(isValidOtpUri('otpauth://totp/Example?secret='), isFalse);
    });

    test('rejects a non-base32 secret', () {
      expect(
          isValidOtpUri('otpauth://totp/Example?secret=bad-secret'), isFalse);
    });

    test('rejects invalid digits and period', () {
      expect(isValidOtpUri('otpauth://totp/Example?secret=$secret&digits=0'),
          isFalse);
      expect(isValidOtpUri('otpauth://totp/Example?secret=$secret&period=-30'),
          isFalse);
      expect(isValidOtpUri('otpauth://totp/Example?secret=$secret&digits=nope'),
          isFalse);
    });

    test('rejects missing, negative, or garbage HOTP counters', () {
      expect(isValidOtpUri('otpauth://hotp/Example?secret=$secret'), isFalse);
      expect(isValidOtpUri('otpauth://hotp/Example?secret=$secret&counter=-1'),
          isFalse);
      expect(
          isValidOtpUri('otpauth://hotp/Example?secret=$secret&counter=nope'),
          isFalse);
    });

    test('rejects a wrong scheme', () {
      expect(isValidOtpUri('https://totp/Example?secret=$secret'), isFalse);
    });

    test('rejects a wrong host (not totp/hotp)', () {
      expect(isValidOtpUri('otpauth://foo/Example?secret=$secret'), isFalse);
    });

    test('rejects arbitrary garbage', () {
      expect(isValidOtpUri('not a uri at all'), isFalse);
      expect(isValidOtpUri(''), isFalse);
    });
  });
}
