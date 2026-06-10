# CloudOTP Authenticator

Open-source TOTP/HOTP authenticator for Windows desktop, Android, and Web with QR import/export, local-only storage, and optional cloud sync.

[![Microsoft Store](https://img.shields.io/badge/Microsoft%20Store-CloudOTP-0078D4?logo=microsoftstore&logoColor=white)](https://apps.microsoft.com/detail/9pld5r9rpwpx)
[![GitHub release](https://img.shields.io/github/v/release/jingcjie/CloudOTP)](https://github.com/jingcjie/CloudOTP/releases/latest)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Platforms](https://img.shields.io/badge/platforms-Windows%20%7C%20Android%20%7C%20Web-brightgreen)](#install)

[中文 README](./readme-zh.md)

CloudOTP is built for people who want OTP codes available on their PC without being locked into one device or one vendor. Use it as a Windows desktop authenticator, open the web version when needed, or install the Android APK from GitHub Releases.

## Install

### Windows

Install CloudOTP from the Microsoft Store:

<a href="https://apps.microsoft.com/detail/9pld5r9rpwpx"><img src="https://developer.microsoft.com/store/badges/images/English_get-it-from-MS.png" alt="Get it from Microsoft Store" width="142" height="52"></a>

You can also install it from Microsoft Store with `winget`:

```powershell
winget install --source msstore --id 9PLD5R9RPWPX --accept-source-agreements --accept-package-agreements
```

### Web

Use the browser version at [https://cloudotp.top/](https://cloudotp.top/).

### Android

Download the APK from the [latest GitHub Release](https://github.com/jingcjie/CloudOTP/releases/latest).

Choose the APK for your device:

- `arm64-v8a`: most modern Android phones
- `armeabi-v7a`: older 32-bit Android phones
- `x86_64`: emulators and some Chromebook devices


### Build from source

Install [Flutter](https://flutter.dev/docs/get-started/install), then run:

```bash
git clone https://github.com/jingcjie/CloudOTP.git
cd CloudOTP
flutter pub get
```

Run locally:

```bash
flutter run -d windows
flutter run -d chrome
flutter run
```

Manual release builds:

```bash
flutter build apk --split-per-abi
dart run msix:create
flutter build web
```

## Features

- Windows desktop authenticator available from Microsoft Store
- TOTP and HOTP code generation
- QR scan, image import, and manual account setup
- QR export for backup, transfer, and migration to other authenticators
- Local-only mode for device storage
- Optional cloud sync for backup and restore
- Light and dark themes
- English, Chinese, Spanish, French, and German UI
- MIT licensed source code

## Security Model

CloudOTP supports local mode and optional cloud sync.

In local mode, OTP data is stored on the current device. Removing app data can remove locally stored OTP entries, so keep your own backup if you rely on local-only mode.

Cloud sync is optional. Cloud data is isolated per account with Supabase authentication and Row-Level Security policies. Client-side encryption for cloud sync is planned, so the project does not currently describe cloud sync as end-to-end encrypted.

QR export is designed to prevent lock-in: you can export accounts and move them to another authenticator at any time.

## Compatibility

Current release targets:

- Windows 10/11
- Android APK from GitHub Releases
- Web browser at `cloudotp.top`


## Contributing

Contributions are welcome. Please open an issue or submit a pull request.

## License

CloudOTP is licensed under the [MIT License](LICENSE).

## Acknowledgements

- [Dart](https://dart.dev)
- [Flutter](https://flutter.dev)
- [OTP RFC 6238](https://datatracker.ietf.org/doc/html/rfc6238)
- [HOTP RFC 4226](https://datatracker.ietf.org/doc/html/rfc4226)
