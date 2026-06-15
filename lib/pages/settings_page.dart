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
import '../theme/app_theme.dart';
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
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword(BuildContext context) async {
    final l10n = context.l10n;
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
              decoration:
                  InputDecoration(labelText: l10n.changePasswordNewLabel),
            ),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration:
                  InputDecoration(labelText: l10n.changePasswordConfirmLabel),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () async {
              if (_newPasswordController.text !=
                  _confirmPasswordController.text) {
                dialogContext.showBeautifulSnackBar(
                  message: l10n.passwordMismatch,
                  isError: true,
                );
                return;
              }
              try {
                await supabase.auth.updateUser(
                  UserAttributes(password: _newPasswordController.text),
                );
                if (dialogContext.mounted) {
                  dialogContext.showBeautifulSnackBar(
                    message: l10n.passwordChangedSuccess,
                    isError: false,
                  );
                  Navigator.of(dialogContext).pop();
                }
              } catch (error) {
                if (dialogContext.mounted) {
                  dialogContext.showBeautifulSnackBar(
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
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (!mounted) return;
      if (result == null) {
        return;
      }

      String fileContents;
      final file = result.files.single;

      if (!kIsWeb && file.path != null) {
        fileContents = await readOtpFile(file.path!);
        if (!mounted) return;
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
              onPressed: () =>
                  Navigator.of(dialogContext).pop(_ImportChoice.merge),
              child: Text(l10n.importMergeOption),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(_ImportChoice.replace),
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
    final currentLanguageCode =
        localeProvider.locale?.toLanguageTag() ?? 'system';
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
              icon: const Icon(Icons.cloud_queue_rounded),
              label: Text(l10n.linkAccount),
            ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
          _buildAccountPanel(context, controller),
          if (!isLinked) _buildLinkPrompt(context),
          if (isLinked)
            _buildSettingsSection(
              context,
              title: l10n.settingsAccountSection,
              children: [
                _buildSettingsTile(
                  context,
                  icon: Icons.lock_outline_rounded,
                  title: l10n.changePasswordTitle,
                  onTap: () => _changePassword(context),
                ),
              ],
            ),
          if (isLinked)
            _buildSettingsSection(
              context,
              title: l10n.settingsSyncSection,
              children: [
                _buildSettingsTile(
                  context,
                  icon: Icons.cloud_download_outlined,
                  title: l10n.pullData,
                  onTap: controller.isLoading
                      ? null
                      : () => _handlePull(controller),
                  trailing: controller.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.backup_outlined,
                  title: l10n.backupData,
                  onTap: controller.isLoading
                      ? null
                      : () => _handleBackup(controller),
                ),
              ],
            ),
          _buildSettingsSection(
            context,
            title: l10n.settingsAppearanceSection,
            children: [
              _buildSettingsTile(
                context,
                icon: Icons.brightness_medium_rounded,
                title: l10n.themeModeTitle,
                trailing: _buildThemeDropdown(context, themeProvider),
              ),
              _buildSettingsTile(
                context,
                icon: Icons.language_rounded,
                title: l10n.languageSettingTitle,
                subtitle: l10n.languageSettingSubtitle,
                trailing: _buildLanguageDropdown(
                  context,
                  localeProvider,
                  currentLanguageCode,
                  languageOptions,
                ),
              ),
            ],
          ),
          _buildSettingsSection(
            context,
            title: l10n.settingsDataSection,
            children: [
              _buildSettingsTile(
                context,
                icon: Icons.upload_file_rounded,
                title: l10n.exportData,
                onTap: () => _handleExport(controller),
              ),
              _buildSettingsTile(
                context,
                icon: Icons.download_rounded,
                title: l10n.importData,
                onTap: () => _handleImport(controller),
              ),
            ],
          ),
          if (isLinked)
            _buildSettingsSection(
              context,
              title: l10n.settingsDangerSection,
              children: [
                _buildSettingsTile(
                  context,
                  icon: Icons.delete_forever_rounded,
                  title: l10n.deleteAllCloudData,
                  onTap: controller.isLoading
                      ? null
                      : () => _handleDelete(controller),
                  destructive: true,
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.logout_rounded,
                  title: l10n.unlinkAccount,
                  onTap: controller.isLoading
                      ? null
                      : () => _handleUnlink(controller),
                  destructive: true,
                ),
              ],
            ),
          _buildAboutSection(context),
        ],
      ),
    );
  }

  Widget _buildAccountPanel(
    BuildContext context,
    AccountLinkController controller,
  ) {
    final l10n = context.l10n;
    final isLinked = controller.isLinked;
    final title = isLinked
        ? controller.linkedEmail ?? l10n.commonUnknown
        : l10n.offlineMode;
    final subtitle = isLinked ? l10n.connectedTo : l10n.workingOffline;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isLinked ? Icons.cloud_done_rounded : Icons.shield_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.muted(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _StatusPill(
            label: isLinked ? l10n.linkedBadge : l10n.offlineMode,
            linked: isLinked,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 8),
            child: Text(
              title,
              style: TextStyle(
                color: AppColors.muted(context),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Material(
            color: AppColors.surface(context),
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: AppColors.border(context)),
            ),
            child: Column(
              children: [
                for (var index = 0; index < children.length; index++) ...[
                  children[index],
                  if (index != children.length - 1)
                    Divider(indent: 64, color: AppColors.border(context)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool destructive = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = destructive ? colorScheme.error : colorScheme.primary;
    final enabled = onTap != null || trailing != null;

    return ListTile(
      enabled: enabled,
      minLeadingWidth: 40,
      leading: _SettingsIcon(icon: icon, color: accent),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: destructive ? colorScheme.error : null,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildThemeDropdown(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    final l10n = context.l10n;
    return SizedBox(
      width: 128,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ThemeMode>(
          value: themeProvider.themeMode,
          isExpanded: true,
          borderRadius: BorderRadius.circular(8),
          onChanged: (ThemeMode? newValue) {
            if (newValue != null) {
              themeProvider.setThemeMode(newValue);
            }
          },
          items: [
            DropdownMenuItem(
              value: ThemeMode.system,
              child: Text(l10n.themeSystem, overflow: TextOverflow.ellipsis),
            ),
            DropdownMenuItem(
              value: ThemeMode.light,
              child: Text(l10n.themeLight, overflow: TextOverflow.ellipsis),
            ),
            DropdownMenuItem(
              value: ThemeMode.dark,
              child: Text(l10n.themeDark, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageDropdown(
    BuildContext context,
    LocaleProvider localeProvider,
    String currentLanguageCode,
    Map<String, String> languageOptions,
  ) {
    return SizedBox(
      width: 150,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: languageOptions.containsKey(currentLanguageCode)
              ? currentLanguageCode
              : 'system',
          isExpanded: true,
          borderRadius: BorderRadius.circular(8),
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
                  child: Text(entry.value, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.aboutTitle,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.aboutDescription,
              style: TextStyle(
                color: AppColors.muted(context),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: _openRepository,
                icon: const Icon(Icons.open_in_new_rounded),
                label: Text(l10n.viewOnGithub),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openRepository() async {
    final l10n = context.l10n;
    final uri = Uri.parse('https://github.com/jingcjie/CloudOTP');
    try {
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
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

  Widget _buildLinkPrompt(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.elevated(context),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.linkPromptTitle,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.linkPromptDescription,
              style: TextStyle(
                color: AppColors.muted(context),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () => AccountLinkSheet.show(context),
                icon: const Icon(Icons.cloud_queue_rounded),
                label: Text(l10n.linkNow),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _ImportChoice { merge, replace }

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.linked,
  });

  final String label;
  final bool linked;

  @override
  Widget build(BuildContext context) {
    final color = linked
        ? Theme.of(context).colorScheme.primary
        : AppColors.muted(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: linked ? 0.16 : 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.26)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _SettingsIcon extends StatelessWidget {
  const _SettingsIcon({
    required this.icon,
    required this.color,
  });

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
