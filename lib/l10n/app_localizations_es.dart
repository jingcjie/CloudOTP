// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Cloud OTP';

  @override
  String get navList => 'Listado';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get scanQrCodeTitle => 'Escanear código QR';

  @override
  String get uriCopiedToClipboard => 'URI copiado al portapapeles';

  @override
  String get copyUri => 'Copiar URI';

  @override
  String get closeButtonLabel => 'Cerrar';

  @override
  String get otpSavedWithBackupHint =>
      'OTP guardado localmente. Usa Copia de seguridad para sincronizar con la nube.';

  @override
  String get otpSaved => 'OTP guardado localmente.';

  @override
  String failedToAddOtp(String error) {
    return 'No se pudo añadir el OTP: $error';
  }

  @override
  String get otpCopied => 'OTP copiado al portapapeles.';

  @override
  String get deletedSuccessfully => 'Eliminado correctamente.';

  @override
  String failedToDeleteOtp(String error) {
    return 'No se pudo eliminar el OTP: $error';
  }

  @override
  String get otpListTitle => 'Lista de OTP';

  @override
  String get emptyOtpListHint =>
      'Aún no has añadido OTP. Pulsa el botón + para agregar uno.';

  @override
  String otpCodeLabel(String code) {
    return 'OTP: $code';
  }

  @override
  String otpDigitsLabel(int digits) {
    return 'Dígitos: $digits';
  }

  @override
  String otpIntervalLabel(int seconds) {
    return 'Intervalo: ${seconds}s';
  }

  @override
  String otpAlgorithmLabel(String algorithm) {
    return 'Algoritmo: $algorithm';
  }

  @override
  String get manualInput => 'Entrada manual';

  @override
  String get qrScanner => 'Escáner QR';

  @override
  String get manualInputTitle => 'Entrada manual';

  @override
  String get secretFieldLabel => 'Secreto';

  @override
  String get labelFieldLabel => 'Etiqueta';

  @override
  String get issuerFieldLabel => 'Emisor (opcional)';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonSave => 'Guardar';

  @override
  String get invalidOtpQr => 'Código QR de OTP no válido';

  @override
  String get changePasswordTitle => 'Cambiar contraseña';

  @override
  String get changePasswordNewLabel => 'Nueva contraseña';

  @override
  String get changePasswordConfirmLabel => 'Confirmar nueva contraseña';

  @override
  String get passwordMismatch => 'Las contraseñas no coinciden.';

  @override
  String get passwordChangedSuccess => 'Contraseña cambiada correctamente.';

  @override
  String unexpectedError(String error) {
    return 'Error inesperado: $error';
  }

  @override
  String get commonSubmit => 'Enviar';

  @override
  String get confirmPullTitle => 'Confirmar extracción de datos';

  @override
  String get confirmPullMessage =>
      'Esto sobrescribirá los datos almacenados localmente. ¿Continuar?';

  @override
  String get cloudNoData => 'No hay datos disponibles en la nube.';

  @override
  String get cloudPullSuccess => 'Datos extraídos correctamente.';

  @override
  String cloudPullFailed(String error) {
    return 'No se pudo extraer datos: $error';
  }

  @override
  String get confirmBackupTitle => 'Confirmar copia de seguridad';

  @override
  String get confirmBackupMessage =>
      'Esto sobrescribirá los datos almacenados en la nube. ¿Continuar?';

  @override
  String get cloudBackupSuccess => 'Datos respaldados correctamente.';

  @override
  String cloudBackupFailed(String error) {
    return 'No se pudo respaldar los datos: $error';
  }

  @override
  String get confirmDeleteTitle => 'Eliminar datos en la nube';

  @override
  String get confirmDeleteMessage =>
      'Esto eliminará permanentemente tus datos OTP de la nube. ¿Continuar?';

  @override
  String get cloudDeleteSuccess => 'Datos en la nube eliminados.';

  @override
  String cloudDeleteFailed(String error) {
    return 'No se pudo eliminar los datos en la nube: $error';
  }

  @override
  String get confirmUnlinkTitle => 'Desvincular cuenta';

  @override
  String get confirmUnlinkMessage =>
      'Seguirás en modo sin conexión. ¿Continuar?';

  @override
  String get unlinkSuccess =>
      'Cuenta desvinculada. Ahora trabajas sin conexión.';

  @override
  String unlinkFailed(String error) {
    return 'No se pudo desvincular la cuenta: $error';
  }

  @override
  String get noOtpToExport => 'No hay entradas OTP para exportar.';

  @override
  String get exportCancelled => 'Exportación cancelada.';

  @override
  String exportDownloadStarted(String filename) {
    return 'Descarga iniciada: $filename';
  }

  @override
  String exportSavedTo(String location) {
    return 'Exportado a $location';
  }

  @override
  String exportFailed(String error) {
    return 'No se pudo exportar: $error';
  }

  @override
  String get unableToReadFile => 'No se puede leer el archivo seleccionado.';

  @override
  String get invalidFileFormat => 'Formato de archivo no válido.';

  @override
  String get fileDoesNotContainOtp =>
      'El archivo seleccionado no contiene datos OTP.';

  @override
  String get fileContainsInvalidOtpEntries =>
      'El archivo contiene entradas OTP no válidas.';

  @override
  String get fileContainsNoEntries =>
      'No se encontraron entradas OTP en el archivo.';

  @override
  String get importOptionsTitle => 'Opciones de importación';

  @override
  String get importOptionsMessage =>
      '¿Quieres fusionar los OTP importados con tu lista actual o reemplazarla por completo?';

  @override
  String get importMergeOption => 'Fusionar';

  @override
  String get importReplaceOption => 'Reemplazar';

  @override
  String get importReplaceSuccess =>
      'Lista de OTP reemplazada con los datos importados.';

  @override
  String get importMergeSuccess => 'Entradas OTP importadas fusionadas.';

  @override
  String importFailed(String error) {
    return 'No se pudo importar: $error';
  }

  @override
  String get commonProceed => 'Continuar';

  @override
  String get linkAccount => 'Vincular cuenta';

  @override
  String get pullData => 'Extraer datos';

  @override
  String get backupData => 'Copia de seguridad';

  @override
  String get themeModeTitle => 'Modo de tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get languageSettingTitle => 'Idioma';

  @override
  String get languageSettingSubtitle => 'Elige un idioma de visualización.';

  @override
  String get languageSystemDefault => 'Predeterminado del sistema';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageFrench => 'Francés';

  @override
  String get languageGerman => 'Alemán';

  @override
  String get languageChineseSimplified => 'Chino (simplificado)';

  @override
  String get exportData => 'Exportar datos';

  @override
  String get importData => 'Importar datos';

  @override
  String get deleteAllCloudData => 'Eliminar todos los datos en la nube';

  @override
  String get unlinkAccount => 'Desvincular cuenta';

  @override
  String get aboutTitle => 'Acerca de CloudOTP';

  @override
  String get aboutDescription =>
      'CloudOTP es un autenticador de código abierto que mantiene tus secretos OTP seguros con sincronización opcional en la nube.';

  @override
  String get viewOnGithub => 'Ver en GitHub';

  @override
  String get couldNotOpenRepository => 'No se pudo abrir el repositorio.';

  @override
  String get offlineMode => 'Modo sin conexión';

  @override
  String get connectedTo => 'Conectado a';

  @override
  String get workingOffline => 'Trabajando sin conexión';

  @override
  String get linkedBadge => 'Vinculado';

  @override
  String get linkPromptTitle => 'Vincula una cuenta en la nube';

  @override
  String get linkPromptDescription =>
      'Tus secretos OTP se almacenan localmente. Vincula una cuenta en la nube para habilitar copias de seguridad seguras.';

  @override
  String get linkNow => 'Vincular ahora';

  @override
  String get commonUnknown => 'desconocido';

  @override
  String cloudAccountLinkedAs(String email) {
    return 'Cuenta en la nube vinculada como $email';
  }

  @override
  String get accountLinkedSuccessfully => 'Cuenta vinculada correctamente.';

  @override
  String get accountCreatedCheckEmail =>
      'Cuenta creada. Revisa tu correo electrónico para confirmar.';

  @override
  String authenticationFailed(String error) {
    return 'Autenticación fallida: $error';
  }

  @override
  String get useCloudDataTitle => '¿Usar datos de la nube?';

  @override
  String useCloudDataMessage(int remoteCount) {
    return 'La copia de seguridad en la nube contiene $remoteCount elemento(s). ¿Quieres reemplazar tus entradas locales con los datos de la nube?';
  }

  @override
  String get keepLocalButton => 'Mantener local';

  @override
  String get useCloudDataButton => 'Usar datos de la nube';

  @override
  String get linkAccountButton => 'Vincular cuenta';

  @override
  String get createAccountButton => 'Crear cuenta';

  @override
  String get linkCloudAccountTitle => 'Vincular cuenta en la nube';

  @override
  String get createCloudAccountTitle => 'Crear cuenta en la nube';

  @override
  String get linkCloudAccountSubtitle =>
      'Inicia sesión para sincronizar tus secretos OTP de forma segura.';

  @override
  String get createCloudAccountSubtitle =>
      'Crea una cuenta para habilitar copias de seguridad seguras.';

  @override
  String get emailFieldLabel => 'Correo electrónico';

  @override
  String get enterYourEmail => 'Introduce tu correo electrónico';

  @override
  String get passwordFieldLabel => 'Contraseña';

  @override
  String get enterYourPassword => 'Introduce tu contraseña';

  @override
  String get passwordTooShort =>
      'La contraseña debe tener al menos 6 caracteres';

  @override
  String get needAccountSignUp => '¿Necesitas una cuenta? Regístrate';

  @override
  String get haveAccountSignIn => '¿Ya tienes una cuenta? Inicia sesión';

  @override
  String get continueOffline => 'Continuar sin conexión';

  @override
  String get otpErrorPlaceholder => 'Error';
}
