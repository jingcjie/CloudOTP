// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Cloud OTP';

  @override
  String get navList => '列表';

  @override
  String get navSettings => '设置';

  @override
  String get scanQrCodeTitle => '扫描二维码';

  @override
  String get uriCopiedToClipboard => 'URI 已复制到剪贴板';

  @override
  String get copyUri => '复制 URI';

  @override
  String get closeButtonLabel => '关闭';

  @override
  String get otpSavedWithBackupHint => 'OTP 已在本地保存。请使用“备份数据”同步到云端。';

  @override
  String get otpSaved => 'OTP 已在本地保存。';

  @override
  String failedToAddOtp(String error) {
    return '添加 OTP 失败：$error';
  }

  @override
  String get otpCopied => 'OTP 已复制到剪贴板。';

  @override
  String get deletedSuccessfully => '删除成功。';

  @override
  String failedToDeleteOtp(String error) {
    return '删除 OTP 失败：$error';
  }

  @override
  String get otpListTitle => 'OTP 列表';

  @override
  String get emptyOtpListHint => '尚未添加 OTP。点击 + 按钮添加。';

  @override
  String otpCodeLabel(String code) {
    return 'OTP：$code';
  }

  @override
  String otpDigitsLabel(int digits) {
    return '位数：$digits';
  }

  @override
  String otpIntervalLabel(int seconds) {
    return '间隔：$seconds秒';
  }

  @override
  String otpAlgorithmLabel(String algorithm) {
    return '算法：$algorithm';
  }

  @override
  String hotpCounterLabel(int counter) {
    return '计数器：$counter';
  }

  @override
  String get hotpCopyAdvanceTooltip => '复制并前进';

  @override
  String get hotpAdvanceTooltip => '前进计数器';

  @override
  String get manualInput => '手动输入';

  @override
  String get qrScanner => '二维码扫描';

  @override
  String get manualInputTitle => '手动输入';

  @override
  String get secretFieldLabel => '密钥';

  @override
  String get labelFieldLabel => '标签';

  @override
  String get issuerFieldLabel => '发行者（可选）';

  @override
  String get commonCancel => '取消';

  @override
  String get commonSave => '保存';

  @override
  String get invalidOtpQr => '无效的 OTP 二维码';

  @override
  String get changePasswordTitle => '修改密码';

  @override
  String get changePasswordNewLabel => '新密码';

  @override
  String get changePasswordConfirmLabel => '确认新密码';

  @override
  String get passwordMismatch => '两次输入的密码不一致。';

  @override
  String get passwordChangedSuccess => '密码修改成功。';

  @override
  String unexpectedError(String error) {
    return '发生意外错误：$error';
  }

  @override
  String deviceClockSkewWarning(int seconds) {
    return '设备时间与服务器相差 $seconds 秒，OTP 代码可能错误。请同步系统时间。';
  }

  @override
  String get commonSubmit => '提交';

  @override
  String get confirmPullTitle => '确认获取数据';

  @override
  String get confirmPullMessage => '这将覆盖本地存储的数据。是否继续？';

  @override
  String get cloudNoData => '云端没有可用数据。';

  @override
  String get cloudPullSuccess => '数据获取成功。';

  @override
  String cloudPullFailed(String error) {
    return '获取数据失败：$error';
  }

  @override
  String get confirmBackupTitle => '确认备份数据';

  @override
  String get confirmBackupMessage => '这将覆盖云端存储的数据。是否继续？';

  @override
  String get cloudBackupSuccess => '数据备份成功。';

  @override
  String cloudBackupFailed(String error) {
    return '备份数据失败：$error';
  }

  @override
  String get confirmDeleteTitle => '删除云端数据';

  @override
  String get confirmDeleteMessage => '这将永久删除云端中的 OTP 数据。是否继续？';

  @override
  String get cloudDeleteSuccess => '云端数据已清除。';

  @override
  String cloudDeleteFailed(String error) {
    return '清除云端数据失败：$error';
  }

  @override
  String get confirmUnlinkTitle => '取消账户关联';

  @override
  String get confirmUnlinkMessage => '将保持离线模式。是否继续？';

  @override
  String get unlinkSuccess => '账户已取消关联，现在处于离线模式。';

  @override
  String unlinkFailed(String error) {
    return '取消关联失败：$error';
  }

  @override
  String get noOtpToExport => '没有可导出的 OTP 条目。';

  @override
  String get exportCancelled => '导出已取消。';

  @override
  String exportDownloadStarted(String filename) {
    return '开始下载：$filename';
  }

  @override
  String exportSavedTo(String location) {
    return '已导出到 $location';
  }

  @override
  String exportFailed(String error) {
    return '导出失败：$error';
  }

  @override
  String get unableToReadFile => '无法读取所选文件。';

  @override
  String get invalidFileFormat => '文件格式无效。';

  @override
  String get fileDoesNotContainOtp => '所选文件不包含 OTP 数据。';

  @override
  String get fileContainsInvalidOtpEntries => '文件中包含无效的 OTP 条目。';

  @override
  String get fileContainsNoEntries => '文件中未找到 OTP 条目。';

  @override
  String get importOptionsTitle => '导入选项';

  @override
  String get importOptionsMessage => '要将导入的 OTP 与现有列表合并，还是完全替换现有列表？';

  @override
  String get importMergeOption => '合并';

  @override
  String get importReplaceOption => '替换';

  @override
  String get importReplaceSuccess => '已使用导入数据替换 OTP 列表。';

  @override
  String get importMergeSuccess => '已合并导入的 OTP 条目。';

  @override
  String importFailed(String error) {
    return '导入失败：$error';
  }

  @override
  String get commonProceed => '继续';

  @override
  String get linkAccount => '关联账户';

  @override
  String get pullData => '获取数据';

  @override
  String get backupData => '备份数据';

  @override
  String get themeModeTitle => '主题模式';

  @override
  String get themeSystem => '系统';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get languageSettingTitle => '语言';

  @override
  String get languageSettingSubtitle => '选择显示语言。';

  @override
  String get languageSystemDefault => '系统默认';

  @override
  String get languageEnglish => '英语';

  @override
  String get languageSpanish => '西班牙语';

  @override
  String get languageFrench => '法语';

  @override
  String get languageGerman => '德语';

  @override
  String get languageChineseSimplified => '简体中文';

  @override
  String get exportData => '导出数据';

  @override
  String get importData => '导入数据';

  @override
  String get deleteAllCloudData => '删除所有云端数据';

  @override
  String get unlinkAccount => '取消关联';

  @override
  String get aboutTitle => '关于 CloudOTP';

  @override
  String get aboutDescription => 'CloudOTP 是一款开源验证器，可通过可选的云同步保护你的 OTP 密钥。';

  @override
  String get viewOnGithub => '在 GitHub 查看';

  @override
  String get couldNotOpenRepository => '无法打开仓库。';

  @override
  String get offlineMode => '离线模式';

  @override
  String get connectedTo => '已连接到';

  @override
  String get workingOffline => '离线工作';

  @override
  String get linkedBadge => '已关联';

  @override
  String get linkPromptTitle => '关联云账户';

  @override
  String get linkPromptDescription => '你的 OTP 密钥保存在本地。关联云账户以启用安全备份。';

  @override
  String get linkNow => '立即关联';

  @override
  String get commonUnknown => '未知';

  @override
  String cloudAccountLinkedAs(String email) {
    return '云账户已关联为 $email';
  }

  @override
  String get accountLinkedSuccessfully => '账户关联成功。';

  @override
  String get accountCreatedCheckEmail => '账户已创建。请检查邮箱以完成确认。';

  @override
  String authenticationFailed(String error) {
    return '认证失败：$error';
  }

  @override
  String get useCloudDataTitle => '使用云端数据？';

  @override
  String useCloudDataMessage(int remoteCount) {
    return '云端备份包含 $remoteCount 个项目。是否用云端数据替换本地条目？';
  }

  @override
  String get keepLocalButton => '保留本地';

  @override
  String get useCloudDataButton => '使用云端数据';

  @override
  String get linkAccountButton => '关联账户';

  @override
  String get createAccountButton => '创建账户';

  @override
  String get linkCloudAccountTitle => '关联云账户';

  @override
  String get createCloudAccountTitle => '创建云账户';

  @override
  String get linkCloudAccountSubtitle => '登录以安全同步你的 OTP 密钥。';

  @override
  String get createCloudAccountSubtitle => '创建账户以启用安全备份。';

  @override
  String get emailFieldLabel => '邮箱';

  @override
  String get enterYourEmail => '请输入邮箱';

  @override
  String get passwordFieldLabel => '密码';

  @override
  String get enterYourPassword => '请输入密码';

  @override
  String get passwordTooShort => '密码至少需要 6 个字符';

  @override
  String get needAccountSignUp => '需要账户？立即注册';

  @override
  String get haveAccountSignIn => '已有账户？立即登录';

  @override
  String get continueOffline => '继续离线使用';

  @override
  String get otpErrorPlaceholder => '错误';
}
