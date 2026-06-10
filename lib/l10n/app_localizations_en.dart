// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Cloud OTP';

  @override
  String get navList => 'List';

  @override
  String get navSettings => 'Settings';

  @override
  String get scanQrCodeTitle => 'Scan QR Code';

  @override
  String get uriCopiedToClipboard => 'URI copied to clipboard';

  @override
  String get copyUri => 'Copy URI';

  @override
  String get closeButtonLabel => 'Close';

  @override
  String get otpSavedWithBackupHint =>
      'OTP saved locally. Use Backup Data to sync cloud.';

  @override
  String get otpSaved => 'OTP saved locally.';

  @override
  String failedToAddOtp(String error) {
    return 'Failed to add OTP: $error';
  }

  @override
  String get otpCopied => 'OTP copied to clipboard.';

  @override
  String get deletedSuccessfully => 'Deleted successfully.';

  @override
  String failedToDeleteOtp(String error) {
    return 'Failed to delete OTP: $error';
  }

  @override
  String get otpListTitle => 'OTP List';

  @override
  String get emptyOtpListHint =>
      'No OTPs added yet. Tap the + button to add one.';

  @override
  String otpCodeLabel(String code) {
    return 'OTP: $code';
  }

  @override
  String otpDigitsLabel(int digits) {
    return 'Digits: $digits';
  }

  @override
  String otpIntervalLabel(int seconds) {
    return 'Interval: ${seconds}s';
  }

  @override
  String otpAlgorithmLabel(String algorithm) {
    return 'Algorithm: $algorithm';
  }

  @override
  String hotpCounterLabel(int counter) {
    return 'Counter: $counter';
  }

  @override
  String get hotpCopyAdvanceTooltip => 'Copy and advance';

  @override
  String get hotpAdvanceTooltip => 'Advance counter';

  @override
  String get manualInput => 'Manual Input';

  @override
  String get qrScanner => 'QR Scanner';

  @override
  String get manualInputTitle => 'Manual Input';

  @override
  String get secretFieldLabel => 'Secret';

  @override
  String get labelFieldLabel => 'Label';

  @override
  String get issuerFieldLabel => 'Issuer (optional)';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get invalidOtpQr => 'Invalid OTP QR code';

  @override
  String get changePasswordTitle => 'Change Password';

  @override
  String get changePasswordNewLabel => 'New Password';

  @override
  String get changePasswordConfirmLabel => 'Confirm New Password';

  @override
  String get passwordMismatch => 'Passwords do not match.';

  @override
  String get passwordChangedSuccess => 'Password changed successfully.';

  @override
  String unexpectedError(String error) {
    return 'Unexpected error: $error';
  }

  @override
  String deviceClockSkewWarning(int seconds) {
    return 'Device clock differs from server by ${seconds}s. OTP codes may be wrong. Sync system time.';
  }

  @override
  String get commonSubmit => 'Submit';

  @override
  String get confirmPullTitle => 'Confirm Pull Data';

  @override
  String get confirmPullMessage =>
      'This will overwrite the data stored locally. Continue?';

  @override
  String get cloudNoData => 'No data available in the cloud.';

  @override
  String get cloudPullSuccess => 'Data pulled successfully.';

  @override
  String cloudPullFailed(String error) {
    return 'Failed to pull data: $error';
  }

  @override
  String get confirmBackupTitle => 'Confirm Backup Data';

  @override
  String get confirmBackupMessage =>
      'This will overwrite the data stored in the cloud. Continue?';

  @override
  String get cloudBackupSuccess => 'Data backed up successfully.';

  @override
  String cloudBackupFailed(String error) {
    return 'Failed to back up data: $error';
  }

  @override
  String get confirmDeleteTitle => 'Delete Cloud Data';

  @override
  String get confirmDeleteMessage =>
      'This will permanently delete your OTP data from the cloud. Continue?';

  @override
  String get cloudDeleteSuccess => 'Cloud data cleared.';

  @override
  String cloudDeleteFailed(String error) {
    return 'Failed to clear cloud data: $error';
  }

  @override
  String get confirmUnlinkTitle => 'Unlink Account';

  @override
  String get confirmUnlinkMessage =>
      'You will remain in offline mode. Continue?';

  @override
  String get unlinkSuccess => 'Account unlinked. You are now working offline.';

  @override
  String unlinkFailed(String error) {
    return 'Failed to unlink account: $error';
  }

  @override
  String get noOtpToExport => 'No OTP entries to export.';

  @override
  String get exportCancelled => 'Export cancelled.';

  @override
  String exportDownloadStarted(String filename) {
    return 'Download started: $filename';
  }

  @override
  String exportSavedTo(String location) {
    return 'Exported to $location';
  }

  @override
  String exportFailed(String error) {
    return 'Failed to export: $error';
  }

  @override
  String get unableToReadFile => 'Unable to read selected file.';

  @override
  String get invalidFileFormat => 'Invalid file format.';

  @override
  String get fileDoesNotContainOtp =>
      'Selected file does not contain OTP data.';

  @override
  String get fileContainsInvalidOtpEntries =>
      'File contains invalid OTP entries.';

  @override
  String get fileContainsNoEntries => 'No OTP entries found in file.';

  @override
  String get importOptionsTitle => 'Import options';

  @override
  String get importOptionsMessage =>
      'Would you like to merge the imported OTPs with your existing list, or replace the current list entirely?';

  @override
  String get importMergeOption => 'Merge';

  @override
  String get importReplaceOption => 'Replace';

  @override
  String get importReplaceSuccess => 'OTP list replaced with imported data.';

  @override
  String get importMergeSuccess => 'Imported OTP entries merged.';

  @override
  String importFailed(String error) {
    return 'Failed to import: $error';
  }

  @override
  String get commonProceed => 'Proceed';

  @override
  String get linkAccount => 'Link account';

  @override
  String get pullData => 'Pull Data';

  @override
  String get backupData => 'Backup Data';

  @override
  String get themeModeTitle => 'Theme Mode';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get languageSettingTitle => 'Language';

  @override
  String get languageSettingSubtitle => 'Choose a display language.';

  @override
  String get languageSystemDefault => 'System default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get languageFrench => 'French';

  @override
  String get languageGerman => 'German';

  @override
  String get languageChineseSimplified => 'Chinese (Simplified)';

  @override
  String get exportData => 'Export Data';

  @override
  String get importData => 'Import Data';

  @override
  String get deleteAllCloudData => 'Delete All Cloud Data';

  @override
  String get unlinkAccount => 'Unlink Account';

  @override
  String get aboutTitle => 'About CloudOTP';

  @override
  String get aboutDescription =>
      'CloudOTP is an open-source authenticator that keeps your OTP secrets secure with optional cloud sync.';

  @override
  String get viewOnGithub => 'View on GitHub';

  @override
  String get couldNotOpenRepository => 'Could not open the repository.';

  @override
  String get offlineMode => 'Offline mode';

  @override
  String get connectedTo => 'Connected to';

  @override
  String get workingOffline => 'Working offline';

  @override
  String get linkedBadge => 'Linked';

  @override
  String get linkPromptTitle => 'Link a cloud account';

  @override
  String get linkPromptDescription =>
      'Your OTP secrets are stored locally. Link a cloud account to enable secure backups.';

  @override
  String get linkNow => 'Link now';

  @override
  String get commonUnknown => 'unknown';

  @override
  String cloudAccountLinkedAs(String email) {
    return 'Cloud account linked as $email';
  }

  @override
  String get accountLinkedSuccessfully => 'Account linked successfully.';

  @override
  String get accountCreatedCheckEmail =>
      'Account created. Check your email to confirm.';

  @override
  String authenticationFailed(String error) {
    return 'Authentication failed: $error';
  }

  @override
  String get useCloudDataTitle => 'Use cloud data?';

  @override
  String useCloudDataMessage(int remoteCount) {
    return 'Cloud backup contains $remoteCount item(s). Do you want to replace your local entries with the cloud data?';
  }

  @override
  String get keepLocalButton => 'Keep local';

  @override
  String get useCloudDataButton => 'Use cloud data';

  @override
  String get linkAccountButton => 'Link Account';

  @override
  String get createAccountButton => 'Create Account';

  @override
  String get linkCloudAccountTitle => 'Link cloud account';

  @override
  String get createCloudAccountTitle => 'Create cloud account';

  @override
  String get linkCloudAccountSubtitle =>
      'Sign in to sync your OTP secrets securely.';

  @override
  String get createCloudAccountSubtitle =>
      'Create an account to enable secure backups.';

  @override
  String get emailFieldLabel => 'Email';

  @override
  String get enterYourEmail => 'Enter your email';

  @override
  String get passwordFieldLabel => 'Password';

  @override
  String get enterYourPassword => 'Enter your password';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get needAccountSignUp => 'Need an account? Sign up';

  @override
  String get haveAccountSignIn => 'Already have an account? Sign in';

  @override
  String get continueOffline => 'Continue offline';

  @override
  String get otpErrorPlaceholder => 'Error';
}
