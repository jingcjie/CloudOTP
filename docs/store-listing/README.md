# Microsoft Store Listing Draft

Use this as the source copy for the Partner Center listing refresh. Keep claims aligned with the README and do not describe cloud sync as end-to-end encrypted until client-side encryption is implemented.

## Short Description

Open-source TOTP/HOTP authenticator for Windows, Android, and Web. Use OTP codes on your PC, import or export QR backups, and choose local-only storage or optional cloud sync.

## Full Description

CloudOTP is an open-source authenticator for Windows users who want TOTP and HOTP codes available on their desktop, with companion access from Android and the Web.

Add accounts by scanning QR codes or entering secrets manually. Generate TOTP codes, advance HOTP counters, organize your accounts, and switch between light and dark themes.

CloudOTP supports local mode for device-only storage. Optional cloud sync can back up and restore your OTP list across devices. Cloud data is isolated per account, and client-side encryption for cloud sync is on the roadmap.

You are not locked in. Export accounts as QR codes so you can move them to another authenticator or keep an offline backup.

CloudOTP is MIT licensed and source-visible on GitHub.

## Feature List

- TOTP and HOTP code generation
- Windows desktop app from Microsoft Store
- QR scan, image import, and manual account setup
- QR export for backup and migration
- Local-only mode with optional cloud sync
- Open-source MIT licensed project
- Light and dark themes
- English, Chinese, Spanish, French, and German UI

## Screenshot Plan

Use fake/demo accounts only. Do not show real OTP secrets, real personal email addresses, or real recovery codes.

- `01-windows-main.png`: Windows desktop main OTP list.
- `02-add-account.png`: add account dialog with QR/manual options.
- `03-qr-import.png`: QR import or image import flow.
- `04-export-backup.png`: QR export/no lock-in feature.
- `05-settings-sync.png`: settings screen with local/cloud mode.
- `06-dark-theme.png`: dark mode desktop screenshot.
- `07-web-companion.png`: optional web version screenshot.
- `08-android-apk.png`: optional Android screenshot.

## What's New Draft

Refreshed Windows desktop experience, improved OTP account handling, HOTP support, QR export improvements, and updated localization.
