import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_otp/models/otp_item.dart';
import 'package:cloud_otp/utils/l10n_extensions.dart';

/// A single OTP row. Each tile owns its own timer / progress / code state, so a
/// tick only repaints this card (the progress bar repaints via a
/// [ValueListenableBuilder]) instead of rebuilding the whole list.
///
/// TOTP tiles run a 100 ms ticker aligned to the real epoch window and refresh
/// the code when the window rolls over. HOTP tiles have no timer: they keep the
/// current counter locally, copy-and-advance in one action, and ask the parent
/// to persist the new URI via [onCounterChanged].
class OtpListTile extends StatefulWidget {
  const OtpListTile({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onExport,
    required this.onCopy,
    required this.onCounterChanged,
  });

  final OtpItem item;
  final VoidCallback onDelete;
  final VoidCallback onExport;
  final ValueChanged<String> onCopy;
  final ValueChanged<String> onCounterChanged;

  @override
  State<OtpListTile> createState() => _OtpListTileState();
}

class _OtpListTileState extends State<OtpListTile> {
  Timer? _timer;
  final ValueNotifier<double> _progress = ValueNotifier<double>(0.0);
  late OtpItem _item;
  late String _code;

  bool get _isHotp => _item.type == OtpType.hotp;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
    _code = _safeGenerate(_item);
    if (!_isHotp) {
      _startTotpCycle();
    }
  }

  @override
  void didUpdateWidget(covariant OtpListTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_shouldAdoptWidgetItem()) {
      _timer?.cancel();
      _item = widget.item;
      _code = _safeGenerate(_item);
      if (!_isHotp) {
        _startTotpCycle();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progress.dispose();
    super.dispose();
  }

  String _safeGenerate(OtpItem item) {
    try {
      return item.generate();
    } catch (e) {
      debugPrint('Error generating OTP: $e');
      return context.l10n.otpErrorPlaceholder;
    }
  }

  void _startTotpCycle() {
    _timer?.cancel();
    final periodMs = _item.interval <= 0 ? 30000 : _item.interval * 1000;
    var currentWindow = DateTime.now().millisecondsSinceEpoch ~/ periodMs;
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      _progress.value = (nowMs % periodMs) / periodMs;
      final window = nowMs ~/ periodMs;
      if (window != currentWindow) {
        currentWindow = window;
        final newCode = _safeGenerate(_item);
        if (newCode != _code) {
          setState(() => _code = newCode);
        }
      }
    });
  }

  void _refreshTotp() {
    final newCode = _safeGenerate(_item);
    setState(() => _code = newCode);
    _startTotpCycle();
  }

  bool _shouldAdoptWidgetItem() {
    if (widget.item.toUri() == _item.toUri()) return false;
    if (_item.type == OtpType.hotp &&
        widget.item.type == OtpType.hotp &&
        widget.item.identityKey == _item.identityKey) {
      return widget.item.counter >= _item.counter;
    }
    return true;
  }

  void _advanceHotp() {
    final next = _item.copyWith(counter: _item.counter + 1);
    final newCode = _safeGenerate(next);
    setState(() {
      _item = next;
      _code = newCode;
    });
    widget.onCounterChanged(next.toUri());
  }

  void _copyAndAdvanceHotp() {
    widget.onCopy(_code);
    _advanceHotp();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final item = _item;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          item.label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(item.issuer),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.ios_share),
              onPressed: widget.onExport,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: widget.onDelete,
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.otpCodeLabel(_code),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(l10n.otpDigitsLabel(item.length)),
                if (_isHotp) Text(l10n.hotpCounterLabel(item.counter)),
                if (!_isHotp) Text(l10n.otpIntervalLabel(item.interval)),
                Text(
                  l10n.otpAlgorithmLabel(
                    item.algorithm.toString().split('.').last,
                  ),
                ),
                const SizedBox(height: 16),
                if (!_isHotp)
                  ValueListenableBuilder<double>(
                    valueListenable: _progress,
                    builder: (context, value, _) => LinearProgressIndicator(
                      value: value.clamp(0.0, 1.0).toDouble(),
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (_isHotp)
                      IconButton(
                        tooltip: l10n.hotpCopyAdvanceTooltip,
                        icon: const Icon(Icons.copy),
                        onPressed: _copyAndAdvanceHotp,
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () => widget.onCopy(_code),
                      ),
                    if (_isHotp)
                      IconButton(
                        tooltip: l10n.hotpAdvanceTooltip,
                        icon: const Icon(Icons.navigate_next),
                        onPressed: _advanceHotp,
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _refreshTotp,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
