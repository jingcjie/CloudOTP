import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_otp/utils/l10n_extensions.dart';

class QRCodeDialog extends StatelessWidget {
  final String uri;

  const QRCodeDialog({super.key, required this.uri});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.8,
          maxHeight: MediaQuery.sizeOf(context).height * 0.8,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: QrImageView(
                    data: uri,
                    version: QrVersions.auto,
                    size: 200.0,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.scanQrCodeTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: uri));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.uriCopiedToClipboard)),
                        );
                      },
                      icon: const Icon(Icons.copy),
                      label: Text(l10n.copyUri),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: isDarkMode ? Colors.black : Colors.white,
                        backgroundColor: isDarkMode ? Colors.white70 : Colors.blue,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      label: Text(l10n.closeButtonLabel),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: isDarkMode ? Colors.black : Colors.white,
                        backgroundColor: isDarkMode ? Colors.white70 : Colors.red,
                      ),
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
}
//
// class QRCodeDialog extends StatelessWidget {
//   final String uri;
//
//   const QRCodeDialog({super.key, required this.uri});
//
//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       child: ConstrainedBox(
//         constraints: BoxConstraints(
//           maxWidth: MediaQuery.sizeOf(context).width * 0.4,
//           maxHeight: MediaQuery.sizeOf(context).height * 0.8,
//         ),
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 QrImageView(
//                   data: uri,
//                   version: QrVersions.auto,
//                   size: 200.0,
//                 ),
//                 const SizedBox(height: 20),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     ElevatedButton(
//                       onPressed: () {
//                         Clipboard.setData(ClipboardData(text: uri));
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('URI copied to clipboard')),
//                         );
//                       },
//                       child: const Text('Copy URI'),
//                     ),
//                     ElevatedButton(
//                       onPressed: () => Navigator.of(context).pop(),
//                       child: const Text('Close'),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
