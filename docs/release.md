# Releasing the Android app

How to build and publish `in.armid.calendar` on Google Play. The web app and the site deploy from `main` by themselves (`.github/workflows/deploy-web.yml`).

## 1. One-time: the upload key (owner)

Play App Signing holds the real app-signing key; you sign uploads with an **upload key** that stays with you.

```bash
keytool -genkey -v -keystore ~/keys/kollavarsham-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Keep the `.jks` file and both passwords somewhere safe (a password manager, plus an offline copy). If the upload key is lost, Play can reset it, but that takes a support request and days.

Create `apps/calendar/android/key.properties` (git ignores it, along with `*.jks` and `*.keystore`):

```properties
storeFile=C:/Users/you/keys/kollavarsham-upload.jks
storePassword=…
keyAlias=upload
keyPassword=…
```

`android/app/build.gradle.kts` reads this file. Without it, release builds are signed with the debug key and Gradle prints a warning; such builds run on a phone but Play rejects them.

Never commit the keystore or `key.properties`, and don't add them to CI. CI builds only debug APKs.

## 2. Before each release

1. `main` is green in CI.
2. Tests, including the goldens (Windows only):
   ```bash
   cd apps/calendar && flutter test
   ```
3. Holiday data is current: `data/holidays/` has the coming year's file, and the app's copies match (`dart run tool/sync_holidays.dart`; `test/holidays_test.dart` fails otherwise).
4. The accuracy checklist for the coming months is filled in (`docs/accuracy-checklist.md`, Day 23).
5. Bump the version in **both** places:
   - `apps/calendar/pubspec.yaml`: `version: 0.2.0+2` (name + build number; the build number must go up every upload);
   - `apps/calendar/lib/app/version.dart`: `appVersion = '0.2.0'` (`test/extras_test.dart` checks they match).
6. Note the changes for "What's new" (500 characters, English and Malayalam).

## 3. Build

```bash
cd apps/calendar
flutter build appbundle --release
```

The bundle is `build/app/outputs/bundle/release/app-release.aab`. Release builds run R8 (code shrinking and obfuscation) and resource shrinking; keep rules are in `android/app/proguard-rules.pro`. If a plugin breaks only in release, add a keep rule there.

To try a release build on a phone first:

```bash
flutter build apk --release --split-per-abi
adb install build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

Smoke test on the phone: onboarding, Today, a pirannal with a reminder a minute ahead (notification arrives, Snooze works), the two home-screen widgets, a launcher shortcut, backup and restore, and `.ics` export into Google Calendar.

Size at Day 18: arm64 APK 19.9 MB (Flutter engine 11.3 MB, Dart code 7.5 MB).

## 4. Publish (owner)

1. Play Console → the app → **Testing → Closed testing** for the first releases (Play requires 12 testers for 14 days before production for new personal accounts).
2. Create a release, upload the `.aab`, paste "What's new", roll out.
3. After the test period, promote the release to **Production**.
4. Listing text, screenshots and data-safety answers: `docs/store-listing.md`.

Don't create `kollavarsham-v*` or `kollavarsham_flutter-v*` tags: they publish the packages to pub.dev (`.github/workflows/publish.yml`). App releases need no tag.

## 5. Known build quirks

- `android.builtInKotlin=false` (from the Flutter template) means plugins that rely on AGP 9's built-in Kotlin (file_picker 11, home_widget 0.9) don't compile their Kotlin. `android/build.gradle.kts` applies the Kotlin plugin to those two. Remove the hook when the template enables built-in Kotlin.
- workmanager 0.7 still applies the Kotlin Gradle Plugin; Flutter warns that a future version will stop building it. Upgrade once a version that resolves on the workspace's Dart floor drops it.
- On Windows, with the project on a different drive from the pub cache, Kotlin's incremental compiler fails ("Could not close incremental caches"). Build with `kotlin.incremental=false` in `android/gradle.properties` locally; don't commit it.
