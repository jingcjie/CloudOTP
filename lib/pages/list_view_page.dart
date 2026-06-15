import 'package:cloud_otp/controllers/account_link_controller.dart';
import 'package:cloud_otp/theme/app_theme.dart';
import 'package:cloud_otp/utils/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_otp/models/otp_item.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:io' show Platform;
import 'package:file_picker/file_picker.dart';
import 'package:zxing2/qrcode.dart';
import 'package:image/image.dart' as img;
import 'package:cloud_otp/widgets/qr_code_dialog.dart';
import 'package:cloud_otp/widgets/otp_list_tile.dart';
import 'package:cloud_otp/models/snackbar.dart';
import 'package:provider/provider.dart';
import 'package:cloud_otp/utils/l10n_extensions.dart';

class ListViewPage extends StatefulWidget {
  const ListViewPage({super.key});

  @override
  State<ListViewPage> createState() => _ListViewPageState();
}

class _ListViewPageState extends State<ListViewPage> {
  AccountLinkController? _controller;
  List<String> _cachedUris = <String>[];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = context.read<AccountLinkController>();
    if (!identical(_controller, controller)) {
      _controller?.removeListener(_onControllerChanged);
      _controller = controller;
      _controller?.addListener(_onControllerChanged);
      _syncFromController();
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onControllerChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted || _controller == null) return;
    if (!listEquals(_cachedUris, _controller!.otpUris)) {
      setState(_syncFromController);
    }
  }

  void _syncFromController() {
    _cachedUris = List<String>.from(_controller?.otpUris ?? const <String>[]);
  }

  Future<void> _addOtp(String uri) async {
    final controller = _controller;
    if (controller == null) return;
    final l10n = context.l10n;
    try {
      await controller.addOtp(uri);
      if (!mounted) return;
      final message =
          controller.isLinked ? l10n.otpSavedWithBackupHint : l10n.otpSaved;
      context.showBeautifulSnackBar(message: message, isError: false);
    } catch (e) {
      if (!mounted) return;
      context.showBeautifulSnackBar(
          message: l10n.failedToAddOtp('$e'), isError: true);
    }
  }

  void _copyOtp(String code) {
    Clipboard.setData(ClipboardData(text: code));
    context.showBeautifulSnackBar(
        message: context.l10n.otpCopied, isError: false);
  }

  void _exportOtp(BuildContext context, int index) {
    if (index < 0 || index >= _cachedUris.length) return;
    final singleOtpUri = _cachedUris[index];
    showDialog(
      context: context,
      builder: (BuildContext context) => QRCodeDialog(uri: singleOtpUri),
    );
  }

  Future<void> _deleteOtp(int index) async {
    final controller = _controller;
    if (controller == null) return;
    try {
      await controller.removeOtpAt(index);
      if (!mounted) return;
      context.showBeautifulSnackBar(
          message: context.l10n.deletedSuccessfully, isError: false);
    } catch (e) {
      if (!mounted) return;
      context.showBeautifulSnackBar(
        message: context.l10n.failedToDeleteOtp('$e'),
        isError: true,
      );
    }
  }

  Future<void> _updateOtp(int index, String uri) async {
    try {
      await _controller?.updateOtpAt(index, uri);
    } catch (e) {
      if (!mounted) return;
      context.showBeautifulSnackBar(
        message: context.l10n.unexpectedError('$e'),
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final visibleEntries = _visibleEntries();
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _cachedUris.isEmpty
          ? _EmptyOtpState(message: l10n.emptyOtpListHint)
          : visibleEntries.isEmpty
              ? _EmptyOtpState(message: l10n.searchNoResults)
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 96),
                  itemCount: visibleEntries.length,
                  itemBuilder: (context, visibleIndex) {
                    final entry = visibleEntries[visibleIndex];
                    final uri = entry.uri;
                    final index = entry.index;
                    OtpItem item;
                    try {
                      item = OtpItem.fromUri(uri);
                    } catch (e) {
                      return _buildErrorTile(index);
                    }
                    return OtpListTile(
                      key: ValueKey('otp:${item.identityKey}:$index'),
                      item: item,
                      onExport: () => _exportOtp(context, index),
                      onDelete: () => _deleteOtp(index),
                      onCopy: _copyOtp,
                      onCounterChanged: (newUri) => _updateOtp(index, newUri),
                    );
                  },
                ),
      floatingActionButton: SpeedDial(
        icon: Icons.add_rounded,
        activeIcon: Icons.close_rounded,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.keyboard_alt_outlined),
            label: l10n.manualInput,
            onTap: _manualInput,
          ),
          SpeedDialChild(
            child: const Icon(Icons.qr_code_scanner_rounded),
            label: l10n.qrScanner,
            onTap: _qrScanner,
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final l10n = context.l10n;
    final material = MaterialLocalizations.of(context);
    return AppBar(
      titleSpacing: 20,
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: material.searchFieldLabel,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.appTitle),
                Text(
                  l10n.otpListTitle,
                  style: TextStyle(
                    color: AppColors.muted(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
      actions: [
        IconButton(
          tooltip: _isSearching
              ? material.closeButtonTooltip
              : material.searchFieldLabel,
          icon: Icon(
            _isSearching ? Icons.close_rounded : Icons.search_rounded,
          ),
          onPressed: _toggleSearch,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  List<_OtpListEntry> _visibleEntries() {
    final query = _searchQuery.trim().toLowerCase();
    final entries = <_OtpListEntry>[];
    for (var index = 0; index < _cachedUris.length; index++) {
      final uri = _cachedUris[index];
      if (_matchesSearch(uri, query)) {
        entries.add(_OtpListEntry(index: index, uri: uri));
      }
    }
    return entries;
  }

  bool _matchesSearch(String uri, String query) {
    if (query.isEmpty) return true;
    try {
      final item = OtpItem.fromUri(uri);
      return '${item.label} ${item.issuer} ${item.type.name}'
          .toLowerCase()
          .contains(query);
    } catch (_) {
      return uri.toLowerCase().contains(query);
    }
  }

  /// Renders a row for an entry whose URI could not be parsed, so one bad entry
  /// can be removed without the whole list failing to load.
  Widget _buildErrorTile(int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 16),
      child: ListTile(
        leading: Icon(
          Icons.error_outline_rounded,
          color: Theme.of(context).colorScheme.error,
        ),
        title: Text(context.l10n.otpErrorPlaceholder),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline_rounded),
          onPressed: () => _deleteOtp(index),
        ),
      ),
    );
  }

  void _manualInput() async {
    final l10n = context.l10n;
    final String? result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        String secret = '';
        String label = '';
        String issuer = '';
        OtpType type = OtpType.totp;

        return StatefulBuilder(
          builder: (context, setLocalState) => AlertDialog(
            title: Text(l10n.manualInputTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SegmentedButton<OtpType>(
                  segments: const [
                    ButtonSegment(value: OtpType.totp, label: Text('TOTP')),
                    ButtonSegment(value: OtpType.hotp, label: Text('HOTP')),
                  ],
                  selected: {type},
                  onSelectionChanged: (selection) =>
                      setLocalState(() => type = selection.first),
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(labelText: l10n.secretFieldLabel),
                  onChanged: (value) => secret = value,
                ),
                TextField(
                  decoration: InputDecoration(labelText: l10n.labelFieldLabel),
                  onChanged: (value) => label = value,
                ),
                TextField(
                  decoration: InputDecoration(labelText: l10n.issuerFieldLabel),
                  onChanged: (value) => issuer = value,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(null),
                child: Text(l10n.commonCancel),
              ),
              TextButton(
                onPressed: () {
                  final trimmedSecret = secret.trim();
                  final trimmedLabel = label.trim();
                  final trimmedIssuer = issuer.trim();
                  final uri = Uri(
                    scheme: 'otpauth',
                    host: type == OtpType.hotp ? 'hotp' : 'totp',
                    path: trimmedLabel,
                    queryParameters: {
                      'secret': trimmedSecret,
                      if (trimmedIssuer.isNotEmpty) 'issuer': trimmedIssuer,
                      if (type == OtpType.hotp) 'counter': '0',
                    },
                  );
                  Navigator.of(dialogContext).pop(uri.toString());
                },
                child: Text(l10n.commonSave),
              ),
            ],
          ),
        );
      },
    );
    if (result != null) {
      if (!mounted) return;
      if (isValidOtpUri(result)) {
        await _addOtp(result);
      } else {
        context.showBeautifulSnackBar(
            message: context.l10n.invalidOtpQr, isError: true);
      }
    }
  }

  void _qrScanner() async {
    // Android uses the live camera scanner; web and desktop fall back to
    // decoding a picked image file.
    final String? scannedData = (!kIsWeb && Platform.isAndroid)
        ? await _mobileQRScanner()
        : await _webQRScanner();
    if (scannedData == null || !mounted) return;
    if (isValidOtpUri(scannedData)) {
      await _addOtp(scannedData);
    } else {
      context.showBeautifulSnackBar(
          message: context.l10n.invalidOtpQr, isError: true);
    }
  }

  Future<String?> _webQRScanner() async {
    String? scanResult;
    final FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null) {
      final fileBytes = result.files.first.bytes;
      if (fileBytes == null) {
        if (mounted) {
          context.showBeautifulSnackBar(
            message: context.l10n.unableToReadFile,
            isError: true,
          );
        }
        return null;
      }

      try {
        final img.Image? image = img.decodeImage(fileBytes);
        if (image != null) {
          scanResult = _processQRCodeImage(image);
        }
      } catch (e) {
        debugPrint('Error decoding selected QR image: $e');
      }
    }
    return scanResult;
  }

  String? _processQRCodeImage(img.Image image) {
    final LuminanceSource source = RGBLuminanceSource(
        image.width,
        image.height,
        image
            .convert(numChannels: 4)
            .getBytes(order: img.ChannelOrder.abgr)
            .buffer
            .asInt32List());
    final bitmap = BinaryBitmap(GlobalHistogramBinarizer(source));

    try {
      final result = QRCodeReader().decode(bitmap);
      return result.text;
    } catch (e) {
      debugPrint('Error decoding QR code: $e');
      return null;
    }
  }

  Future<String?> _mobileQRScanner() async {
    String? result;
    bool hasScanned = false;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (routeContext) => Scaffold(
          appBar: AppBar(
            title: Text(routeContext.l10n.scanQrCodeTitle),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(routeContext).pop(),
            ),
          ),
          body: MobileScanner(
            onDetect: (capture) {
              if (hasScanned) return; // Prevent multiple scans
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  hasScanned = true;
                  result = barcode.rawValue;
                  Navigator.of(routeContext).pop();
                  return;
                }
              }
            },
          ),
        ),
      ),
    );

    if (!hasScanned) {
      result = null;
    }
    return result;
  }
}

class _OtpListEntry {
  const _OtpListEntry({
    required this.index,
    required this.uri,
  });

  final int index;
  final String uri;
}

class _EmptyOtpState extends StatelessWidget {
  const _EmptyOtpState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.password_rounded,
              size: 42,
              color: AppColors.muted(context),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.muted(context),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
