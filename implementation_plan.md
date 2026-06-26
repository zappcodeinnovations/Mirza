# Asset Cleanup Plan

This plan details the removal of unused assets and updating the `pubspec.yaml` file to ensure the project remains clean and unaffected.

## User Review Required

Please review the list of assets that will be deleted. If you plan to use any of these in the future, let me know, and I will keep them. Otherwise, I will proceed with deleting them and removing their references from `pubspec.yaml`.

## Proposed Changes

### 1. Remove Unused Assets from Directories

The following files are not referenced anywhere in the `lib/` codebase and will be permanently deleted:

**Icons (`assets/icons/`)**:
- `Gixa.png`
- `Gixxa3.png`
- `Wishlist.png`
- `appicon.png`
- `assistance.png`
- `cutoff (2).png`
- `edutrack.png`
- `help.png`
- `home.png`
- `prediction.png`
- `premium_genie.png`
- `profile.png` (Note: `assets/images/profile.png` is used and will be kept)
- `subscription_genie.png`

**Images (`assets/images/`)**:
- `applications.png`
- `college_placeholder.jpg`
- `documents.png` (Only found commented out)
- `dummy.png`
- `gixa_app_logo.png`

**Lottie (`assets/lottie/`)**:
- `AiData.json`
- `OnlineLearning.json`
- `Search_Doctor.json`
- `predicationAI.json`
- `premium.json`
- `sign_in.json`
- `gixa.gif`
- `gixa_logo.svg`

**Videos (`assets/videos/`)**:
- `Genie.mp4`
- `Genie1.mp4`
- `Genie2.mp4`
- `gixa_video.mp4`
- `gixa_video1.mp4`
- `gixxaa.mp4`
- `welcome.mp4`

### 2. Update `pubspec.yaml`

I will remove the entries corresponding to these deleted files from the `flutter: assets:` section of `pubspec.yaml`. This ensures the app bundle size is reduced and there are no missing file errors.

## Verification Plan

- After making the changes, the app should continue to compile and run normally since only unreferenced files are being removed.
- I will verify that the `pubspec.yaml` formatting remains correct.
