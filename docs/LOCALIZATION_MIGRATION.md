# Localization System Migration

## Changes Made

This project was using **TWO conflicting localization systems**:
1. **Flutter Intl IDE Plugin** (generating `lib/generated/l10n.dart` and `lib/generated/intl/messages_*.dart`)
2. **Official Flutter gen-l10n** (generating `lib/l10n/app_localizations*.dart`)

### ✅ Migration Complete

The project now uses **ONLY the official Flutter gen-l10n system**.

## Files Modified

### 1. `/lib/l10n/app_localizations_extension.dart`
- **Changed from**: Wrapping the old `lib/generated/l10n.dart`
- **Changed to**: Wrapping the official `lib/l10n/app_localizations.dart`
- Simplified the wrapper to just provide the `l10n` extension method
- Added `appLocalizationsDelegates` helper function

### 2. `/lib/src/screens/slides/slides_carousel.dart`
- **Changed from**: `import 'package:ecounity/generated/l10n.dart';`
- **Changed to**: `import 'package:ecounity/l10n/app_localizations.dart';`

### 3. `/lib/main.dart`
- **Changed from**: `AppLocalizations.localizationsDelegates`
- **Changed to**: `appLocalizationsDelegates`

### 4. Added New Localization Keys
Added to all `.arb` files in `lib/l10n/`:
- `refresh`: "Refresh" (and translations)
- `cache_cleared`: "Cache cleared. Please reload the page." (and translations)

## Files That Can Be Safely Deleted

The following generated files from the old system are **NO LONGER USED** and can be deleted:
```
lib/generated/l10n.dart
lib/generated/intl/messages_all.dart
lib/generated/intl/messages_en.dart
lib/generated/intl/messages_de.dart
lib/generated/intl/messages_fi.dart
lib/generated/intl/messages_pt.dart
lib/generated/intl/messages_sl.dart
```

**DO NOT** manually edit these files if you keep them - they were auto-generated.

## How to Add New Translations

### Step 1: Edit the .arb files
Add new keys to files in `lib/l10n/`:
- `intl_en.arb` (English - template)
- `intl_fi.arb` (Finnish)
- `intl_de.arb` (German)
- `intl_pt.arb` (Portuguese)
- `intl_sl.arb` (Slovenian)

Example:
```json
{
  "my_new_key": "My new text",
  ...
}
```

### Step 2: Run the generator
```bash
./generate.sh
```

Or manually:
```bash
flutter gen-l10n
flutter packages pub run build_runner build
```

### Step 3: Use in code
```dart
Text(context.l10n.my_new_key)
```

## Configuration

The localization is configured in:
- **`l10n.yaml`**: Defines the gen-l10n configuration
  - Source: `lib/l10n/`
  - Template: `intl_en.arb`
  - Output: `app_localizations.dart`
  - Missing translations: `missingTranslations.txt`

## Current Localization System

✅ **Official Flutter gen-l10n** (recommended by Flutter team)
- Source: `.arb` files in `lib/l10n/`
- Generated files: `lib/l10n/app_localizations*.dart`
- Configuration: `l10n.yaml`
- Generation command: `flutter gen-l10n`

❌ **Flutter Intl Plugin** (REMOVED)
- ~~Source: `.arb` files~~
- ~~Generated files: `lib/generated/l10n.dart` and `lib/generated/intl/messages_*.dart`~~
- ~~Generation: IDE plugin or `intl_utils`~~

## Benefits of Single System

1. ✅ **No conflicts**: Only one source of truth
2. ✅ **Official support**: Uses Flutter's recommended approach
3. ✅ **Maintainable**: No manual edits to generated files
4. ✅ **Type-safe**: Compile-time checking of localization keys
5. ✅ **Simple**: One command to regenerate everything
