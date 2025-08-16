#!/bin/bash

# Download fonts for typstwriter package
# This script downloads fonts from official sources

set -e

FONTS_DIR="$(dirname "$0")/../packages/typstwriter/fonts"
TEMP_DIR=$(mktemp -d)

echo "📦 Downloading fonts for typstwriter package..."
echo "📁 Target directory: $FONTS_DIR"

# Create fonts directory
mkdir -p "$FONTS_DIR"

# Download Iosevka Nerd Font (NFP variant)
echo "⬇️  Downloading Iosevka Nerd Font..."
IOSEVKA_VERSION="v3.1.1"
IOSEVKA_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/${IOSEVKA_VERSION}/Iosevka.zip"

curl -L "$IOSEVKA_URL" -o "$TEMP_DIR/Iosevka.zip"
unzip -j "$TEMP_DIR/Iosevka.zip" "IosevkaNerdFont-Regular.ttf" "IosevkaNerdFont-Bold.ttf" -d "$FONTS_DIR/"

# Download Hack Nerd Font (NFM variant) 
echo "⬇️  Downloading Hack Nerd Font..."
HACK_VERSION="v3.1.1"
HACK_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/${HACK_VERSION}/Hack.zip"

curl -L "$HACK_URL" -o "$TEMP_DIR/Hack.zip"
unzip -j "$TEMP_DIR/Hack.zip" "HackNerdFontMono-Regular.ttf" "HackNerdFontMono-Bold.ttf" -d "$FONTS_DIR/"

# Download Noto Color Emoji
echo "⬇️  Downloading Noto Color Emoji..."
NOTO_URL="https://github.com/googlefonts/noto-emoji/raw/main/fonts/NotoColorEmoji.ttf"
curl -L "$NOTO_URL" -o "$FONTS_DIR/NotoColorEmoji.ttf"

# Cleanup
rm -rf "$TEMP_DIR"

echo "✅ Fonts downloaded successfully!"
echo "📊 Font sizes:"
ls -lh "$FONTS_DIR"/*.ttf

echo ""
echo "🎨 Total package size:"
du -sh "$FONTS_DIR"

echo ""
echo "✨ Ready to use bundled fonts in typstwriter package!"
