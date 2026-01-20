#!/bin/bash
set -e

VERSION="${1:-0.3.0-alpha}"
SIGNING_IDENTITY="${2:-}"

echo "Building Ports v$VERSION..."

# Build release
swift build -c release

# Create app bundle
echo "Creating app bundle..."
rm -rf Ports.app
mkdir -p Ports.app/Contents/MacOS
mkdir -p Ports.app/Contents/Resources

cp .build/release/PortViewer Ports.app/Contents/MacOS/Ports
chmod +x Ports.app/Contents/MacOS/Ports

cat > Ports.app/Contents/Info.plist << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>Ports</string>
    <key>CFBundleIdentifier</key>
    <string>com.corvidlabs.ports</string>
    <key>CFBundleName</key>
    <string>Ports</string>
    <key>CFBundleDisplayName</key>
    <string>Ports</string>
    <key>CFBundleVersion</key>
    <string>${VERSION}</string>
    <key>CFBundleShortVersionString</key>
    <string>${VERSION}</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
PLIST

# Sign if identity provided
if [ -n "$SIGNING_IDENTITY" ]; then
    echo "Signing with: $SIGNING_IDENTITY"
    codesign --force --options runtime --sign "$SIGNING_IDENTITY" --timestamp Ports.app/Contents/MacOS/Ports
    codesign --force --options runtime --sign "$SIGNING_IDENTITY" --timestamp Ports.app
    echo "Verifying signature..."
    codesign --verify --verbose Ports.app
else
    echo "No signing identity provided, using ad-hoc signing..."
    codesign --force --deep --sign - Ports.app
fi

# Create DMG
echo "Creating DMG..."
rm -rf dmg_contents Ports-${VERSION}.dmg
mkdir -p dmg_contents
cp -r Ports.app dmg_contents/
ln -s /Applications dmg_contents/Applications

if command -v create-dmg &> /dev/null; then
    create-dmg \
        --volname "Ports" \
        --window-pos 200 120 \
        --window-size 600 400 \
        --icon-size 100 \
        --icon "Ports.app" 150 185 \
        --icon "Applications" 450 185 \
        --hide-extension "Ports.app" \
        --app-drop-link 450 185 \
        --no-internet-enable \
        "Ports-${VERSION}.dmg" \
        "dmg_contents/" || hdiutil create -volname "Ports" -srcfolder dmg_contents -ov -format UDZO "Ports-${VERSION}.dmg"
else
    hdiutil create -volname "Ports" -srcfolder dmg_contents -ov -format UDZO "Ports-${VERSION}.dmg"
fi

rm -rf dmg_contents

echo ""
echo "✓ Built Ports.app"
echo "✓ Created Ports-${VERSION}.dmg"
echo ""
echo "To install locally:"
echo "  cp -r Ports.app /Applications/"
echo "  open /Applications/Ports.app"
echo ""
echo "To sign and notarize (after adding secrets to GitHub):"
echo "  gh workflow run release.yml -f version=$VERSION"
