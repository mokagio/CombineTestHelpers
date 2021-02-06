#!/bin/bash

set -e

rm -rf DerivedData

tuist generate

xcodebuild \
  -project ./IntegrationTests.xcodeproj \
  -scheme iosTests \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 12 Pro,OS=latest' \
  test | xcbeautify

xcodebuild \
  -project ./IntegrationTests.xcodeproj \
  -scheme macosTests \
  -sdk macosx \
  test | xcbeautify
