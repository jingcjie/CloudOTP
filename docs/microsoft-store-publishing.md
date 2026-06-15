# Microsoft Store publishing automation

This repo publishes the Windows MSIX update through `.github/workflows/microsoft-store-publish.yml`.
The workflow builds or uses an MSIX/MSIXUPLOAD package, uploads it to a Partner Center draft, updates listing metadata, waits for GitHub environment approval, then submits the draft to Microsoft Store certification.

## 1. Partner Center prerequisites

Microsoft's Store Developer CLI update flow expects:

- A Windows app developer account in Partner Center.
- A Microsoft Entra tenant associated with the Partner Center account.
- A Microsoft Entra app registration added in Partner Center under Account settings > User management > Microsoft Entra applications.
- The Entra app assigned a Partner Center role that can manage submissions, for example Manager.
- An app that is already published and live in Microsoft Store.
- A free product. Microsoft documents Store CLI/GitHub Actions app update support for free products only.

Reference:

- https://learn.microsoft.com/en-us/windows/apps/publish/msstore-dev-cli/github-actions
- https://learn.microsoft.com/en-us/windows/apps/publish/msstore-dev-cli/overview
- https://learn.microsoft.com/en-us/windows/apps/publish/msstore-dev-cli/commands

## 2. Add GitHub secrets

In GitHub, open the repository, then go to Settings > Secrets and variables > Actions > New repository secret.

Add these repository secrets:

- `MSSTORE_TENANT_ID`: Microsoft Entra tenant ID.
- `MSSTORE_CLIENT_ID`: Entra application/client ID.
- `MSSTORE_CLIENT_SECRET`: Entra client secret value.
- `MSSTORE_SELLER_ID`: Partner Center seller ID. In the newer Partner Center UI, open Settings > Account settings > Organization profile > Identifiers, then use the Seller ID shown under Publisher.
- `MSSTORE_PRODUCT_ID`: Store product ID, usually the `9...` ID shown for the app in Partner Center.

Do not put these values in workflow YAML, scripts, docs, or committed config files.

## 2a. Local-only credential storage

If publishing from your own machine instead of GitHub Actions, copy the local template and fill it in:

```powershell
Copy-Item .env.local.example .env.local
notepad .env.local
```

Then load it before running Store commands:

```powershell
./tool/Import-StorePublishingEnv.ps1 -ConfigureMsstore
```

This sets the `MSSTORE_*` values for the current PowerShell session and runs `msstore reconfigure`.
The `.env.local` file is ignored by git, but it is still plaintext on your machine. Keep it private and do not paste it into issues, logs, or screenshots.

## 3. Configure manual approval

The publish job uses the GitHub environment named `microsoft-store-production`.

Create it in GitHub:

1. Open Settings > Environments.
2. Create an environment named `microsoft-store-production`.
3. Enable Required reviewers.
4. Add the people who are allowed to approve Store submission.

Without required reviewers, GitHub will not pause before the final `msstore submission publish` step.

## 4. Maintain listing metadata

Edit `docs/store-listing/README.md` before running the workflow.

The workflow applies these sections to the selected Store listing language, default `en-us`:

- `Short Description` -> Store short description.
- `Full Description` -> Store description.
- `Feature List` -> Store product features.

The workflow does not use the `What's New Draft` section. It generates the Store "What's new in this version" value from recent git commit subjects.

By default, release notes use commits after the latest reachable git tag. If you need another range, pass a `release_notes_from` value when manually running the workflow, for example `v2.1.0`.

## 5. Run the workflow

Open Actions > Microsoft Store Publish > Run workflow.

Inputs:

- `package_path`: leave empty to build `dart run msix:create`; set it only if a package is already in the repo workspace.
- `release_notes_from`: optional git ref for release notes.
- `listing_language`: default `en-us`.
- `dry_run`: builds and creates a metadata preview artifact without calling Partner Center.

The normal run does this:

1. Builds and tests the Flutter project.
2. Builds or locates the `.msix`/`.msixupload`.
3. Configures Microsoft Store Developer CLI from GitHub secrets.
4. Runs `msstore publish <package> --appId <product-id> --noCommit` to upload the package to the draft without submitting it.
5. Fetches draft metadata with `msstore submission get`.
6. Updates the listing JSON and release notes.
7. Pushes metadata with `msstore submission updateMetadata`.
8. Stops at the `microsoft-store-production` environment approval.
9. After approval, runs `msstore submission publish` to submit the draft.

The workflow uploads `store-draft-metadata` as an artifact before the approval job. Review `store-release-notes.txt` and `store-submission.updated.json` from that artifact before approving.

## 6. Troubleshooting

- Increase `msix_config.msix_version` in `pubspec.yaml` for each Store package. Partner Center rejects duplicate or lower package versions.
- If `msstore submission get` outputs invalid JSON for a localized listing, update Microsoft Store Developer CLI when a fix is available, or temporarily remove/problem-isolate that listing in Partner Center before running automation.
- If the approval job starts without pausing, the `microsoft-store-production` environment exists but has no required reviewers.
- If Partner Center rejects the package, inspect the workflow log and the Partner Center submission details. The final Store availability still depends on Microsoft certification.
