import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('de'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Cloud OTP'**
  String get appTitle;

  /// No description provided for @navList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get navList;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @scanQrCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scanQrCodeTitle;

  /// No description provided for @uriCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'URI copied to clipboard'**
  String get uriCopiedToClipboard;

  /// No description provided for @copyUri.
  ///
  /// In en, this message translates to:
  /// **'Copy URI'**
  String get copyUri;

  /// No description provided for @closeButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeButtonLabel;

  /// No description provided for @otpSavedWithBackupHint.
  ///
  /// In en, this message translates to:
  /// **'OTP saved locally. Use Backup Data to sync cloud.'**
  String get otpSavedWithBackupHint;

  /// No description provided for @otpSaved.
  ///
  /// In en, this message translates to:
  /// **'OTP saved locally.'**
  String get otpSaved;

  /// No description provided for @failedToAddOtp.
  ///
  /// In en, this message translates to:
  /// **'Failed to add OTP: {error}'**
  String failedToAddOtp(String error);

  /// No description provided for @otpCopied.
  ///
  /// In en, this message translates to:
  /// **'OTP copied to clipboard.'**
  String get otpCopied;

  /// No description provided for @deletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Deleted successfully.'**
  String get deletedSuccessfully;

  /// No description provided for @failedToDeleteOtp.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete OTP: {error}'**
  String failedToDeleteOtp(String error);

  /// No description provided for @otpListTitle.
  ///
  /// In en, this message translates to:
  /// **'OTP List'**
  String get otpListTitle;

  /// No description provided for @emptyOtpListHint.
  ///
  /// In en, this message translates to:
  /// **'No OTPs added yet. Tap the + button to add one.'**
  String get emptyOtpListHint;

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No matching OTPs.'**
  String get searchNoResults;

  /// No description provided for @otpCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'OTP: {code}'**
  String otpCodeLabel(String code);

  /// No description provided for @otpDigitsLabel.
  ///
  /// In en, this message translates to:
  /// **'Digits: {digits}'**
  String otpDigitsLabel(int digits);

  /// No description provided for @otpIntervalLabel.
  ///
  /// In en, this message translates to:
  /// **'Interval: {seconds}s'**
  String otpIntervalLabel(int seconds);

  /// No description provided for @otpAlgorithmLabel.
  ///
  /// In en, this message translates to:
  /// **'Algorithm: {algorithm}'**
  String otpAlgorithmLabel(String algorithm);

  /// No description provided for @hotpCounterLabel.
  ///
  /// In en, this message translates to:
  /// **'Counter: {counter}'**
  String hotpCounterLabel(int counter);

  /// No description provided for @hotpCopyAdvanceTooltip.
  ///
  /// In en, this message translates to:
  /// **'Copy and advance'**
  String get hotpCopyAdvanceTooltip;

  /// No description provided for @hotpAdvanceTooltip.
  ///
  /// In en, this message translates to:
  /// **'Advance counter'**
  String get hotpAdvanceTooltip;

  /// No description provided for @manualInput.
  ///
  /// In en, this message translates to:
  /// **'Manual Input'**
  String get manualInput;

  /// No description provided for @qrScanner.
  ///
  /// In en, this message translates to:
  /// **'QR Scanner'**
  String get qrScanner;

  /// No description provided for @manualInputTitle.
  ///
  /// In en, this message translates to:
  /// **'Manual Input'**
  String get manualInputTitle;

  /// No description provided for @secretFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Secret'**
  String get secretFieldLabel;

  /// No description provided for @labelFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get labelFieldLabel;

  /// No description provided for @issuerFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Issuer (optional)'**
  String get issuerFieldLabel;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @invalidOtpQr.
  ///
  /// In en, this message translates to:
  /// **'Invalid OTP QR code'**
  String get invalidOtpQr;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordTitle;

  /// No description provided for @changePasswordNewLabel.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get changePasswordNewLabel;

  /// No description provided for @changePasswordConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get changePasswordConfirmLabel;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordMismatch;

  /// No description provided for @passwordChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully.'**
  String get passwordChangedSuccess;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error: {error}'**
  String unexpectedError(String error);

  /// No description provided for @deviceClockSkewWarning.
  ///
  /// In en, this message translates to:
  /// **'Device clock differs from server by {seconds}s. OTP codes may be wrong. Sync system time.'**
  String deviceClockSkewWarning(int seconds);

  /// No description provided for @commonSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get commonSubmit;

  /// No description provided for @confirmPullTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Pull Data'**
  String get confirmPullTitle;

  /// No description provided for @confirmPullMessage.
  ///
  /// In en, this message translates to:
  /// **'This will overwrite the data stored locally. Continue?'**
  String get confirmPullMessage;

  /// No description provided for @cloudNoData.
  ///
  /// In en, this message translates to:
  /// **'No data available in the cloud.'**
  String get cloudNoData;

  /// No description provided for @cloudPullSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data pulled successfully.'**
  String get cloudPullSuccess;

  /// No description provided for @cloudPullFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to pull data: {error}'**
  String cloudPullFailed(String error);

  /// No description provided for @confirmBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Backup Data'**
  String get confirmBackupTitle;

  /// No description provided for @confirmBackupMessage.
  ///
  /// In en, this message translates to:
  /// **'This will overwrite the data stored in the cloud. Continue?'**
  String get confirmBackupMessage;

  /// No description provided for @cloudBackupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data backed up successfully.'**
  String get cloudBackupSuccess;

  /// No description provided for @cloudBackupFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to back up data: {error}'**
  String cloudBackupFailed(String error);

  /// No description provided for @confirmDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Cloud Data'**
  String get confirmDeleteTitle;

  /// No description provided for @confirmDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete your OTP data from the cloud. Continue?'**
  String get confirmDeleteMessage;

  /// No description provided for @cloudDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Cloud data cleared.'**
  String get cloudDeleteSuccess;

  /// No description provided for @cloudDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to clear cloud data: {error}'**
  String cloudDeleteFailed(String error);

  /// No description provided for @confirmUnlinkTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlink Account'**
  String get confirmUnlinkTitle;

  /// No description provided for @confirmUnlinkMessage.
  ///
  /// In en, this message translates to:
  /// **'You will remain in offline mode. Continue?'**
  String get confirmUnlinkMessage;

  /// No description provided for @unlinkSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account unlinked. You are now working offline.'**
  String get unlinkSuccess;

  /// No description provided for @unlinkFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to unlink account: {error}'**
  String unlinkFailed(String error);

  /// No description provided for @noOtpToExport.
  ///
  /// In en, this message translates to:
  /// **'No OTP entries to export.'**
  String get noOtpToExport;

  /// No description provided for @exportCancelled.
  ///
  /// In en, this message translates to:
  /// **'Export cancelled.'**
  String get exportCancelled;

  /// No description provided for @exportDownloadStarted.
  ///
  /// In en, this message translates to:
  /// **'Download started: {filename}'**
  String exportDownloadStarted(String filename);

  /// No description provided for @exportSavedTo.
  ///
  /// In en, this message translates to:
  /// **'Exported to {location}'**
  String exportSavedTo(String location);

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to export: {error}'**
  String exportFailed(String error);

  /// No description provided for @unableToReadFile.
  ///
  /// In en, this message translates to:
  /// **'Unable to read selected file.'**
  String get unableToReadFile;

  /// No description provided for @invalidFileFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid file format.'**
  String get invalidFileFormat;

  /// No description provided for @fileDoesNotContainOtp.
  ///
  /// In en, this message translates to:
  /// **'Selected file does not contain OTP data.'**
  String get fileDoesNotContainOtp;

  /// No description provided for @fileContainsInvalidOtpEntries.
  ///
  /// In en, this message translates to:
  /// **'File contains invalid OTP entries.'**
  String get fileContainsInvalidOtpEntries;

  /// No description provided for @fileContainsNoEntries.
  ///
  /// In en, this message translates to:
  /// **'No OTP entries found in file.'**
  String get fileContainsNoEntries;

  /// No description provided for @importOptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Import options'**
  String get importOptionsTitle;

  /// No description provided for @importOptionsMessage.
  ///
  /// In en, this message translates to:
  /// **'Would you like to merge the imported OTPs with your existing list, or replace the current list entirely?'**
  String get importOptionsMessage;

  /// No description provided for @importMergeOption.
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get importMergeOption;

  /// No description provided for @importReplaceOption.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get importReplaceOption;

  /// No description provided for @importReplaceSuccess.
  ///
  /// In en, this message translates to:
  /// **'OTP list replaced with imported data.'**
  String get importReplaceSuccess;

  /// No description provided for @importMergeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Imported OTP entries merged.'**
  String get importMergeSuccess;

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to import: {error}'**
  String importFailed(String error);

  /// No description provided for @commonProceed.
  ///
  /// In en, this message translates to:
  /// **'Proceed'**
  String get commonProceed;

  /// No description provided for @linkAccount.
  ///
  /// In en, this message translates to:
  /// **'Link account'**
  String get linkAccount;

  /// No description provided for @settingsAccountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccountSection;

  /// No description provided for @settingsSyncSection.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get settingsSyncSection;

  /// No description provided for @settingsAppearanceSection.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearanceSection;

  /// No description provided for @settingsDataSection.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsDataSection;

  /// No description provided for @settingsDangerSection.
  ///
  /// In en, this message translates to:
  /// **'Danger'**
  String get settingsDangerSection;

  /// No description provided for @pullData.
  ///
  /// In en, this message translates to:
  /// **'Pull Data'**
  String get pullData;

  /// No description provided for @backupData.
  ///
  /// In en, this message translates to:
  /// **'Backup Data'**
  String get backupData;

  /// No description provided for @themeModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get themeModeTitle;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @languageSettingTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSettingTitle;

  /// No description provided for @languageSettingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a display language.'**
  String get languageSettingSubtitle;

  /// No description provided for @languageSystemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystemDefault;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get languageFrench;

  /// No description provided for @languageGerman.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get languageGerman;

  /// No description provided for @languageChineseSimplified.
  ///
  /// In en, this message translates to:
  /// **'Chinese (Simplified)'**
  String get languageChineseSimplified;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// No description provided for @importData.
  ///
  /// In en, this message translates to:
  /// **'Import Data'**
  String get importData;

  /// No description provided for @deleteAllCloudData.
  ///
  /// In en, this message translates to:
  /// **'Delete All Cloud Data'**
  String get deleteAllCloudData;

  /// No description provided for @unlinkAccount.
  ///
  /// In en, this message translates to:
  /// **'Unlink Account'**
  String get unlinkAccount;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About CloudOTP'**
  String get aboutTitle;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'CloudOTP is an open-source authenticator that keeps your OTP secrets secure with optional cloud sync.'**
  String get aboutDescription;

  /// No description provided for @viewOnGithub.
  ///
  /// In en, this message translates to:
  /// **'View on GitHub'**
  String get viewOnGithub;

  /// No description provided for @couldNotOpenRepository.
  ///
  /// In en, this message translates to:
  /// **'Could not open the repository.'**
  String get couldNotOpenRepository;

  /// No description provided for @offlineMode.
  ///
  /// In en, this message translates to:
  /// **'Offline mode'**
  String get offlineMode;

  /// No description provided for @connectedTo.
  ///
  /// In en, this message translates to:
  /// **'Connected to'**
  String get connectedTo;

  /// No description provided for @workingOffline.
  ///
  /// In en, this message translates to:
  /// **'Working offline'**
  String get workingOffline;

  /// No description provided for @linkedBadge.
  ///
  /// In en, this message translates to:
  /// **'Linked'**
  String get linkedBadge;

  /// No description provided for @linkPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Link a cloud account'**
  String get linkPromptTitle;

  /// No description provided for @linkPromptDescription.
  ///
  /// In en, this message translates to:
  /// **'Your OTP secrets are stored locally. Link a cloud account to enable secure backups.'**
  String get linkPromptDescription;

  /// No description provided for @linkNow.
  ///
  /// In en, this message translates to:
  /// **'Link now'**
  String get linkNow;

  /// No description provided for @commonUnknown.
  ///
  /// In en, this message translates to:
  /// **'unknown'**
  String get commonUnknown;

  /// No description provided for @cloudAccountLinkedAs.
  ///
  /// In en, this message translates to:
  /// **'Cloud account linked as {email}'**
  String cloudAccountLinkedAs(String email);

  /// No description provided for @accountLinkedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Account linked successfully.'**
  String get accountLinkedSuccessfully;

  /// No description provided for @accountCreatedCheckEmail.
  ///
  /// In en, this message translates to:
  /// **'Account created. Check your email to confirm.'**
  String get accountCreatedCheckEmail;

  /// No description provided for @authenticationFailed.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed: {error}'**
  String authenticationFailed(String error);

  /// No description provided for @useCloudDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Use cloud data?'**
  String get useCloudDataTitle;

  /// No description provided for @useCloudDataMessage.
  ///
  /// In en, this message translates to:
  /// **'Cloud backup contains {remoteCount} item(s). Do you want to replace your local entries with the cloud data?'**
  String useCloudDataMessage(int remoteCount);

  /// No description provided for @keepLocalButton.
  ///
  /// In en, this message translates to:
  /// **'Keep local'**
  String get keepLocalButton;

  /// No description provided for @useCloudDataButton.
  ///
  /// In en, this message translates to:
  /// **'Use cloud data'**
  String get useCloudDataButton;

  /// No description provided for @linkAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Link Account'**
  String get linkAccountButton;

  /// No description provided for @createAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountButton;

  /// No description provided for @linkCloudAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Link cloud account'**
  String get linkCloudAccountTitle;

  /// No description provided for @createCloudAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create cloud account'**
  String get createCloudAccountTitle;

  /// No description provided for @linkCloudAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync your OTP secrets securely.'**
  String get linkCloudAccountSubtitle;

  /// No description provided for @createCloudAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create an account to enable secure backups.'**
  String get createCloudAccountSubtitle;

  /// No description provided for @emailFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailFieldLabel;

  /// No description provided for @enterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// No description provided for @passwordFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordFieldLabel;

  /// No description provided for @enterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @needAccountSignUp.
  ///
  /// In en, this message translates to:
  /// **'Need an account? Sign up'**
  String get needAccountSignUp;

  /// No description provided for @haveAccountSignIn.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get haveAccountSignIn;

  /// No description provided for @continueOffline.
  ///
  /// In en, this message translates to:
  /// **'Continue offline'**
  String get continueOffline;

  /// No description provided for @otpErrorPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get otpErrorPlaceholder;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es', 'fr', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
