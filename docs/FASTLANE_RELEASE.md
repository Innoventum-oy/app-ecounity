# Fastlane Release Workflow

This project has platform Fastlane setups:

- Android: `android/fastlane`
- iOS: `ios/fastlane`

The app id is `app.ecounity.ecounity` on both platforms.

## Ruby

Use the Homebrew Ruby for Bundler/Fastlane commands:

```sh
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
unset GEM_HOME GEM_PATH
bundle install
```

The checked-in `.ruby-version` is `4.0.5`, which matches the Homebrew Ruby
installed on this machine. Fastlane currently requires Ruby 3.0 or newer.

Fastlane is also available through Homebrew on this machine:

```sh
fastlane --version
```

## Android Signing

Google Play requires a release-signed AAB. Create the upload keystore with
Java `keytool`:

```sh
keytool -genkeypair -v \
  -keystore android/app/upload-keystore.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias upload \
  -dname "CN=Ecounity, OU=Mobile, O=Innoventum Oy, L=Helsinki, C=FI"
```

Then create `android/key.properties`:

```properties
storePassword=...
keyPassword=...
keyAlias=upload
storeFile=app/upload-keystore.jks
```

Modern `keytool` creates PKCS12 keystores by default, where the key password is
the same as the store password, so set `keyPassword` to the same value as
`storePassword` if prompted for only one password. Place the keystore at
`android/app/upload-keystore.jks`. Both files are ignored by git. Back up the
keystore and passwords securely because future Google Play updates depend on the
same upload key.

The Android Fastlane build lane validates `android/key.properties` and the
keystore before building so a Play upload cannot accidentally use the debug
signing fallback. For a local-only build check without release signing, pass
`allow_debug_signing:true`.

## Store Credentials

Android uses a Google Play service-account JSON:

```sh
cp android/fastlane/.env.example android/fastlane/.env
```

Set either `GOOGLE_PLAY_JSON_KEY_FILE` or `GOOGLE_PLAY_JSON_KEY_DATA`. For local
use, save the downloaded service-account key at
`android/fastlane/google-play-service-account.json`; this path is ignored by
git and is the default in `android/fastlane/.env.example`. Relative JSON paths
are resolved from the `android/` folder, so
`fastlane/google-play-service-account.json` works whether the lane is launched
from `android/` or via the Android Fastfile from the project root.

To create the key, enable the Google Play Developer API for a Google Cloud
project, create a service account, add a JSON key for that service account, and
invite the service-account email in Play Console under Users and permissions
with release/store-listing access for `app.ecounity.ecounity`.

Validate Android upload credentials without uploading:

```sh
cd android
bundle exec fastlane check_google_play_credentials
```

## Google Play Listing Metadata

Google Play listing metadata is tracked in the Android Fastlane metadata folder:

```text
android/fastlane/metadata/android/<locale>/title.txt
android/fastlane/metadata/android/<locale>/short_description.txt
android/fastlane/metadata/android/<locale>/full_description.txt
android/fastlane/metadata/android/<locale>/feature_graphic.png
android/fastlane/metadata/android/en-GB/app_icon.png
```

The app name shown in Play Console is `title.txt`. Google Play limits these
fields to 30 characters for app name, 80 characters for short description, and
4,000 characters for full description. The feature graphic must be a `1024x500`
JPEG or 24-bit PNG with no alpha channel. The Play Store app icon is uploaded
from `en-GB/app_icon.png` and reused for all localized listings unless a locale
has its own `app_icon.png`; it must be a `512x512` PNG under 1024 KB. English is
configured as `en-GB`; add translated folders as needed, for example `de-DE`,
`es-ES`, `fi-FI`, `it-IT`, `pl-PL`, `pt-PT`, `ro-RO`, and `uk`.

By default, the metadata lanes validate/upload all current app languages:

```sh
en-GB,de-DE,es-ES,fi-FI,it-IT,pl-PL,pt-PT,ro-RO,uk
```

To restrict metadata work to a smaller set, set `PLAY_METADATA_LOCALES` in
`android/fastlane/.env` or pass `metadata_locales:`:

```sh
PLAY_METADATA_LOCALES=en-GB
```

Validate listing metadata locally:

```sh
cd android
bundle exec fastlane validate_metadata
```

Upload listing text and feature graphics through the Google Play Developer API:

```sh
cd android
bundle exec fastlane upload_metadata
```

For a text-only metadata upload, pass `skip_images:true`.

Dry-run the Play edit without committing:

```sh
cd android
bundle exec fastlane upload_metadata validate_only:true
```

Read back what Google Play currently reports for listing icons, feature
graphics, and screenshots:

```sh
cd android
bundle exec fastlane check_store_listing_assets strict:true
```

iOS uses an App Store Connect API key:

```sh
cp ios/fastlane/.env.example ios/fastlane/.env
```

Set `APP_STORE_CONNECT_API_KEY_PATH`, or set the p8 key variables shown in the
example file. API-key authentication is preferred because it avoids interactive
Apple ID and 2FA prompts during uploads.

Recommended local setup:

1. In App Store Connect, create a Team API key under Users and Access,
   Integrations, App Store Connect API.
2. Download the `.p8` file once and keep it outside git, for example under a
   private credentials folder.
3. Set these values in `ios/fastlane/.env`:

```sh
APP_STORE_CONNECT_API_KEY_KEY_ID=XXXXXXXXXX
APP_STORE_CONNECT_API_KEY_ISSUER_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
APP_STORE_CONNECT_API_KEY_KEY_FILEPATH=/absolute/path/to/AuthKey_XXXXXXXXXX.p8
```

For CI, set `APP_STORE_CONNECT_API_KEY_KEY` to the raw or base64-encoded `.p8`
content and set `APP_STORE_CONNECT_API_KEY_IS_KEY_CONTENT_BASE64=true` when
using base64. The legacy `APP_STORE_CONNECT_API_KEY_FILEPATH` name is also
accepted locally, but new setups should use Fastlane's
`APP_STORE_CONNECT_API_KEY_KEY_FILEPATH` name.

Validate iOS upload credentials without uploading:

```sh
cd ios
bundle exec fastlane check_app_store_credentials
```

## App Store Metadata

App Store copyright, promotional text, keywords, support URL, and description
are tracked in the iOS Fastlane metadata folder:

```text
ios/fastlane/metadata/ios/copyright.txt
ios/fastlane/metadata/ios/<locale>/promotional_text.txt
ios/fastlane/metadata/ios/<locale>/keywords.txt
ios/fastlane/metadata/ios/<locale>/support_url.txt
ios/fastlane/metadata/ios/<locale>/description.txt
```

The iOS metadata uses App Store locales:

```sh
en-GB,de-DE,es-ES,fi,it,pl,pt-PT,ro,uk
```

The promotional text is copied from the Google Play short description, and the
description is copied from the Google Play full description. App Store Connect
limits promotional text to 170 characters, keywords to 100 bytes, copyright to
100 characters, and description to 4,000 characters. The copyright file should
contain the year and rights holder; App Store Connect adds the copyright symbol
automatically.

Unless noted otherwise, the project-level `LICENSE` releases this repository
under the Creative Commons CC0 1.0 Universal public domain dedication. Project
names, partner names, trademarks, and third-party logos may be subject to
separate rights.

Validate App Store metadata locally:

```sh
cd ios
bundle exec fastlane validate_metadata
```

Upload App Store metadata without uploading a build or screenshots:

```sh
cd ios
bundle exec fastlane upload_metadata
```

To include metadata when creating an App Store release, pass
`upload_metadata:true`:

```sh
cd ios
bundle exec fastlane release upload_metadata:true
```

## iOS Signing

The TestFlight and App Store lanes need an Apple Distribution certificate and an
App Store provisioning profile for `app.ecounity.ecounity`. To let Fastlane
create or download those assets using the configured App Store Connect API key,
run:

```sh
cd ios
bundle exec fastlane setup_app_store_signing
```

Signing files are written to `ios/signing/` and installed locally; that
folder is ignored by git. To have the build lane do this automatically before
exporting the IPA, pass `setup_signing:true` or set `IOS_SETUP_SIGNING=true` in
`ios/fastlane/.env`:

```sh
cd ios
bundle exec fastlane beta setup_signing:true
```

If your team already manages signing elsewhere, set `IOS_EXPORT_OPTIONS_PLIST`
to a custom export options plist instead.

## iOS Export Compliance

The iOS target sets `ITSAppUsesNonExemptEncryption` to `false` in
`ios/Runner/Info.plist`. The app uses platform networking/WebView behavior for
HTTPS and only uses `package:crypto` for an MD5 cache filename hash, so no
proprietary encryption or bundled standard encryption implementation is expected
from the app code. Re-check this if a future dependency adds its own encryption
library.

## Screenshots

Start an emulator or simulator first, then run:

```sh
cd android
bundle exec fastlane screenshots device:emulator-5554
```

```sh
cd ios
bundle exec fastlane screenshots
```

The lanes run the Flutter integration test in screenshot mode for
`en,de,es,fi,it,pl,pt,ro,uk`, then copy the PNGs into the folders Fastlane expects:

- iOS: `ios/fastlane/screenshots/<locale>/`, using App Store locales
  `en-GB,de-DE,es-ES,fi,it,pl,pt-PT,ro,uk`
- Android: `android/fastlane/metadata/android/<locale>/images/`, using Play
  Store locales `en-GB,de-DE,es-ES,fi-FI,it-IT,pl-PL,pt-PT,ro-RO,uk` and screenshot
  folders `phoneScreenshots`, `sevenInchScreenshots`, and
  `tenInchScreenshots`

Each locale currently prepares ten screenshots: welcome, language selector,
dashboard, modules list, resources list, representative wiki, quiz, drag/drop,
and video content screens, plus an MLR unit list for a module. The dashboard
capture waits for the suggested content cover image frame before taking its
screenshot, and the modules list waits for module thumbnail frames. The test
also looks for slides content and skips it when no localized candidate is
available.

The iOS lane captures separate simulator targets by default:

- `iphone_65` from an auto-created `Ecounity iPhone 6.5`
  (`iPhone 11 Pro Max` device type), expected at `1242x2688`
- `ipad_13` from an auto-created `Ecounity iPad 13`
  (`iPad Pro 13-inch (M4)` device type), expected at `2064x2752`

The prepare step also accepts `1284x2778` for iPhone and `2048x2732` for iPad.
Prepared App Store screenshots are prefixed by target, for example
`iphone_65_01_welcome.png` and `ipad_13_01_welcome.png`. Prepared iOS
screenshots are re-encoded as opaque 8-bit RGB PNGs because App Store Connect
rejects alpha channels and transparency. For a focused run,
pass `targets:iphone_65` or `targets:ipad_13`. To use an existing simulator,
pass `iphone_device:<name-or-udid>` or `ipad_device:<name-or-udid>`.

When `--clean` is used, the iOS prepare step clears the whole
`ios/fastlane/screenshots` folder before writing the selected locales. This
prevents old one-device screenshots from being mixed with the split iPhone/iPad
sets. The upload lane also refuses to upload stale unprefixed files.

Each Flutter screenshot drive is retried once by default
(`SCREENSHOT_DRIVE_RETRIES=1`) to absorb occasional VM-service disconnects after
the integration test has already completed. Android screenshot drives also time
out after 10 minutes by default (`SCREENSHOT_DRIVE_TIMEOUT=600`), terminate the
stuck `flutter drive` process group, force-stop the app on the emulator, and
retry. On macOS, the Android lane starts `caffeinate` for each screenshot drive
when available. If `flutter drive` exits non-zero after at least ten screenshots
were written for the current locale/device batch (`SCREENSHOT_MINIMUM_COUNT=10`),
Fastlane keeps that completed batch and continues.

The Android screenshot lane supports separate Google Play device buckets with
`SCREENSHOT_TARGETS=phone,seven_inch,ten_inch`. By default it launches these
AVDs when no explicit device id is configured:

- `phone`: `Pixel_6_API_33`
- `seven_inch`: `Ecounity_7in_API_33`
- `ten_inch`: `Ecounity_10in_API_33`

Prepared Android screenshots are re-encoded as opaque 24-bit PNGs and capped at
the first 8 sorted screenshots per device type because Google Play allows up to
8 screenshots in each device bucket.

If Android screenshot generation stalls mid-run, stop the current lane and
resume the full screenshot lane. Resume mode preserves
`build/fastlane/raw/android`, skips target-locale batches that already contain
at least `SCREENSHOT_MINIMUM_COUNT` non-empty PNGs, and prepares all selected
targets together after the missing batches are captured:

```sh
cd android
bundle exec fastlane screenshots resume:true
```

To keep the computer awake for the whole Android screenshot lane, run:

```sh
cd android
PATH=/opt/homebrew/opt/ruby/bin:$PATH caffeinate -dimsu bundle exec fastlane screenshots resume:true
```

For a focused diagnostic run, narrow the target/locales explicitly, for example
`bundle exec fastlane screenshots targets:phone locales:fi`.

For a clean start that recreates every selected screenshot, omit `resume:true`.

Validate the prepared iOS screenshot set without uploading:

```sh
cd ios
bundle exec fastlane validate_screenshots
```

Upload only screenshots:

```sh
cd ios
bundle exec fastlane upload_screenshots force:true
```

The upload lane uploads screenshots in one-locale/one-device batches, replaces
existing App Store Connect screenshots by default, and uses
`DELIVER_NUMBER_OF_THREADS=1` unless you override it. This keeps Apple's
screenshot placeholder API from being hit too aggressively. Pass `append:true`
only when you intentionally do not want Fastlane to clear existing screenshots.

If a network or App Store Connect failure interrupts the upload, resume from a
locale:

```sh
cd ios
bundle exec fastlane upload_screenshots force:true start_locale:fi
```

```sh
cd android
bundle exec fastlane upload_screenshots
```

Dry-run the Google Play screenshot edit without committing:

```sh
cd android
bundle exec fastlane upload_screenshots validate_only:true
```

If Play Console shows uploaded assets in the asset selector but not in the
listing sections, run `check_store_listing_assets strict:true`. If the API shows
the expected counts, the assets are attached in Google Play's edit/review state
even when the Console UI is still showing the live listing or pending changes
view.

## Releases

Build locally:

```sh
cd android
bundle exec fastlane build
```

For a local Android build check before the upload keystore exists:

```sh
cd android
bundle exec fastlane build allow_debug_signing:true
```

```sh
cd ios
bundle exec fastlane build
```

Upload Android internal testing:

```sh
cd android
bundle exec fastlane internal
```

Create a draft Google Play production release:

```sh
cd android
bundle exec fastlane release
```

Include listing text in the draft release:

```sh
cd android
bundle exec fastlane release upload_metadata:true
```

Include localized production release notes for the current build:

```sh
cd android
bundle exec fastlane release upload_changelogs:true
```

Release notes are read from
`android/fastlane/metadata/android/<locale>/changelogs/<version-code>.txt`.
For build `17`, the prepared files are `changelogs/17.txt`; each locale also
has `changelogs/default.txt` as a fallback.

Upload to TestFlight:

```sh
cd ios
bundle exec fastlane beta setup_signing:true
```

Upload an App Store release without submitting for review:

```sh
cd ios
bundle exec fastlane release
```

To include store assets, pass `upload_metadata:true` and/or
`upload_screenshots:true` on the matching platform lane. To submit to Apple review, pass
`submit_for_review:true force:true`.
