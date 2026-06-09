# CloudOTP Authenticator

CloudOTP 是一个开源 TOTP/HOTP 认证器，支持 Windows 桌面端、Android 和 Web。它支持二维码导入/导出、本地存储模式，以及可选的云同步。

[English README](./README.md)

CloudOTP 的重点是让你在电脑上也能方便地查看 OTP 验证码，同时尽量避免被某一个设备或某一个认证器应用锁定。

## 安装

### Windows

从 Microsoft Store 安装 CloudOTP：

<a href="https://apps.microsoft.com/detail/9pld5r9rpwpx"><img src="https://developer.microsoft.com/store/badges/images/English_get-it-from-MS.png" alt="Get it from Microsoft Store" width="142" height="52"></a>

### Web

直接访问 [https://cloudotp.top/](https://cloudotp.top/) 使用网页版。

### Android

从 [GitHub Releases](https://github.com/jingcjie/CloudOTP/releases/latest) 下载 APK。

APK 选择建议：

- `arm64-v8a`：大多数现代 Android 手机
- `armeabi-v7a`：较老的 32 位 Android 手机
- `x86_64`：模拟器和部分 Chromebook 设备

CloudOTP 目前不再上架 Google Play。

### 从源码运行

安装 [Flutter](https://flutter.dev/docs/get-started/install)，然后运行：

```bash
git clone https://github.com/jingcjie/CloudOTP.git
cd CloudOTP
flutter pub get
```

本地运行：

```bash
flutter run -d windows
flutter run -d chrome
flutter run
```

手动构建发布包：

```bash
flutter build apk --split-per-abi
dart run msix:create
flutter build web
```

## 功能

- Windows 桌面认证器，可从 Microsoft Store 安装
- 支持 TOTP 和 HOTP 验证码
- 支持二维码扫描、图片导入和手动添加账号
- 支持二维码导出，便于备份、迁移到其他认证器
- 支持本地存储模式
- 支持可选云同步，用于备份和恢复
- 支持亮色/暗色主题
- 支持英文、中文、西班牙语、法语和德语界面
- MIT 开源许可

## 安全模型

CloudOTP 支持本地模式和可选云同步。

本地模式下，OTP 数据保存在当前设备上。清除应用数据可能会删除本地保存的 OTP 条目，因此如果你只使用本地模式，请自行保留备份。

云同步是可选功能。云端数据通过 Supabase 认证和 Row-Level Security 按账号隔离。云同步的客户端加密功能已列入计划，因此目前不要把云同步描述为端到端加密。

二维码导出用于避免锁定：你可以随时导出账号，并迁移到其他认证器。

## 截图

演示截图和 GIF 请只使用测试账号，不要展示真实密钥、真实邮箱或真实恢复码。素材目录：

- [`docs/assets/screenshots/`](docs/assets/screenshots/)
- [`docs/assets/gifs/`](docs/assets/gifs/)

建议使用的演示账号：

- Example Mail
- Work Dashboard
- CloudOTP Demo
- Local Account

## 兼容性

当前发布目标：

- Windows 10/11
- GitHub Releases 提供的 Android APK
- `cloudotp.top` 网页版

Linux、macOS 和 iOS 目前不是正式发布目标。

## 贡献

欢迎提交 issue 或 pull request。

## 许可证

CloudOTP 使用 [MIT License](LICENSE)。

## 致谢

- [Dart](https://dart.dev)
- [Flutter](https://flutter.dev)
- [OTP RFC 6238](https://datatracker.ietf.org/doc/html/rfc6238)
- [HOTP RFC 4226](https://datatracker.ietf.org/doc/html/rfc4226)
