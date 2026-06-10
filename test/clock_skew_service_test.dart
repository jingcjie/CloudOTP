import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_otp/services/clock_skew_service.dart';

void main() {
  group('checkClockSkew', () {
    test('estimates offset from the local request midpoint', () async {
      var nowCalls = 0;
      final times = [
        DateTime.utc(2026, 1, 1, 0, 0, 0),
        DateTime.utc(2026, 1, 1, 0, 0, 1),
      ];

      final result = await checkClockSkew(
        fetchServerTime: () async => '2026-01-01T00:00:20.500Z',
        now: () => times[nowCalls++],
      );

      expect(result, isNotNull);
      expect(result!.roundTrip, const Duration(seconds: 1));
      expect(result.offset, const Duration(seconds: 20));
    });

    test('accepts common RPC wrapper shapes', () async {
      var nowCalls = 0;
      final times = [
        DateTime.utc(2026, 1, 1, 0, 0, 0),
        DateTime.utc(2026, 1, 1, 0, 0, 0),
      ];

      final result = await checkClockSkew(
        fetchServerTime: () async => [
          {'server_time': '2026-01-01 00:00:16+00'}
        ],
        now: () => times[nowCalls++],
      );

      expect(result?.offset, const Duration(seconds: 16));
    });

    test('returns null when server time cannot be parsed', () async {
      final result = await checkClockSkew(
        fetchServerTime: () async => 'not a timestamp',
        now: () => DateTime.utc(2026),
      );

      expect(result, isNull);
    });

    test('returns null when server time fetch fails', () async {
      final result = await checkClockSkew(
        fetchServerTime: () async => throw Exception('offline'),
        now: () => DateTime.utc(2026),
      );

      expect(result, isNull);
    });

    test('returns null when server time fetch times out', () async {
      final result = await checkClockSkew(
        fetchServerTime: () => Future.delayed(
          const Duration(milliseconds: 20),
          () => '2026-01-01T00:00:20Z',
        ),
        now: () => DateTime.utc(2026),
        timeout: const Duration(milliseconds: 1),
      );

      expect(result, isNull);
    });
  });

  group('clockSkewWarningSeconds', () {
    test('is silent below 15 seconds', () {
      final result = ClockSkewResult(
        offset: const Duration(seconds: 14, milliseconds: 999),
        roundTrip: Duration.zero,
      );

      expect(clockSkewWarningSeconds(result), isNull);
    });

    test('reports at 15 seconds or greater', () {
      final result = ClockSkewResult(
        offset: const Duration(seconds: 15),
        roundTrip: Duration.zero,
      );

      expect(clockSkewWarningSeconds(result), 15);
    });

    test('uses absolute offset when local clock is ahead', () {
      final result = ClockSkewResult(
        offset: const Duration(seconds: -17),
        roundTrip: Duration.zero,
      );

      expect(clockSkewWarningSeconds(result), 17);
    });
  });
}
