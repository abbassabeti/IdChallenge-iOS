#!/bin/bash

# Set the framework name and output directory
FRAMEWORK_NAME="IdFramework"
OUTPUT_DIR="./XCFramework"

# Clean previous build artifacts
rm -rf $OUTPUT_DIR
mkdir $OUTPUT_DIR

# Derived data path (you can customize this if necessary)
DERIVED_DATA_PATH=$(mktemp -d)

# Build for iOS devices (arm64)
echo "Building $FRAMEWORK_NAME for iOS devices..."
xcodebuild archive \
  -scheme $FRAMEWORK_NAME \
  -sdk iphoneos \
  -configuration Release \
  -archivePath "$OUTPUT_DIR/ios_devices.xcarchive" \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  -derivedDataPath "$DERIVED_DATA_PATH"

# Build for iOS simulators (x86_64, arm64)
echo "Building $FRAMEWORK_NAME for iOS simulators..."
xcodebuild archive \
  -scheme $FRAMEWORK_NAME \
  -sdk iphonesimulator \
  -configuration Release \
  -archivePath "$OUTPUT_DIR/ios_simulators.xcarchive" \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  -derivedDataPath "$DERIVED_DATA_PATH"

# Create XCFramework
echo "Creating XCFramework..."
xcodebuild -create-xcframework \
  -framework "$OUTPUT_DIR/ios_devices.xcarchive/Products/Library/Frameworks/$FRAMEWORK_NAME.framework" \
  -framework "$OUTPUT_DIR/ios_simulators.xcarchive/Products/Library/Frameworks/$FRAMEWORK_NAME.framework" \
  -output "$OUTPUT_DIR/$FRAMEWORK_NAME.xcframework"

# Clean up Derived Data
echo "Cleaning up..."
rm -rf "$DERIVED_DATA_PATH"

echo "$FRAMEWORK_NAME.xcframework created successfully in $OUTPUT_DIR"
