#!/bin/sh
flutter gen-l10n
# generate the hive adapters
flutter packages pub run build_runner build --delete-conflicting-outputs
