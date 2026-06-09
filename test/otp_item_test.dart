import 'package:flutter_test/flutter_test.dart';
import 'package:otp/otp.dart';
import 'package:cloud_otp/models/otp_item.dart';

void main() {
  // ASCII "12345678901234567890" in base32 — the RFC 6238 / RFC 4226 test key.
  const rfcSecret = 'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ';

  group('OtpItem.fromUri', () {
    test('applies TOTP defaults when only secret/label given', () {
      final item = OtpItem.fromUri('otpauth://totp/Example?secret=$rfcSecret');
      expect(item.type, OtpType.totp);
      expect(item.label, 'Example');
      expect(item.secret, rfcSecret);
      expect(item.issuer, '');
      expect(item.length, 6);
      expect(item.interval, 30);
      expect(item.algorithm, Algorithm.SHA1);
      expect(item.counter, 0);
    });

    test('parses explicit digits/period/issuer', () {
      final item = OtpItem.fromUri(
        'otpauth://totp/ACME:alice@acme.com?secret=$rfcSecret&issuer=ACME&digits=8&period=60',
      );
      expect(item.label, 'ACME:alice@acme.com');
      expect(item.issuer, 'ACME');
      expect(item.length, 8);
      expect(item.interval, 60);
    });

    test('parses SHA256 and SHA512 algorithms (case-insensitive)', () {
      expect(
        OtpItem.fromUri('otpauth://totp/A?secret=$rfcSecret&algorithm=SHA256')
            .algorithm,
        Algorithm.SHA256,
      );
      expect(
        OtpItem.fromUri('otpauth://totp/A?secret=$rfcSecret&algorithm=sha512')
            .algorithm,
        Algorithm.SHA512,
      );
    });

    test('parses HOTP type and counter', () {
      final item = OtpItem.fromUri(
        'otpauth://hotp/A?secret=$rfcSecret&counter=7',
      );
      expect(item.type, OtpType.hotp);
      expect(item.counter, 7);
    });

    test('rejects garbage digits and period', () {
      expect(
        () => OtpItem.fromUri('otpauth://totp/A?secret=$rfcSecret&digits=abc'),
        throwsFormatException,
      );
      expect(
        () => OtpItem.fromUri('otpauth://totp/A?secret=$rfcSecret&period=0'),
        throwsFormatException,
      );
    });

    test('rejects missing or invalid secrets', () {
      expect(() => OtpItem.fromUri('otpauth://totp/A'), throwsFormatException);
      expect(
        () => OtpItem.fromUri('otpauth://totp/A?secret=NOT*BASE32'),
        throwsFormatException,
      );
    });

    test('rejects invalid HOTP counters', () {
      expect(
        () => OtpItem.fromUri('otpauth://hotp/A?secret=$rfcSecret'),
        throwsFormatException,
      );
      expect(
        () => OtpItem.fromUri('otpauth://hotp/A?secret=$rfcSecret&counter=-1'),
        throwsFormatException,
      );
      expect(
        () =>
            OtpItem.fromUri('otpauth://hotp/A?secret=$rfcSecret&counter=nope'),
        throwsFormatException,
      );
    });

    test('throws on a non-URI string', () {
      expect(() => OtpItem.fromUri('::: not a uri :::'), throwsFormatException);
    });
  });

  group('toUri round-trip', () {
    test('TOTP with defaults reproduces a minimal URI', () {
      final original =
          OtpItem.fromUri('otpauth://totp/Example?secret=$rfcSecret');
      final round = OtpItem.fromUri(original.toUri());
      expect(round.type, OtpType.totp);
      expect(round.label, 'Example');
      expect(round.secret, rfcSecret);
      expect(round.length, 6);
      expect(round.interval, 30);
      expect(round.algorithm, Algorithm.SHA1);
      // Defaults are omitted from the serialized URI.
      expect(original.toUri().contains('counter='), isFalse);
      expect(original.toUri().contains('digits='), isFalse);
    });

    test('preserves non-default fields through fromUri(toUri())', () {
      final item = OtpItem(
        label: 'ACME:bob',
        secret: rfcSecret,
        issuer: 'ACME',
        length: 8,
        interval: 60,
        algorithm: Algorithm.SHA256,
      );
      final round = OtpItem.fromUri(item.toUri());
      expect(round.label, 'ACME:bob');
      expect(round.issuer, 'ACME');
      expect(round.length, 8);
      expect(round.interval, 60);
      expect(round.algorithm, Algorithm.SHA256);
    });

    test('HOTP serializes and restores its counter', () {
      final item = OtpItem(
        label: 'A',
        secret: rfcSecret,
        issuer: '',
        type: OtpType.hotp,
        counter: 42,
      );
      expect(item.toUri().contains('counter=42'), isTrue);
      expect(item.toUri().startsWith('otpauth://hotp/'), isTrue);
      expect(OtpItem.fromUri(item.toUri()).counter, 42);
    });
  });

  group('copyWith', () {
    test('advances only the counter', () {
      final item = OtpItem(
        label: 'A',
        secret: rfcSecret,
        issuer: 'I',
        type: OtpType.hotp,
        counter: 3,
      );
      final next = item.copyWith(counter: item.counter + 1);
      expect(next.counter, 4);
      expect(next.label, 'A');
      expect(next.secret, rfcSecret);
      expect(next.type, OtpType.hotp);
    });
  });

  group('identityKey', () {
    test('ignores the HOTP counter (same account, different counters)', () {
      final a = OtpItem.fromUri('otpauth://hotp/A?secret=$rfcSecret&counter=2');
      final b = OtpItem.fromUri('otpauth://hotp/A?secret=$rfcSecret&counter=9');
      expect(a.identityKey, b.identityKey);
    });

    test('differs for different accounts', () {
      final a = OtpItem.fromUri('otpauth://hotp/A?secret=$rfcSecret&counter=0');
      final b = OtpItem.fromUri('otpauth://hotp/B?secret=$rfcSecret&counter=0');
      expect(a.identityKey, isNot(b.identityKey));
    });

    test('TOTP vs HOTP of the same account are distinct identities', () {
      final totp = OtpItem.fromUri('otpauth://totp/A?secret=$rfcSecret');
      final hotp =
          OtpItem.fromUri('otpauth://hotp/A?secret=$rfcSecret&counter=0');
      expect(totp.identityKey, isNot(hotp.identityKey));
    });
  });

  group('generate', () {
    // RFC 6238: SHA1, 8 digits, T=59s -> 94287082.
    test('TOTP SHA1 matches RFC 6238 test vector', () {
      final item = OtpItem(
        label: 'A',
        secret: rfcSecret,
        issuer: '',
        length: 8,
      );
      expect(item.generate(atMillis: 59 * 1000), '94287082');
    });

    // SHA256/SHA512 use the Google-style single key (app behavior), not the
    // RFC's per-algorithm extended keys; these lock the app's actual output.
    test('TOTP SHA256/SHA512 are stable (regression lock)', () {
      final sha256 = OtpItem(
          label: 'A',
          secret: rfcSecret,
          issuer: '',
          length: 8,
          algorithm: Algorithm.SHA256);
      final sha512 = OtpItem(
          label: 'A',
          secret: rfcSecret,
          issuer: '',
          length: 8,
          algorithm: Algorithm.SHA512);
      expect(sha256.generate(atMillis: 59 * 1000), '32247374');
      expect(sha512.generate(atMillis: 59 * 1000), '69342147');
    });

    // RFC 4226 HOTP (SHA1, 6 digits), counters 0..5.
    test('HOTP matches RFC 4226 test vectors', () {
      const expected = [
        '755224',
        '287082',
        '359152',
        '969429',
        '338314',
        '254676'
      ];
      for (var c = 0; c < expected.length; c++) {
        final item = OtpItem(
          label: 'A',
          secret: rfcSecret,
          issuer: '',
          type: OtpType.hotp,
          counter: c,
        );
        expect(item.generate(), expected[c], reason: 'counter $c');
      }
    });

    test('secret is upper-cased before generation', () {
      final lower = OtpItem(
          label: 'A', secret: rfcSecret.toLowerCase(), issuer: '', length: 8);
      expect(lower.generate(atMillis: 59 * 1000), '94287082');
    });
  });
}
