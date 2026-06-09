import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cloud_otp/controllers/account_link_controller.dart';

// These tests cover only the controller's *local* operations (the ones that
// never touch Supabase): add / remove / update / merge / replace. The Supabase
// client is constructed but never network-called.
void main() {
  const otpKey = 'otpUris';
  late SupabaseClient dummyClient;

  AccountLinkController newController() => AccountLinkController(
        supabaseClient: dummyClient,
        preferences: SharedPreferencesAsync(),
      );

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    dummyClient =
        SupabaseClient('https://example.supabase.co', 'public-anon-key');
  });

  String uri(String label) => 'otpauth://totp/$label?secret=GEZDGNBVGY3TQOJQ';

  test('initialize loads an empty list when nothing is stored', () async {
    final controller = newController();
    await controller.initialize();
    expect(controller.rawOtpUris, isEmpty);
  });

  test('initialize loads previously stored URIs', () async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData(
      {
        otpKey: <String>[uri('A'), uri('B')],
      },
    );
    final controller = newController();
    await controller.initialize();
    expect(controller.rawOtpUris, [uri('A'), uri('B')]);
  });

  test('addOtp appends and persists', () async {
    final controller = newController();
    await controller.initialize();
    await controller.addOtp(uri('A'));
    await controller.addOtp(uri('B'));
    expect(controller.rawOtpUris, [uri('A'), uri('B')]);

    // Persisted: a fresh controller on the same backend sees it.
    final reloaded = newController();
    await reloaded.initialize();
    expect(reloaded.rawOtpUris, [uri('A'), uri('B')]);
  });

  test('removeOtpAt removes by index and ignores out-of-bounds', () async {
    final controller = newController();
    await controller.initialize();
    await controller.addOtp(uri('A'));
    await controller.addOtp(uri('B'));

    await controller.removeOtpAt(5); // no-op
    expect(controller.rawOtpUris, [uri('A'), uri('B')]);

    await controller.removeOtpAt(0);
    expect(controller.rawOtpUris, [uri('B')]);
  });

  test('updateOtpAt replaces in place, persists, and bounds-checks', () async {
    final controller = newController();
    await controller.initialize();
    await controller
        .addOtp('otpauth://hotp/A?secret=GEZDGNBVGY3TQOJQ&counter=0');

    await controller.updateOtpAt(
        0, 'otpauth://hotp/A?secret=GEZDGNBVGY3TQOJQ&counter=1');
    expect(controller.rawOtpUris.single.contains('counter=1'), isTrue);

    await controller.updateOtpAt(
        9, 'otpauth://hotp/A?secret=GEZDGNBVGY3TQOJQ&counter=2'); // no-op
    expect(controller.rawOtpUris.single.contains('counter=1'), isTrue);

    final reloaded = newController();
    await reloaded.initialize();
    expect(reloaded.rawOtpUris.single.contains('counter=1'), isTrue);
  });

  test('mergeWith adds only new entries and dedupes', () async {
    final controller = newController();
    await controller.initialize();
    await controller.addOtp(uri('A'));

    await controller.mergeWith([uri('A'), uri('B'), uri('C')]);
    expect(controller.rawOtpUris, [uri('A'), uri('B'), uri('C')]);
  });

  test('mergeWith with no new entries is a no-op', () async {
    final controller = newController();
    await controller.initialize();
    await controller.addOtp(uri('A'));

    var notified = 0;
    controller.addListener(() => notified++);
    await controller.mergeWith([uri('A')]);
    expect(controller.rawOtpUris, [uri('A')]);
    expect(notified, 0);
  });

  test('replaceLocalWith overwrites the whole list', () async {
    final controller = newController();
    await controller.initialize();
    await controller.addOtp(uri('A'));
    await controller.addOtp(uri('B'));

    await controller.replaceLocalWith([uri('X')]);
    expect(controller.rawOtpUris, [uri('X')]);
  });

  group('mergeWith HOTP de-duplication', () {
    String hotp(String label, int counter) =>
        'otpauth://hotp/$label?secret=GEZDGNBVGY3TQOJQ&counter=$counter';

    test('same account with a higher incoming counter adopts it (no dup)',
        () async {
      final controller = newController();
      await controller.initialize();
      await controller.addOtp(hotp('A', 2));

      await controller.mergeWith([hotp('A', 5)]);
      expect(controller.rawOtpUris.length, 1);
      // Adopted the incoming string verbatim (not re-serialized).
      expect(controller.rawOtpUris.single, hotp('A', 5));
    });

    test('same account with a lower incoming counter is ignored', () async {
      final controller = newController();
      await controller.initialize();
      await controller.addOtp(hotp('A', 5));

      await controller.mergeWith([hotp('A', 2)]);
      expect(controller.rawOtpUris, [hotp('A', 5)]);
    });

    test('distinct accounts are both kept', () async {
      final controller = newController();
      await controller.initialize();
      await controller.addOtp(hotp('A', 0));

      await controller.mergeWith([hotp('B', 0)]);
      expect(controller.rawOtpUris.length, 2);
    });

    test('unparseable entries fall back to exact-string dedupe', () async {
      final controller = newController();
      await controller.initialize();
      await controller.addOtp('not-a-uri');

      await controller.mergeWith(['not-a-uri', 'also-bad']);
      expect(controller.rawOtpUris, ['not-a-uri', 'also-bad']);
    });
  });

  group('data migration', () {
    test('stamps the current schema version on initialize', () async {
      final prefs = SharedPreferencesAsync();
      expect(await prefs.getInt('dataSchemaVersion'), isNull);

      await newController().initialize();
      expect(await prefs.getInt('dataSchemaVersion'), 1);
    });

    test('leaves pre-existing (unversioned) URIs untouched', () async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.withData(
        {
          otpKey: <String>[uri('Legacy1'), uri('Legacy2')],
        },
      );
      final controller = newController();
      await controller.initialize();
      expect(controller.rawOtpUris, [uri('Legacy1'), uri('Legacy2')]);
    });
  });

  test('updateOtpAt is local-only; manual backup is the cloud sync path',
      () async {
    final controller = newController();
    await controller.initialize();
    await controller
        .addOtp('otpauth://hotp/A?secret=GEZDGNBVGY3TQOJQ&counter=0');

    await controller.updateOtpAt(
        0, 'otpauth://hotp/A?secret=GEZDGNBVGY3TQOJQ&counter=1');

    expect(controller.rawOtpUris.single.contains('counter=1'), isTrue);
  });
}
