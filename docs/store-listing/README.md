# Microsoft Store Listing Draft

Use this as the source copy for the Partner Center listing refresh. Keep claims aligned with the README and do not describe cloud sync as end-to-end encrypted until client-side encryption is implemented.

## Short Description

Open-source TOTP/HOTP authenticator for Windows. Manage 2FA codes on your PC, import or export QR backups, and choose local-only storage or optional cloud sync.

## Full Description

CloudOTP is an open-source authenticator for people who want their two-factor authentication codes available on a Windows PC without being locked into one device or one vendor.

Add accounts by scanning QR codes, importing QR images, or entering secrets manually. Generate TOTP codes for time-based 2FA, advance HOTP counters when needed, and keep your account list readable with a clean desktop interface and light or dark theme.

CloudOTP supports local-only mode for device storage. Optional cloud sync can back up and restore your OTP list across devices, while keeping cloud data isolated per account. Client-side encryption for cloud sync is on the roadmap, so the app does not describe sync data as end-to-end encrypted yet.

Export is built in. You can save accounts as QR codes for offline backup, transfer them to another device, or move to another authenticator at any time.

CloudOTP is MIT licensed and source-visible on GitHub. The app is designed to be practical, portable, and transparent about how your OTP data is handled.

## Feature List

- TOTP and HOTP two-factor authentication codes
- QR scanner, QR image import, and manual secret entry
- QR export for backup, transfer, and migration
- Local-only storage mode for device-only use
- Optional account-based cloud sync for backup and restore
- Clean Windows desktop interface with light and dark themes
- English, Chinese, Spanish, French, and German interface
- Open-source project licensed under MIT

## Keywords

- authenticator
- otp
- totp
- hotp
- 2fa
- mfa
- two factor authentication

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

Refreshed Windows desktop experience, improved time checking, WebAssembly support, and updated OTP account handling.

Prompt for codex to upload:
Use the local Microsoft Store publishing flow for CloudOTP.
msstore is already configured on this machine.
Product ID: 9PLD5R9RPWPX.
Build the MSIX, update the Store listing from docs/store-listing/README.md,
generate "What's new" from commits since <tag>, upload to Partner Center,
then stop at PendingCommit unless I explicitly say to publish.