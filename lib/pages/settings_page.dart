import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../controllers/account_link_controller.dart';
import '../models/snackbar.dart';
import '../models/theme_provider.dart';
import '../utils/constants.dart';
import '../utils/file_saver.dart';
import '../utils/file_loader.dart';
import 'auth_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword(BuildContext context) async {
    final navigator = Navigator.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password'),
            ),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm New Password'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => navigator.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (_newPasswordController.text != _confirmPasswordController.text) {
                context.showBeautifulSnackBar(
                  message: 'Passwords do not match.',
                  isError: true,
                );
                return;
              }
              try {
                await supabase.auth.updateUser(
                  UserAttributes(password: _newPasswordController.text),
                );
                if (mounted) {
                  context.showBeautifulSnackBar(
                    message: 'Password changed successfully.',
                    isError: false,
                  );
                  navigator.pop();
                }
              } catch (error) {
                if (mounted) {
                  context.showBeautifulSnackBar(
                    message: 'Unexpected error: $error',
                    isError: true,
                  );
                }
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePull(AccountLinkController controller) async {
    final confirm = await _confirmAction(
      context,
      title: 'Confirm Pull Data',
      message: 'This will overwrite the data stored locally. Continue?',
    );
    if (confirm != true) return;

    try {
      final remoteData = await controller.pullFromCloud();
      if (!mounted) return;
      if (remoteData.isEmpty) {
        context.showBeautifulSnackBar(
          message: 'No data available in the cloud.',
          isError: false,
        );
      } else {
        context.showBeautifulSnackBar(
          message: 'Data pulled successfully.',
          isError: false,
        );
      }
    } catch (error) {
      if (!mounted) return;
      context.showBeautifulSnackBar(
        message: 'Failed to pull data: $error',
        isError: true,
      );
    }
  }

  Future<void> _handleBackup(AccountLinkController controller) async {
    final confirm = await _confirmAction(
      context,
      title: 'Confirm Backup Data',
      message: 'This will overwrite the data stored in the cloud. Continue?',
    );
    if (confirm != true) return;

    try {
      await controller.pushToCloud();
      if (!mounted) return;
      context.showBeautifulSnackBar(
        message: 'Data backed up successfully.',
        isError: false,
      );
    } catch (error) {
      if (!mounted) return;
      context.showBeautifulSnackBar(
        message: 'Failed to backup data: $error',
        isError: true,
      );
    }
  }

  Future<void> _handleDelete(AccountLinkController controller) async {
    final confirm = await _confirmAction(
      context,
      title: 'Delete Cloud Data',
      message: 'This will permanently delete your OTP data from the cloud. Continue?',
    );
    if (confirm != true) return;

    try {
      await controller.clearCloudData();
      if (!mounted) return;
      context.showBeautifulSnackBar(
        message: 'Cloud data cleared.',
        isError: false,
      );
    } catch (error) {
      if (!mounted) return;
      context.showBeautifulSnackBar(
        message: 'Failed to clear cloud data: $error',
        isError: true,
      );
    }
  }

  Future<void> _handleUnlink(AccountLinkController controller) async {
    final confirm = await _confirmAction(
      context,
      title: 'Unlink Account',
      message: 'You will remain in offline mode. Continue?',
    );
    if (confirm != true) return;

    try {
      await controller.unlinkAccount();
      if (!mounted) return;
      context.showBeautifulSnackBar(
        message: 'Account unlinked. You are now working offline.',
        isError: false,
      );
    } catch (error) {
      if (!mounted) return;
      context.showBeautifulSnackBar(
        message: 'Failed to unlink account: $error',
        isError: true,
      );
    }
  }

  Future<void> _handleExport(AccountLinkController controller) async {
    if (controller.otpUris.isEmpty) {
      context.showBeautifulSnackBar(
        message: 'No OTP entries to export.',
        isError: false,
      );
      return;
    }

    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final defaultFileName = 'cloud_otp_backup_$timestamp.json';

    try {
      final savedLocation = await saveOtpJson(
        suggestedName: defaultFileName,
        contents: jsonEncode(controller.rawOtpUris),
      );
      if (!mounted) return;
      if (savedLocation == null) {
        context.showBeautifulSnackBar(
          message: 'Export cancelled.',
          isError: false,
        );
      } else {
        final message = kIsWeb
            ? 'Download started: $defaultFileName'
            : 'Exported to $savedLocation';
        context.showBeautifulSnackBar(
          message: message,
          isError: false,
        );
      }
    } catch (error) {
      if (!mounted) return;
      context.showBeautifulSnackBar(
        message: 'Failed to export: $error',
        isError: true,
      );
    }
  }

  Future<void> _handleImport(AccountLinkController controller) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result == null) {
        return;
      }

      String fileContents;
      final file = result.files.single;

      if (!kIsWeb && file.path != null) {
        fileContents = await readOtpFile(file.path!);
      } else if (file.bytes != null) {
        fileContents = utf8.decode(file.bytes!);
      } else {
        context.showBeautifulSnackBar(
          message: 'Unable to read selected file.',
          isError: true,
        );
        return;
      }

      dynamic decoded;
      try {
        decoded = jsonDecode(fileContents);
      } catch (_) {
        context.showBeautifulSnackBar(
          message: 'Invalid file format.',
          isError: true,
        );
        return;
      }

      if (decoded is! List) {
        context.showBeautifulSnackBar(
          message: 'Selected file does not contain OTP data.',
          isError: true,
        );
        return;
      }

      final parsed = <String>[];
      for (final entry in decoded) {
        if (entry is String && isValidOtpUri(entry)) {
          parsed.add(entry);
        } else {
          context.showBeautifulSnackBar(
            message: 'File contains invalid OTP entries.',
            isError: true,
          );
          return;
        }
      }

      if (parsed.isEmpty) {
        context.showBeautifulSnackBar(
          message: 'No OTP entries found in file.',
          isError: false,
        );
        return;
      }

      final choice = await showDialog<_ImportChoice>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Import options'),
          content: const Text(
            'Would you like to merge the imported OTPs with your existing list, or replace the current list entirely?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(_ImportChoice.merge),
              child: const Text('Merge'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(_ImportChoice.replace),
              child: const Text('Replace'),
            ),
          ],
        ),
      );

      if (choice == null) {
        return;
      }

      if (choice == _ImportChoice.replace) {
        await controller.replaceLocalWith(parsed);
        if (mounted) {
          context.showBeautifulSnackBar(
            message: 'OTP list replaced with imported data.',
            isError: false,
          );
        }
      } else {
        await controller.mergeWith(parsed);
        if (mounted) {
          context.showBeautifulSnackBar(
            message: 'Imported OTP entries merged.',
            isError: false,
          );
        }
      }
    } catch (error) {
      if (!mounted) return;
      context.showBeautifulSnackBar(
        message: 'Failed to import: $error',
        isError: true,
      );
    }
  }

  Future<bool?> _confirmAction(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Proceed'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final controller = context.watch<AccountLinkController>();
    final isLinked = controller.isLinked;

    return Scaffold(
      floatingActionButton: isLinked
          ? null
          : FloatingActionButton.extended(
              onPressed: () => AccountLinkSheet.show(context),
              icon: const Icon(Icons.cloud_queue),
              label: const Text('Link account'),
            ),
      body: ListView(
        children: [
          _buildTopBanner(context, controller),
          if (!isLinked) _buildLinkPrompt(context),
          if (isLinked) _buildCloudStatusRow(controller),
          if (isLinked)
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Change Password'),
              onTap: () => _changePassword(context),
            ),
          if (isLinked)
            ListTile(
              leading: const Icon(Icons.cloud_download),
              title: const Text('Pull Data'),
              onTap: controller.isLoading ? null : () => _handlePull(controller),
              trailing: controller.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
            ),
          if (isLinked)
            ListTile(
              leading: const Icon(Icons.backup),
              title: const Text('Backup Data'),
              onTap: controller.isLoading ? null : () => _handleBackup(controller),
            ),
          ListTile(
            leading: const Icon(Icons.brightness_medium),
            title: const Text('Theme Mode'),
            trailing: DropdownButton<ThemeMode>(
              value: themeProvider.themeMode,
              onChanged: (ThemeMode? newValue) {
                if (newValue != null) {
                  themeProvider.setThemeMode(newValue);
                }
              },
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('System'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text('Light'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text('Dark'),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.file_upload),
            title: const Text('Export Data'),
            onTap: () => _handleExport(controller),
          ),
          ListTile(
            leading: const Icon(Icons.file_download),
            title: const Text('Import Data'),
            onTap: () => _handleImport(controller),
          ),
          if (isLinked)
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text(
                'Delete All Cloud Data',
                style: TextStyle(color: Colors.red),
              ),
              onTap: controller.isLoading ? null : () => _handleDelete(controller),
            ),
          if (isLinked)
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Unlink Account',
                style: TextStyle(color: Colors.red),
              ),
              onTap: controller.isLoading ? null : () => _handleUnlink(controller),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTopBanner(BuildContext context, AccountLinkController controller) {
    final isLinked = controller.isLinked;
    final subtitle = isLinked ? controller.linkedEmail ?? '' : 'Offline mode';

    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColorLight,
            Theme.of(context).primaryColorDark.withOpacity(0.6),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 20,
            left: 20,
            child: Icon(
              Icons.account_circle,
              size: 80,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLinked ? 'Connected to' : 'Working offline',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle.isEmpty ? 'Cloud OTP' : subtitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (isLinked)
            Positioned(
              top: 20,
              right: 20,
              child: Chip(
                avatar: const Icon(Icons.cloud_done, color: Colors.white, size: 16),
                backgroundColor: Colors.green.withOpacity(0.8),
                label: const Text(
                  'Linked',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLinkPrompt(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Link a cloud account',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your OTP secrets are stored locally. Link a cloud account to enable secure backups.',
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => AccountLinkSheet.show(context),
                  icon: const Icon(Icons.cloud_queue),
                  label: const Text('Link now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCloudStatusRow(AccountLinkController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.cloud_done, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Cloud account linked as ${controller.linkedEmail ?? 'unknown'}',
            ),
          ),
        ],
      ),
    );
  }
}

enum _ImportChoice { merge, replace }
