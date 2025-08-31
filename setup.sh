#!/bin/bash

echo "🚀 Setting up EcoVision with Google Maps integration..."

# Check if CocoaPods is installed
if ! command -v pod &> /dev/null; then
    echo "📦 Installing CocoaPods..."
    sudo gem install cocoapods
else
    echo "✅ CocoaPods is already installed"
fi

# Install pods
echo "📱 Installing Google Maps dependencies..."
pod install

echo ""
echo "🎉 Setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Open 'EcoVision.xcworkspace' (not .xcodeproj)"
echo "2. Get your Google Maps API key from: https://console.cloud.google.com/apis/credentials"
echo "3. Update the API key in 'EcoVision/GoogleMapsConfig.swift'"
echo "4. Build and run the project"
echo ""
echo "⚠️  Important: Make sure to open the .xcworkspace file, not the .xcodeproj file!"
