// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Cloud OTP';

  @override
  String get navList => 'Liste';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get scanQrCodeTitle => 'Scanner un code QR';

  @override
  String get uriCopiedToClipboard => 'URI copié dans le presse-papiers';

  @override
  String get copyUri => 'Copier l\'URI';

  @override
  String get closeButtonLabel => 'Fermer';

  @override
  String get otpSavedWithBackupHint =>
      'OTP enregistré localement. Utilisez Sauvegarde pour synchroniser avec le cloud.';

  @override
  String get otpSaved => 'OTP enregistré localement.';

  @override
  String failedToAddOtp(String error) {
    return 'Échec de l\'ajout de l\'OTP : $error';
  }

  @override
  String get otpCopied => 'OTP copié dans le presse-papiers.';

  @override
  String get deletedSuccessfully => 'Suppression réussie.';

  @override
  String failedToDeleteOtp(String error) {
    return 'Échec de la suppression de l\'OTP : $error';
  }

  @override
  String get otpListTitle => 'Liste des OTP';

  @override
  String get emptyOtpListHint =>
      'Aucun OTP ajouté pour le moment. Appuyez sur le bouton + pour en ajouter un.';

  @override
  String otpCodeLabel(String code) {
    return 'OTP : $code';
  }

  @override
  String otpDigitsLabel(int digits) {
    return 'Chiffres : $digits';
  }

  @override
  String otpIntervalLabel(int seconds) {
    return 'Intervalle : ${seconds}s';
  }

  @override
  String otpAlgorithmLabel(String algorithm) {
    return 'Algorithme : $algorithm';
  }

  @override
  String get manualInput => 'Saisie manuelle';

  @override
  String get qrScanner => 'Lecteur QR';

  @override
  String get manualInputTitle => 'Saisie manuelle';

  @override
  String get secretFieldLabel => 'Secret';

  @override
  String get labelFieldLabel => 'Étiquette';

  @override
  String get issuerFieldLabel => 'Émetteur (facultatif)';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get invalidOtpQr => 'Code QR OTP invalide';

  @override
  String get changePasswordTitle => 'Modifier le mot de passe';

  @override
  String get changePasswordNewLabel => 'Nouveau mot de passe';

  @override
  String get changePasswordConfirmLabel => 'Confirmer le nouveau mot de passe';

  @override
  String get passwordMismatch => 'Les mots de passe ne correspondent pas.';

  @override
  String get passwordChangedSuccess => 'Mot de passe modifié avec succès.';

  @override
  String unexpectedError(String error) {
    return 'Erreur inattendue : $error';
  }

  @override
  String get commonSubmit => 'Valider';

  @override
  String get confirmPullTitle => 'Confirmer l\'extraction des données';

  @override
  String get confirmPullMessage =>
      'Cela écrasera les données stockées localement. Continuer ?';

  @override
  String get cloudNoData => 'Aucune donnée disponible dans le cloud.';

  @override
  String get cloudPullSuccess => 'Données extraites avec succès.';

  @override
  String cloudPullFailed(String error) {
    return 'Impossible d\'extraire les données : $error';
  }

  @override
  String get confirmBackupTitle => 'Confirmer la sauvegarde';

  @override
  String get confirmBackupMessage =>
      'Cela écrasera les données stockées dans le cloud. Continuer ?';

  @override
  String get cloudBackupSuccess => 'Données sauvegardées avec succès.';

  @override
  String cloudBackupFailed(String error) {
    return 'Impossible de sauvegarder les données : $error';
  }

  @override
  String get confirmDeleteTitle => 'Supprimer les données cloud';

  @override
  String get confirmDeleteMessage =>
      'Cela supprimera définitivement vos données OTP du cloud. Continuer ?';

  @override
  String get cloudDeleteSuccess => 'Données cloud supprimées.';

  @override
  String cloudDeleteFailed(String error) {
    return 'Impossible de supprimer les données cloud : $error';
  }

  @override
  String get confirmUnlinkTitle => 'Dissocier le compte';

  @override
  String get confirmUnlinkMessage =>
      'Vous resterez en mode hors ligne. Continuer ?';

  @override
  String get unlinkSuccess =>
      'Compte dissocié. Vous travaillez maintenant hors ligne.';

  @override
  String unlinkFailed(String error) {
    return 'Impossible de dissocier le compte : $error';
  }

  @override
  String get noOtpToExport => 'Aucune entrée OTP à exporter.';

  @override
  String get exportCancelled => 'Exportation annulée.';

  @override
  String exportDownloadStarted(String filename) {
    return 'Téléchargement lancé : $filename';
  }

  @override
  String exportSavedTo(String location) {
    return 'Exporté vers $location';
  }

  @override
  String exportFailed(String error) {
    return 'Impossible d\'exporter : $error';
  }

  @override
  String get unableToReadFile => 'Impossible de lire le fichier sélectionné.';

  @override
  String get invalidFileFormat => 'Format de fichier invalide.';

  @override
  String get fileDoesNotContainOtp =>
      'Le fichier sélectionné ne contient pas de données OTP.';

  @override
  String get fileContainsInvalidOtpEntries =>
      'Le fichier contient des entrées OTP invalides.';

  @override
  String get fileContainsNoEntries =>
      'Aucune entrée OTP trouvée dans le fichier.';

  @override
  String get importOptionsTitle => 'Options d\'importation';

  @override
  String get importOptionsMessage =>
      'Souhaitez-vous fusionner les OTP importés avec votre liste actuelle ou la remplacer entièrement ?';

  @override
  String get importMergeOption => 'Fusionner';

  @override
  String get importReplaceOption => 'Remplacer';

  @override
  String get importReplaceSuccess =>
      'Liste OTP remplacée par les données importées.';

  @override
  String get importMergeSuccess => 'Entrées OTP importées fusionnées.';

  @override
  String importFailed(String error) {
    return 'Impossible d\'importer : $error';
  }

  @override
  String get commonProceed => 'Continuer';

  @override
  String get linkAccount => 'Associer un compte';

  @override
  String get pullData => 'Récupérer les données';

  @override
  String get backupData => 'Sauvegarde';

  @override
  String get themeModeTitle => 'Mode thème';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get languageSettingTitle => 'Langue';

  @override
  String get languageSettingSubtitle => 'Choisissez une langue d\'affichage.';

  @override
  String get languageSystemDefault => 'Par défaut du système';

  @override
  String get languageEnglish => 'Anglais';

  @override
  String get languageSpanish => 'Espagnol';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageGerman => 'Allemand';

  @override
  String get languageChineseSimplified => 'Chinois (simplifié)';

  @override
  String get exportData => 'Exporter les données';

  @override
  String get importData => 'Importer des données';

  @override
  String get deleteAllCloudData => 'Supprimer toutes les données cloud';

  @override
  String get unlinkAccount => 'Dissocier le compte';

  @override
  String get aboutTitle => 'À propos de CloudOTP';

  @override
  String get aboutDescription =>
      'CloudOTP est un authentificateur open source qui protège vos secrets OTP avec une synchronisation cloud facultative.';

  @override
  String get viewOnGithub => 'Voir sur GitHub';

  @override
  String get couldNotOpenRepository => 'Impossible d\'ouvrir le dépôt.';

  @override
  String get offlineMode => 'Mode hors ligne';

  @override
  String get connectedTo => 'Connecté à';

  @override
  String get workingOffline => 'Travail hors ligne';

  @override
  String get linkedBadge => 'Associé';

  @override
  String get linkPromptTitle => 'Associez un compte cloud';

  @override
  String get linkPromptDescription =>
      'Vos secrets OTP sont stockés localement. Associez un compte cloud pour activer des sauvegardes sécurisées.';

  @override
  String get linkNow => 'Associer maintenant';

  @override
  String get commonUnknown => 'inconnu';

  @override
  String cloudAccountLinkedAs(String email) {
    return 'Compte cloud associé en tant que $email';
  }

  @override
  String get accountLinkedSuccessfully => 'Compte associé avec succès.';

  @override
  String get accountCreatedCheckEmail =>
      'Compte créé. Vérifiez votre e-mail pour confirmer.';

  @override
  String authenticationFailed(String error) {
    return 'Échec de l\'authentification : $error';
  }

  @override
  String get useCloudDataTitle => 'Utiliser les données cloud ?';

  @override
  String useCloudDataMessage(int remoteCount) {
    return 'La sauvegarde cloud contient $remoteCount élément(s). Voulez-vous remplacer vos entrées locales par les données cloud ?';
  }

  @override
  String get keepLocalButton => 'Conserver localement';

  @override
  String get useCloudDataButton => 'Utiliser les données cloud';

  @override
  String get linkAccountButton => 'Associer le compte';

  @override
  String get createAccountButton => 'Créer un compte';

  @override
  String get linkCloudAccountTitle => 'Associer un compte cloud';

  @override
  String get createCloudAccountTitle => 'Créer un compte cloud';

  @override
  String get linkCloudAccountSubtitle =>
      'Connectez-vous pour synchroniser vos secrets OTP en toute sécurité.';

  @override
  String get createCloudAccountSubtitle =>
      'Créez un compte pour activer des sauvegardes sécurisées.';

  @override
  String get emailFieldLabel => 'Courriel';

  @override
  String get enterYourEmail => 'Saisissez votre courriel';

  @override
  String get passwordFieldLabel => 'Mot de passe';

  @override
  String get enterYourPassword => 'Saisissez votre mot de passe';

  @override
  String get passwordTooShort =>
      'Le mot de passe doit comporter au moins 6 caractères';

  @override
  String get needAccountSignUp => 'Besoin d\'un compte ? Inscrivez-vous';

  @override
  String get haveAccountSignIn => 'Vous avez déjà un compte ? Connectez-vous';

  @override
  String get continueOffline => 'Continuer hors ligne';

  @override
  String get otpErrorPlaceholder => 'Erreur';
}
