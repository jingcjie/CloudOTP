import 'package:cloud_otp/controllers/account_link_controller.dart';
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
    await _controller?.updateOtpAt(index, uri);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: GradientAppBar(title: l10n.otpListTitle),
      body: _cachedUris.isEmpty
          ? Center(child: Text(l10n.emptyOtpListHint))
          : ListView.builder(
              itemCount: _cachedUris.length,
              itemBuilder: (context, index) {
                final uri = _cachedUris[index];
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
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.input),
            label: l10n.manualInput,
            onTap: _manualInput,
          ),
          SpeedDialChild(
            child: const Icon(Icons.qr_code_scanner),
            label: l10n.qrScanner,
            onTap: _qrScanner,
          ),
        ],
      ),
    );
  }

  /// Renders a row for an entry whose URI could not be parsed, so one bad entry
  /// can be removed without the whole list failing to load.
  Widget _buildErrorTile(int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.error_outline),
        title: Text(context.l10n.otpErrorPlaceholder),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
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
      final Uint8List fileBytes = result.files.first.bytes!;
      final img.Image? image = img.decodeImage(fileBytes);
      if (image != null) {
        scanResult = _processQRCodeImage(image);
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

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const GradientAppBar({
    super.key,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade800.withValues(alpha: 0.9),
            Colors.green.shade700.withValues(alpha: 0.9),
          ],
        ),
      ),
      child: AppBar(
        title: Text(title),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: actions,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
