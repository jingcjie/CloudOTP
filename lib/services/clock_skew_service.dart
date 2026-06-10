import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

class ClockSkewResult {
  const ClockSkewResult({
    required this.offset,
    required this.roundTrip,
  });

  /// Server time minus local midpoint time. A negative offset means the local
  /// clock appears ahead of the server.
  final Duration offset;
  final Duration roundTrip;

  Duration get absoluteOffset => offset.isNegative ? -offset : offset;
}

typedef ServerTimeFetcher = Future<Object?> Function();

const defaultClockSkewWarningThreshold = Duration(seconds: 15);

int? clockSkewWarningSeconds(
  ClockSkewResult? result, {
  Duration threshold = defaultClockSkewWarningThreshold,
}) {
  if (result == null) return null;
  if (result.absoluteOffset < threshold) return null;
  return (result.absoluteOffset.inMilliseconds / 1000).round();
}

Future<ClockSkewResult?> checkClockSkew({
  required ServerTimeFetcher fetchServerTime,
  DateTime Function() now = DateTime.now,
  Duration timeout = const Duration(seconds: 8),
}) async {
  final DateTime requestStartedAt;
  final Object? rawServerTime;
  final DateTime requestFinishedAt;
  try {
    requestStartedAt = now().toUtc();
    rawServerTime = await fetchServerTime().timeout(timeout);
    requestFinishedAt = now().toUtc();
  } catch (_) {
    return null;
  }

  final serverTime = _parseServerTime(rawServerTime);
  if (serverTime == null) return null;

  final roundTrip = requestFinishedAt.difference(requestStartedAt);
  final midpointMicros =
      requestStartedAt.microsecondsSinceEpoch + roundTrip.inMicroseconds ~/ 2;
  final offset = Duration(
    microseconds: serverTime.microsecondsSinceEpoch - midpointMicros,
  );

  return ClockSkewResult(offset: offset, roundTrip: roundTrip);
}

Future<ClockSkewResult?> checkSupabaseClockSkew(
  SupabaseClient client, {
  DateTime Function() now = DateTime.now,
  Duration timeout = const Duration(seconds: 8),
}) {
  return checkClockSkew(
    fetchServerTime: () => client.rpc('keep_alive'),
    now: now,
    timeout: timeout,
  );
}

DateTime? _parseServerTime(Object? raw) {
  if (raw is DateTime) return raw.toUtc();
  if (raw is String) return _parseTimestamp(raw);
  if (raw is List && raw.isNotEmpty) return _parseServerTime(raw.first);
  if (raw is Map) {
    for (final key in const ['server_time', 'keep_alive', 'now', 'timestamp']) {
      if (raw.containsKey(key)) {
        final parsed = _parseServerTime(raw[key]);
        if (parsed != null) return parsed;
      }
    }
  }
  return null;
}

DateTime? _parseTimestamp(String value) {
  final trimmed = value.trim();
  final parsed = DateTime.tryParse(trimmed);
  if (parsed != null) return parsed.toUtc();

  final normalized = trimmed.replaceFirst(' ', 'T');
  return DateTime.tryParse(normalized)?.toUtc();
}
