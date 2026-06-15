import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_otp/models/otp_item.dart';
import 'package:cloud_otp/theme/app_theme.dart';
import 'package:cloud_otp/utils/l10n_extensions.dart';
import 'package:flutter/material.dart';

enum _OtpTileAction { export, refresh, advance, delete }

/// A single OTP row. Each tile owns its own timer / progress / code state, so a
/// tick only repaints the countdown ring instead of rebuilding the whole list.
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
    var currentWindow = _updateTotpProgress(periodMs);
    _timer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final window = _updateTotpProgress(periodMs);
      if (window != currentWindow) {
        currentWindow = window;
        final newCode = _safeGenerate(_item);
        if (newCode != _code) {
          setState(() => _code = newCode);
        }
      }
    });
  }

  int _updateTotpProgress(int periodMs) {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    _progress.value = (nowMs % periodMs) / periodMs;
    return nowMs ~/ periodMs;
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

  void _copyPrimary() {
    if (_isHotp) {
      _copyAndAdvanceHotp();
    } else {
      widget.onCopy(_code);
    }
  }

  void _handleMenuAction(_OtpTileAction action) {
    switch (action) {
      case _OtpTileAction.export:
        widget.onExport();
        break;
      case _OtpTileAction.refresh:
        _refreshTotp();
        break;
      case _OtpTileAction.advance:
        _advanceHotp();
        break;
      case _OtpTileAction.delete:
        widget.onDelete();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final material = MaterialLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final display = _OtpDisplay.fromItem(_item);
    final code = _formatCode(_code);
    final copyTooltip =
        _isHotp ? l10n.hotpCopyAdvanceTooltip : material.copyButtonLabel;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      child: Material(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border(context)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    _IssuerMark(label: display.issuer),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  display.issuer,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _TypeBadge(text: _isHotp ? 'HOTP' : 'TOTP'),
                            ],
                          ),
                          if (display.account.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              display.account,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.muted(context),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    PopupMenuButton<_OtpTileAction>(
                      tooltip: material.moreButtonTooltip,
                      icon: const Icon(Icons.more_vert_rounded),
                      onSelected: _handleMenuAction,
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: _OtpTileAction.export,
                          child: _MenuItem(
                            icon: Icons.ios_share_rounded,
                            label: l10n.exportData,
                          ),
                        ),
                        if (_isHotp)
                          PopupMenuItem(
                            value: _OtpTileAction.advance,
                            child: _MenuItem(
                              icon: Icons.navigate_next_rounded,
                              label: l10n.hotpAdvanceTooltip,
                            ),
                          )
                        else
                          PopupMenuItem(
                            value: _OtpTileAction.refresh,
                            child: _MenuItem(
                              icon: Icons.refresh_rounded,
                              label: material.refreshIndicatorSemanticLabel,
                            ),
                          ),
                        PopupMenuItem(
                          value: _OtpTileAction.delete,
                          child: _MenuItem(
                            icon: Icons.delete_outline_rounded,
                            label: material.deleteButtonTooltip,
                            color: colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        code,
                        maxLines: 1,
                        overflow: TextOverflow.visible,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontFeatures: const [FontFeature.tabularFigures()],
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (_isHotp)
                      _CounterBadge(counter: _item.counter)
                    else
                      ValueListenableBuilder<double>(
                        valueListenable: _progress,
                        builder: (context, value, _) => _CountdownRing(
                          elapsed: value,
                          interval: _item.interval,
                        ),
                      ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      tooltip: copyTooltip,
                      icon: const Icon(Icons.copy_rounded),
                      onPressed: _copyPrimary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatCode(String value) {
    if (!RegExp(r'^\d+$').hasMatch(value) || value.length <= 3) {
      return value;
    }

    final groups = <String>[];
    for (var index = 0; index < value.length; index += 3) {
      groups.add(value.substring(index, math.min(index + 3, value.length)));
    }
    return groups.join(' ');
  }
}

class _OtpDisplay {
  const _OtpDisplay({
    required this.issuer,
    required this.account,
  });

  final String issuer;
  final String account;

  factory _OtpDisplay.fromItem(OtpItem item) {
    final rawLabel = item.label.trim();
    final rawIssuer = item.issuer.trim();
    final separatorIndex = rawLabel.indexOf(':');

    if (rawIssuer.isNotEmpty) {
      final prefixedLabel = '$rawIssuer:';
      final account = rawLabel.startsWith(prefixedLabel)
          ? rawLabel.substring(prefixedLabel.length).trim()
          : rawLabel;
      return _OtpDisplay(
        issuer: rawIssuer,
        account: account == rawIssuer ? '' : account,
      );
    }

    if (separatorIndex > 0 && separatorIndex < rawLabel.length - 1) {
      return _OtpDisplay(
        issuer: rawLabel.substring(0, separatorIndex).trim(),
        account: rawLabel.substring(separatorIndex + 1).trim(),
      );
    }

    return _OtpDisplay(
      issuer: rawLabel.isEmpty ? 'OTP' : rawLabel,
      account: '',
    );
  }
}

class _IssuerMark extends StatelessWidget {
  const _IssuerMark({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final background = _brandColor(label);
    final foreground =
        ThemeData.estimateBrightnessForColor(background) == Brightness.dark
            ? Colors.white
            : Colors.black;

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        _monogram(label),
        style: TextStyle(
          color: foreground,
          fontSize: 15,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
      ),
    );
  }

  Color _brandColor(String value) {
    const colors = [
      Color(0xFF39D98A),
      Color(0xFF4AA3FF),
      Color(0xFFFFC857),
      Color(0xFFFF7A59),
      Color(0xFFA48CFF),
      Color(0xFF5AD4D8),
    ];
    final hash = value.codeUnits.fold<int>(0, (sum, code) => sum + code);
    return colors[hash % colors.length];
  }

  String _monogram(String value) {
    final words = RegExp(r'[A-Za-z0-9]+')
        .allMatches(value)
        .map((match) => match.group(0)!)
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    if (words.length == 1) {
      final word = words.first;
      return word.substring(0, math.min(2, word.length)).toUpperCase();
    }
    return '?';
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.secondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        child: Text(
          text,
          style: TextStyle(
            color: colorScheme.secondary,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _CountdownRing extends StatelessWidget {
  const _CountdownRing({
    required this.elapsed,
    required this.interval,
  });

  final double elapsed;
  final int interval;

  @override
  Widget build(BuildContext context) {
    final safeInterval = interval <= 0 ? 30 : interval;
    final remaining =
        math.max(1, ((1 - elapsed.clamp(0.0, 1.0)) * safeInterval).ceil());
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 38,
      height: 38,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: 1 - elapsed.clamp(0.0, 1.0),
            strokeWidth: 3,
            backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
          Text(
            '$remaining',
            style: TextStyle(
              color: AppColors.muted(context),
              fontFeatures: const [FontFeature.tabularFigures()],
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _CounterBadge extends StatelessWidget {
  const _CounterBadge({required this.counter});

  final int counter;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.elevated(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Text(
          '#$counter',
          style: TextStyle(
            color: AppColors.muted(context),
            fontFeatures: const [FontFeature.tabularFigures()],
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    this.color,
  });

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final itemColor = color ?? Theme.of(context).colorScheme.onSurface;
    return Row(
      children: [
        Icon(icon, color: itemColor, size: 20),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(color: itemColor, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
