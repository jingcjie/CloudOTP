import 'package:cloud_otp/controllers/account_link_controller.dart';
import 'package:cloud_otp/utils/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_otp/models/otp_item.dart';
import 'dart:async';
import 'package:otp/otp.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:io' show Platform;
import 'package:file_picker/file_picker.dart';
import 'package:zxing2/qrcode.dart';
import 'package:image/image.dart' as img;
import 'package:cloud_otp/widgets/qr_code_dialog.dart';
import 'package:cloud_otp/models/snackbar.dart';
import 'package:provider/provider.dart';

class ListViewPage extends StatefulWidget {
  const ListViewPage({super.key});

  @override
  State<ListViewPage> createState() => _ListViewPageState();
}

class _ListViewPageState extends State<ListViewPage> {
  AccountLinkController? _controller;
  List<String> _cachedUris = [];
  List<OtpItem> otpItems = <OtpItem>[];
  List<String> currentOtps = <String>[];
  List<bool> _isExpanded = <bool>[];
  List<double> _progress = <double>[];
  List<Timer?> _timers = <Timer?>[];

  @override
  void initState() {
    super.initState();
    _initializeState(const [], notify: false);
  }

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

  void _onControllerChanged() {
    if (!mounted || _controller == null) return;
    final newUris = _controller!.otpUris;
    if (!listEquals(_cachedUris, newUris)) {
      _syncFromController();
    }
  }

  void _syncFromController() {
    final current = _controller?.otpUris ?? const <String>[];
    _cachedUris = List<String>.from(current);
    _initializeState(_cachedUris);
  }

  void _initializeState(List<String> source, {bool notify = true}) {
    _disposeTimers();
    try {
      final items = List<OtpItem>.from(source.map((uri) => OtpItem.fromUri(uri)));
      final expanded = List<bool>.filled(items.length, false, growable: true);
      final progress = List<double>.filled(items.length, 0.0, growable: true);
      final timers = List<Timer?>.filled(items.length, null, growable: true);
      final otps = List<String>.generate(items.length, (index) => '');

      for (var i = 0; i < items.length; i++) {
        otps[i] = _generateOtp(items[i]);
      }

      void apply() {
        otpItems = items;
        _isExpanded = expanded;
        _progress = progress;
        _timers = timers;
        currentOtps = otps;
      }

      if (notify && mounted) {
        setState(apply);
      } else {
        apply();
      }

      for (var i = 0; i < items.length; i++) {
        _resetAndStartTimer(i);
      }
    } catch (e, stack) {
      if (kDebugMode) {
        print('Error initializing OTP state: $e');
        print(stack);
      }

      void clear() {
        otpItems = <OtpItem>[];
        _isExpanded = <bool>[];
        _progress = <double>[];
        _timers = <Timer?>[];
        currentOtps = <String>[];
      }

      if (notify && mounted) {
        setState(clear);
      } else {
        clear();
      }
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onControllerChanged);
    _disposeTimers();
    super.dispose();
  }

  void _disposeTimers() {
    for (final timer in _timers) {
      timer?.cancel();
    }
    _timers = <Timer?>[];
  }

  void _resetAndStartTimer(int index) {
    if (index < 0 ||
        index >= _timers.length ||
        index >= otpItems.length ||
        index >= _progress.length) {
      return;
    }

    _timers[index]?.cancel();
    _progress[index] = 0.0;

    const updateInterval = Duration(milliseconds: 100);
    final totalDuration = Duration(seconds: otpItems[index].interval);
    var elapsed = Duration.zero;

    _timers[index] = Timer.periodic(updateInterval, (timer) {
      elapsed += updateInterval;
      if (!mounted || index >= _progress.length) {
        timer.cancel();
        return;
      }

      setState(() {
        final fraction = totalDuration.inMilliseconds == 0
            ? 1.0
            : elapsed.inMilliseconds / totalDuration.inMilliseconds;
        _progress[index] = fraction.clamp(0.0, 1.0).toDouble();
      });

      if (elapsed >= totalDuration) {
        timer.cancel();
        _refreshOtp(index);
      }
    });
  }

  void _refreshOtp(int index) {
    if (index < 0 || index >= otpItems.length || index >= currentOtps.length) return;

    final newCode = _generateOtp(otpItems[index]);
    if (!mounted) return;
    setState(() {
      currentOtps[index] = newCode;
    });
    _resetAndStartTimer(index);
  }

  Future<void> _addOtp(String uri) async {
    final controller = _controller;
    if (controller == null) return;
    try {
      await controller.addOtp(uri);
      if (!mounted) return;
      final message = controller.isLinked
          ? 'OTP saved locally. Use Backup Data to sync cloud.'
          : 'OTP saved locally.';
      context.showBeautifulSnackBar(message: message, isError: false);
    } catch (e) {
      if (!mounted) return;
      context.showBeautifulSnackBar(message: 'Failed to add OTP: $e', isError: true);
    }
  }

  String _generateOtp(OtpItem item) {
    try {
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      return OTP.generateTOTPCodeString(
        item.secret.toUpperCase(),
        currentTime,
        length: item.length,
        interval: item.interval,
        algorithm: item.algorithm,
        isGoogle: true,
      );
    } catch (e) {
      print('Error generating OTP: $e');
      return 'Error';
    }
  }



  void _copyOtp(int index) {
    if (index < 0 || index >= currentOtps.length) return;

    Clipboard.setData(ClipboardData(text: currentOtps[index]));
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(content: Text('OTP copied to clipboard')),
    // );

    context.showBeautifulSnackBar(message: 'OTP copied to clipboard.', isError: false);
  }


  void _exportOtp(BuildContext context, int index) {
    if (index < 0 || index >= _cachedUris.length) return;
    var singleOtpUri = _cachedUris[index];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return QRCodeDialog(uri: singleOtpUri);
      },
    );
  }

  Future<void> _deleteOtp(int index) async {
    final controller = _controller;
    if (controller == null) return;
    try {
      await controller.removeOtpAt(index);
      if (!mounted) return;
      context.showBeautifulSnackBar(message: 'Deleted successfully.', isError: false);
    } catch (e) {
      if (!mounted) return;
      context.showBeautifulSnackBar(message: 'Failed to delete OTP: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(
        title: 'OTP List',
        actions: [
          // Add any action buttons here if needed
        ],
      ),
      body: otpItems.isEmpty
          ? const Center(child: Text('No OTPs added yet. Tap the + button to add one.'))
          : ListView.builder(
        itemCount: otpItems.length,
        itemBuilder: (context, index) {
          if (index < 0 || index >= otpItems.length) {
            return const SizedBox.shrink();
          }
          final otpItem = otpItems[index];
          final code = index < currentOtps.length ? currentOtps[index] : '';
          final progress = index < _progress.length ? _progress[index] : 0.0;
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ExpansionTile(
              key: ValueKey(index < _cachedUris.length ? _cachedUris[index] : '$index'),
              initiallyExpanded: index < _isExpanded.length && _isExpanded[index],
              title: Text(
                otpItem.label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(otpItem.issuer),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.ios_share),
                    onPressed: () => _exportOtp(context, index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteOtp(index),
                  ),
                ],
              ),
              onExpansionChanged: (expanded) {
                if (index < 0 || index >= _isExpanded.length) {
                  return;
                }
                setState(() {
                  _isExpanded[index] = expanded;
                });
              },
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('OTP: $code', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Digits: ${otpItem.length}'),
                      Text('Interval: ${otpItem.interval}s'),
                      Text('Algorithm: ${otpItem.algorithm.toString().split('.').last}'),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0).toDouble(),
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () => _copyOtp(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () => _refreshOtp(index),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
            label: 'Manual Input',
            onTap: _manualInput,
          ),
          SpeedDialChild(
            child: const Icon(Icons.qr_code_scanner),
            label: 'QR Scanner',
            onTap: _qrScanner,
          ),
        ],
      ),
    );
  }

  void _manualInput() async {
    String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String secret = '';
        String label = '';
        String issuer = '';

        return AlertDialog(
          title: const Text('Manual Input'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Secret'),
                onChanged: (value) {
                  secret = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Label'),
                onChanged: (value) {
                  label = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Issuer (optional)'),
                onChanged: (value) {
                  issuer = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final uri = Uri(
                  scheme: 'otpauth',
                  host: 'totp',
                  path: label,
                  queryParameters: {
                    'secret': secret,
                    if (issuer.isNotEmpty) 'issuer': issuer,
                  },
                );
                Navigator.of(context).pop(uri.toString());
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    if (result != null) {
      await _addOtp(result);
    }
  }

  void _qrScanner() async {
    String? scannedData;
    if (kIsWeb){
      scannedData = await _webQRScanner();
    }else{
      if (Platform.isAndroid) {
        // Check for mobile platforms without using dart:io
        scannedData = await _mobileQRScanner();
      } else {
        // Web-specific implementation
        scannedData = await _webQRScanner();
      }
    }
    if (scannedData != null) {
      if (isValidOtpUri(scannedData)) {
        await _addOtp(scannedData);
      } else {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text('Invalid OTP QR code')),
        // );
        context.showBeautifulSnackBar(message: 'Invalid OTP QR code', isError: true);
      }
    }
  }

  Future<String?> _webQRScanner() async {
    String? string_result;
    // For web, we'll use file picker to select an image
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null) {
      Uint8List fileBytes = result.files.first.bytes!;
      img.Image? image = img.decodeImage(fileBytes);

      if (image != null) {
        string_result = _processQRCodeImage(image);
      }
    }
    return string_result;
  }

  String? _processQRCodeImage(img.Image image) {
    LuminanceSource source = RGBLuminanceSource(
        image.width,
        image.height,
        image
            .convert(numChannels: 4)
            .getBytes(order: img.ChannelOrder.abgr)
            .buffer
            .asInt32List());
    var bitmap = BinaryBitmap(GlobalHistogramBinarizer(source));

    try {
      var result = QRCodeReader().decode(bitmap);
      return result.text;
    } catch (e) {
      print('Error decoding QR code: $e');
      return null;
    }
  }




  Future<String?> _mobileQRScanner() async {
    String? result;
    bool hasScanned = false;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Scan QR Code'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
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
                  Navigator.of(context).pop(); // This should close the scanner page
                  return;
                }
              }
            },
          ),
        ),
      ),
    );

    // If we've reached this point and hasScanned is still false,
    // it means the user manually went back without scanning
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
    Key? key,
    required this.title,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade800.withOpacity(0.9),
            Colors.green.shade700.withOpacity(0.9),
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
