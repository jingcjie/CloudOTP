import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/account_link_controller.dart';
import '../models/snackbar.dart';
import '../models/theme_provider.dart';
import '../models/locale_provider.dart';
import '../utils/constants.dart';
import '../utils/file_saver.dart';
import '../utils/file_loader.dart';
import '../utils/l10n_extensions.dart';
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
    final l10n = context.l10n;
    final navigator = Navigator.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.changePasswordTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: l10n.changePasswordNewLabel),
            ),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: l10n.changePasswordConfirmLabel),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => navigator.pop(),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () async {
              if (_newPasswordController.text != _confirmPasswordController.text) {
                context.showBeautifulSnackBar(
                  message: l10n.passwordMismatch,
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
                    message: l10n.passwordChangedSuccess,
                    isError: false,
                  );
                  navigator.pop();
                }
              } catch (error) {
                if (mounted) {
                  context.showBeautifulSnackBar(
                    message: l10n.unexpectedError('$error'),
                    isError: true,
                  );
                }
              }
            },
            child: Text(l10n.commonSubmit),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePull(AccountLinkController controller) async {
    final l10n = context.l10n;
    final confirm = await _confirmAction(
      context,
      title: l10n.confirmPullTitle,
      message: l10n.confirmPullMessage,
    );
    if (confirm != true) return;

    try {
      final remoteData = await controller.pullFromCloud();
      if (!mounted) return;
      if (remoteData.isEmpty) {
        context.showBeautifulSnackBar(
          message: l10n.cloudNoData,
          isError: false,
        );
      } else {
        context.showBeautifulSnackBar(
          message: l10n.cloudPullSuccess,
          isError: false,
        );
      }
    } catch (error) {
      if (!mounted) return;
      context.showBeautifulSnackBar(
        message: l10n.cloudPullFailed('$error'),
        isError: true,
      );
    }
  }

  Future<void> _handleBackup(AccountLinkController controller) async {
    final l10n = context.l10n;
    final confirm = await _confirmAction(
      context,
      title: l10n.confirmBackupTitle,
      message: l10n.confirmBackupMessage,
    );
    if (confirm != true) return;

    try {
      await controller.pushToCloud();
      if (!mounted) return;
      context.showBeautifulSnackBar(
        message: l10n.cloudBackupSuccess,
        isError: false,
      );
    } catch (error) {
      if (!mounted) return;
      context.showBeautifulSnackBar(
        message: l10n.cloudBackupFailed('$error'),
        isError: true,
      );
    }
  }

  Future<void> _handleDelete(AccountLinkController controller) async {
    final l10n = context.l10n;
    final confirm = await _confirmAction(
      context,
      title: l10n.confirmDeleteTitle,
      message: l10n.confirmDeleteMessage,
    );
    if (confirm != true) return;

    try {
      await controller.clearCloudData();
      if (!mounted) return;
      context.showBeautifulSnackBar(
        message: l10n.cloudDeleteSuccess,
        isError: false,
      );
    } catch (error) {
      if (!mounted) return;
      context.showBeautifulSnackBar(
        message: l10n.cloudDeleteFailed('$error'),
        isError: true,
      );
    }
  }

  Future<void> _handleUnlink(AccountLinkController controller) async {
    final l10n = context.l10n;
    final confirm = await _confirmAction(
      context,
      title: l10n.confirmUnlinkTitle,
      message: l10n.confirmUnlinkMessage,
    );
    if (confirm != true) return;

    try {
      await controller.unlinkAccount();
      if (!mounted) return;
      context.showBeautifulSnackBar(
        message: l10n.unlinkSuccess,
        isError: false,
      );
    } catch (error) {
      if (!mounted) return;
      context.showBeautifulSnackBar(
        message: l10n.unlinkFailed('$error'),
        isError: true,
      );
    }
  }

  Future<void> _handleExport(AccountLinkController controller) async {
    final l10n = context.l10n;
    if (controller.otpUris.isEmpty) {
      context.showBeautifulSnackBar(
        message: l10n.noOtpToExport,
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
          message: l10n.exportCancelled,
          isError: false,
        );
      } else {
        final message = kIsWeb
            ? l10n.exportDownloadStarted(defaultFileName)
            : l10n.exportSavedTo(savedLocation);
        context.showBeautifulSnackBar(
          message: message,
          isError: false,
        );
      }
    } catch (error) {
      if (!mounted) return;
      context.showBeautifulSnackBar(
        message: l10n.exportFailed('$error'),
        isError: true,
      );
    }
  }

  Future<void> _handleImport(AccountLinkController controller) async {
    final l10n = context.l10n;
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
          message: l10n.unableToReadFile,
          isError: true,
        );
        return;
      }

      dynamic decoded;
      try {
        decoded = jsonDecode(fileContents);
      } catch (_) {
        context.showBeautifulSnackBar(
          message: l10n.invalidFileFormat,
          isError: true,
        );
        return;
      }

      if (decoded is! List) {
        context.showBeautifulSnackBar(
          message: l10n.fileDoesNotContainOtp,
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
            message: l10n.fileContainsInvalidOtpEntries,
            isError: true,
          );
          return;
        }
      }

      if (parsed.isEmpty) {
        context.showBeautifulSnackBar(
          message: l10n.fileContainsNoEntries,
          isError: false,
        );
        return;
      }

      final choice = await showDialog<_ImportChoice>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.importOptionsTitle),
          content: Text(l10n.importOptionsMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.commonCancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(_ImportChoice.merge),
              child: Text(l10n.importMergeOption),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(_ImportChoice.replace),
              child: Text(l10n.importReplaceOption),
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
            message: l10n.importReplaceSuccess,
            isError: false,
          );
        }
      } else {
        await controller.mergeWith(parsed);
        if (mounted) {
          context.showBeautifulSnackBar(
            message: l10n.importMergeSuccess,
            isError: false,
          );
        }
      }
    } catch (error) {
      if (!mounted) return;
      context.showBeautifulSnackBar(
        message: l10n.importFailed('$error'),
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
      builder: (dialogContext) {
        final l10n = dialogContext.l10n;
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.commonCancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.commonProceed),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final controller = context.watch<AccountLinkController>();
    final localeProvider = context.watch<LocaleProvider>();
    final l10n = context.l10n;
    final isLinked = controller.isLinked;
    final currentLanguageCode = localeProvider.locale?.toLanguageTag() ?? 'system';
    final languageOptions = <String, String>{
      'system': l10n.languageSystemDefault,
      'en': l10n.languageEnglish,
      'es': l10n.languageSpanish,
      'fr': l10n.languageFrench,
      'de': l10n.languageGerman,
      'zh': l10n.languageChineseSimplified,
    };

    return Scaffold(
      floatingActionButton: isLinked
          ? null
          : FloatingActionButton.extended(
              onPressed: () => AccountLinkSheet.show(context),
              icon: const Icon(Icons.cloud_queue),
              label: Text(l10n.linkAccount),
            ),
      body: ListView(
        children: [
          _buildTopBanner(context, controller),
          if (!isLinked) _buildLinkPrompt(context),
          if (isLinked) _buildCloudStatusRow(context, controller),
          if (isLinked)
            ListTile(
              leading: const Icon(Icons.lock),
              title: Text(l10n.changePasswordTitle),
              onTap: () => _changePassword(context),
            ),
          if (isLinked)
            ListTile(
              leading: const Icon(Icons.cloud_download),
              title: Text(l10n.pullData),
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
              title: Text(l10n.backupData),
              onTap: controller.isLoading ? null : () => _handleBackup(controller),
            ),
          ListTile(
            leading: const Icon(Icons.brightness_medium),
            title: Text(l10n.themeModeTitle),
            trailing: DropdownButtonHideUnderline(
              child: DropdownButton<ThemeMode>(
                value: themeProvider.themeMode,
                borderRadius: BorderRadius.circular(12),
                onChanged: (ThemeMode? newValue) {
                  if (newValue != null) {
                    themeProvider.setThemeMode(newValue);
                  }
                },
                items: [
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text(l10n.themeSystem),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text(l10n.themeLight),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: Text(l10n.themeDark),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.languageSettingTitle),
            subtitle: Text(l10n.languageSettingSubtitle),
            trailing: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: languageOptions.containsKey(currentLanguageCode)
                    ? currentLanguageCode
                    : 'system',
                borderRadius: BorderRadius.circular(12),
                onChanged: (String? value) {
                  if (value == null) return;
                  if (value == 'system') {
                    localeProvider.setLocale(null);
                  } else {
                    final selectedLocale = LocaleProvider.supportedLocales.firstWhere(
                      (locale) => locale.toLanguageTag() == value,
                      orElse: () => LocaleProvider.supportedLocales.first,
                    );
                    localeProvider.setLocale(selectedLocale);
                  }
                },
                items: languageOptions.entries
                    .map(
                      (entry) => DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(entry.value),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.file_upload),
            title: Text(l10n.exportData),
            onTap: () => _handleExport(controller),
          ),
          ListTile(
            leading: const Icon(Icons.file_download),
            title: Text(l10n.importData),
            onTap: () => _handleImport(controller),
          ),
          if (isLinked)
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: Text(
                l10n.deleteAllCloudData,
                style: const TextStyle(color: Colors.red),
              ),
              onTap: controller.isLoading ? null : () => _handleDelete(controller),
            ),
          if (isLinked)
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(
                l10n.unlinkAccount,
                style: const TextStyle(color: Colors.red),
              ),
              onTap: controller.isLoading ? null : () => _handleUnlink(controller),
            ),
          _buildAboutSection(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.aboutTitle,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.aboutDescription,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: () => _openRepository(context),
                  icon: const Icon(Icons.open_in_new),
                  label: Text(l10n.viewOnGithub),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openRepository(BuildContext context) async {
    final l10n = context.l10n;
    final uri = Uri.parse('https://github.com/jingcjie/CloudOTP');
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!mounted) return;
      if (!launched) {
        context.showBeautifulSnackBar(
          message: l10n.couldNotOpenRepository,
          isError: true,
        );
      }
    } catch (error) {
      if (!mounted) return;
      context.showBeautifulSnackBar(
        message: l10n.unexpectedError('$error'),
        isError: true,
      );
    }
  }

  Widget _buildTopBanner(BuildContext context, AccountLinkController controller) {
    final l10n = context.l10n;
    final isLinked = controller.isLinked;
    final subtitle = isLinked ? controller.linkedEmail ?? '' : l10n.offlineMode;

    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColorLight,
            Theme.of(context).primaryColorDark.withValues(alpha: 0.6),
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
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLinked ? l10n.connectedTo : l10n.workingOffline,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle.isEmpty ? l10n.appTitle : subtitle,
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
                backgroundColor: Colors.green.withValues(alpha: 0.8),
                label: Text(
                  l10n.linkedBadge,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLinkPrompt(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.linkPromptTitle,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.linkPromptDescription,
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => AccountLinkSheet.show(context),
                  icon: const Icon(Icons.cloud_queue),
                  label: Text(l10n.linkNow),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCloudStatusRow(BuildContext context, AccountLinkController controller) {
    final l10n = context.l10n;
    final email = controller.linkedEmail ?? l10n.commonUnknown;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.cloud_done, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.cloudAccountLinkedAs(email),
            ),
          ),
        ],
      ),
    );
  }
}

enum _ImportChoice { merge, replace }
