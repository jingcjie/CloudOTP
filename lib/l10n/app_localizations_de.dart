// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Cloud OTP';

  @override
  String get navList => 'Liste';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get scanQrCodeTitle => 'QR-Code scannen';

  @override
  String get uriCopiedToClipboard => 'URI in die Zwischenablage kopiert';

  @override
  String get copyUri => 'URI kopieren';

  @override
  String get closeButtonLabel => 'Schließen';

  @override
  String get otpSavedWithBackupHint =>
      'OTP lokal gespeichert. Verwende \"Sicherung\", um mit der Cloud zu synchronisieren.';

  @override
  String get otpSaved => 'OTP lokal gespeichert.';

  @override
  String failedToAddOtp(String error) {
    return 'OTP konnte nicht hinzugefügt werden: $error';
  }

  @override
  String get otpCopied => 'OTP in die Zwischenablage kopiert.';

  @override
  String get deletedSuccessfully => 'Erfolgreich gelöscht.';

  @override
  String failedToDeleteOtp(String error) {
    return 'OTP konnte nicht gelöscht werden: $error';
  }

  @override
  String get otpListTitle => 'OTP-Liste';

  @override
  String get emptyOtpListHint =>
      'Noch keine OTPs hinzugefügt. Tippe auf die +-Taste, um eines hinzuzufügen.';

  @override
  String otpCodeLabel(String code) {
    return 'OTP: $code';
  }

  @override
  String otpDigitsLabel(int digits) {
    return 'Ziffern: $digits';
  }

  @override
  String otpIntervalLabel(int seconds) {
    return 'Intervall: ${seconds}s';
  }

  @override
  String otpAlgorithmLabel(String algorithm) {
    return 'Algorithmus: $algorithm';
  }

  @override
  String hotpCounterLabel(int counter) {
    return 'Zähler: $counter';
  }

  @override
  String get hotpCopyAdvanceTooltip => 'Kopieren und weiter';

  @override
  String get hotpAdvanceTooltip => 'Zähler erhöhen';

  @override
  String get manualInput => 'Manuelle Eingabe';

  @override
  String get qrScanner => 'QR-Scanner';

  @override
  String get manualInputTitle => 'Manuelle Eingabe';

  @override
  String get secretFieldLabel => 'Secret';

  @override
  String get labelFieldLabel => 'Bezeichnung';

  @override
  String get issuerFieldLabel => 'Aussteller (optional)';

  @override
  String get commonCancel => 'Abbrechen';

  @override
  String get commonSave => 'Speichern';

  @override
  String get invalidOtpQr => 'Ungültiger OTP-QR-Code';

  @override
  String get changePasswordTitle => 'Passwort ändern';

  @override
  String get changePasswordNewLabel => 'Neues Passwort';

  @override
  String get changePasswordConfirmLabel => 'Neues Passwort bestätigen';

  @override
  String get passwordMismatch => 'Die Passwörter stimmen nicht überein.';

  @override
  String get passwordChangedSuccess => 'Passwort erfolgreich geändert.';

  @override
  String unexpectedError(String error) {
    return 'Unerwarteter Fehler: $error';
  }

  @override
  String deviceClockSkewWarning(int seconds) {
    return 'Die Geraeteuhr weicht um ${seconds}s vom Server ab. OTP-Codes koennen falsch sein. Synchronisiere die Systemzeit.';
  }

  @override
  String get commonSubmit => 'Bestätigen';

  @override
  String get confirmPullTitle => 'Datenübernahme bestätigen';

  @override
  String get confirmPullMessage =>
      'Dadurch werden lokal gespeicherte Daten überschrieben. Fortfahren?';

  @override
  String get cloudNoData => 'Keine Daten in der Cloud vorhanden.';

  @override
  String get cloudPullSuccess => 'Daten erfolgreich übernommen.';

  @override
  String cloudPullFailed(String error) {
    return 'Daten konnten nicht übernommen werden: $error';
  }

  @override
  String get confirmBackupTitle => 'Sicherung bestätigen';

  @override
  String get confirmBackupMessage =>
      'Dadurch werden die Daten in der Cloud überschrieben. Fortfahren?';

  @override
  String get cloudBackupSuccess => 'Daten erfolgreich gesichert.';

  @override
  String cloudBackupFailed(String error) {
    return 'Daten konnten nicht gesichert werden: $error';
  }

  @override
  String get confirmDeleteTitle => 'Clouddaten löschen';

  @override
  String get confirmDeleteMessage =>
      'Dadurch werden deine OTP-Daten dauerhaft aus der Cloud gelöscht. Fortfahren?';

  @override
  String get cloudDeleteSuccess => 'Clouddaten gelöscht.';

  @override
  String cloudDeleteFailed(String error) {
    return 'Clouddaten konnten nicht gelöscht werden: $error';
  }

  @override
  String get confirmUnlinkTitle => 'Konto trennen';

  @override
  String get confirmUnlinkMessage => 'Du bleibst im Offline-Modus. Fortfahren?';

  @override
  String get unlinkSuccess => 'Konto getrennt. Du arbeitest jetzt offline.';

  @override
  String unlinkFailed(String error) {
    return 'Konto konnte nicht getrennt werden: $error';
  }

  @override
  String get noOtpToExport => 'Keine OTP-Einträge zum Exportieren.';

  @override
  String get exportCancelled => 'Export abgebrochen.';

  @override
  String exportDownloadStarted(String filename) {
    return 'Download gestartet: $filename';
  }

  @override
  String exportSavedTo(String location) {
    return 'Exportiert nach $location';
  }

  @override
  String exportFailed(String error) {
    return 'Export fehlgeschlagen: $error';
  }

  @override
  String get unableToReadFile => 'Ausgewählte Datei kann nicht gelesen werden.';

  @override
  String get invalidFileFormat => 'Ungültiges Dateiformat.';

  @override
  String get fileDoesNotContainOtp =>
      'Die ausgewählte Datei enthält keine OTP-Daten.';

  @override
  String get fileContainsInvalidOtpEntries =>
      'Die Datei enthält ungültige OTP-Einträge.';

  @override
  String get fileContainsNoEntries =>
      'Keine OTP-Einträge in der Datei gefunden.';

  @override
  String get importOptionsTitle => 'Importoptionen';

  @override
  String get importOptionsMessage =>
      'Möchtest du die importierten OTPs mit deiner aktuellen Liste zusammenführen oder sie vollständig ersetzen?';

  @override
  String get importMergeOption => 'Zusammenführen';

  @override
  String get importReplaceOption => 'Ersetzen';

  @override
  String get importReplaceSuccess =>
      'OTP-Liste durch importierte Daten ersetzt.';

  @override
  String get importMergeSuccess => 'Importierte OTP-Einträge zusammengeführt.';

  @override
  String importFailed(String error) {
    return 'Import fehlgeschlagen: $error';
  }

  @override
  String get commonProceed => 'Fortfahren';

  @override
  String get linkAccount => 'Konto verknüpfen';

  @override
  String get pullData => 'Daten abrufen';

  @override
  String get backupData => 'Sicherung';

  @override
  String get themeModeTitle => 'Designmodus';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get languageSettingTitle => 'Sprache';

  @override
  String get languageSettingSubtitle => 'Wähle eine Anzeigesprache.';

  @override
  String get languageSystemDefault => 'Systemstandard';

  @override
  String get languageEnglish => 'Englisch';

  @override
  String get languageSpanish => 'Spanisch';

  @override
  String get languageFrench => 'Französisch';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageChineseSimplified => 'Chinesisch (vereinfacht)';

  @override
  String get exportData => 'Daten exportieren';

  @override
  String get importData => 'Daten importieren';

  @override
  String get deleteAllCloudData => 'Alle Clouddaten löschen';

  @override
  String get unlinkAccount => 'Konto trennen';

  @override
  String get aboutTitle => 'Über CloudOTP';

  @override
  String get aboutDescription =>
      'CloudOTP ist ein Open-Source-Authenticator, der deine OTP-Geheimnisse mit optionaler Cloud-Synchronisation schützt.';

  @override
  String get viewOnGithub => 'Auf GitHub ansehen';

  @override
  String get couldNotOpenRepository =>
      'Repository konnte nicht geöffnet werden.';

  @override
  String get offlineMode => 'Offline-Modus';

  @override
  String get connectedTo => 'Verbunden mit';

  @override
  String get workingOffline => 'Offline arbeiten';

  @override
  String get linkedBadge => 'Verbunden';

  @override
  String get linkPromptTitle => 'Cloud-Konto verknüpfen';

  @override
  String get linkPromptDescription =>
      'Deine OTP-Geheimnisse werden lokal gespeichert. Verknüpfe ein Cloud-Konto, um sichere Backups zu ermöglichen.';

  @override
  String get linkNow => 'Jetzt verknüpfen';

  @override
  String get commonUnknown => 'unbekannt';

  @override
  String cloudAccountLinkedAs(String email) {
    return 'Cloud-Konto verknüpft als $email';
  }

  @override
  String get accountLinkedSuccessfully => 'Konto erfolgreich verknüpft.';

  @override
  String get accountCreatedCheckEmail =>
      'Konto erstellt. Überprüfe deine E-Mail, um zu bestätigen.';

  @override
  String authenticationFailed(String error) {
    return 'Authentifizierung fehlgeschlagen: $error';
  }

  @override
  String get useCloudDataTitle => 'Clouddaten verwenden?';

  @override
  String useCloudDataMessage(int remoteCount) {
    return 'Die Cloud-Sicherung enthält $remoteCount Element(e). Möchtest du deine lokalen Einträge mit den Clouddaten ersetzen?';
  }

  @override
  String get keepLocalButton => 'Lokal behalten';

  @override
  String get useCloudDataButton => 'Clouddaten verwenden';

  @override
  String get linkAccountButton => 'Konto verknüpfen';

  @override
  String get createAccountButton => 'Konto erstellen';

  @override
  String get linkCloudAccountTitle => 'Cloud-Konto verknüpfen';

  @override
  String get createCloudAccountTitle => 'Cloud-Konto erstellen';

  @override
  String get linkCloudAccountSubtitle =>
      'Melde dich an, um deine OTP-Geheimnisse sicher zu synchronisieren.';

  @override
  String get createCloudAccountSubtitle =>
      'Erstelle ein Konto, um sichere Backups zu ermöglichen.';

  @override
  String get emailFieldLabel => 'E-Mail';

  @override
  String get enterYourEmail => 'Gib deine E-Mail ein';

  @override
  String get passwordFieldLabel => 'Passwort';

  @override
  String get enterYourPassword => 'Gib dein Passwort ein';

  @override
  String get passwordTooShort =>
      'Das Passwort muss mindestens 6 Zeichen lang sein';

  @override
  String get needAccountSignUp => 'Noch kein Konto? Registrieren';

  @override
  String get haveAccountSignIn => 'Bereits ein Konto? Anmelden';

  @override
  String get continueOffline => 'Offline fortfahren';

  @override
  String get otpErrorPlaceholder => 'Fehler';
}
