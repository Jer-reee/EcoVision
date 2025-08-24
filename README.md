# EcoVision - iOS Recycling App

A SwiftUI-based iOS application that helps users identify recyclable items and find nearby recycling locations using Apple Maps integration (with Google Maps coming via Swift Package Manager).

## Features

- **AI-Powered Item Recognition**: Identify recyclable items using camera or photo library
- **Interactive Apple Maps**: View recycling locations on an interactive map
- **Location Filtering**: Filter locations by type (Container Deposit, Glass, E-Waste)
- **Detailed Location Information**: View opening hours, accepted items, and get directions
- **Waste Collection Calendar**: Track upcoming waste collection dates
- **User Profile Management**: Manage address and preferences

## Maps Integration

This app currently uses Apple Maps for location display and will be upgraded to Google Maps via Swift Package Manager.

### Current Status

- ✅ **Apple Maps Integration**: Fully functional with custom markers
- 🔄 **Google Maps Integration**: Coming soon via Swift Package Manager
- ✅ **Location Data**: Sample recycling locations included

### Future Google Maps Setup (Coming Soon)

1. **Get a Google Maps API Key**:
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Create a new project or select an existing one
   - Enable the following APIs:
     - Maps SDK for iOS
     - Places API
   - Create credentials (API Key) for iOS applications

2. **Configure the API Key**:
   - Open `EcoVision/GoogleMapsConfig.swift`
   - Replace the placeholder with your actual API key

## Project Structure

```
EcoVision/
├── EcoVision/
│   ├── EcoVisionApp.swift          # Main app entry point
│   ├── ContentView.swift           # Main navigation and tab structure
│   ├── HomeView.swift              # Camera and image picker interface
│   ├── MapView.swift               # Maps integration (Apple Maps + Google Maps coming)
│   ├── GoogleMapsConfig.swift      # Google Maps configuration (for future use)
│   ├── CalendarView.swift          # Waste collection calendar
│   ├── ProfileView.swift           # User profile and settings
│   ├── ResultViews.swift           # AI recognition results
│   ├── SupportingViews.swift       # Reusable UI components
│   ├── DataModels.swift            # Data structures
│   ├── WasteCollectionService.swift # Waste collection logic
│   └── NotificationManager.swift   # Local notifications
└── EcoVision.xcodeproj/            # Xcode project file
```

## Building and Running

1. **Prerequisites**:
   - Xcode 15.0 or later
   - iOS 17.0 or later

2. **Open Project**:
   - Open `EcoVision.xcodeproj` directly
   - Configure your development team in project settings

3. **Run**:
   - Select your target device or simulator
   - Press Cmd+R to build and run

## Maps Features

- **Interactive Map View**: Pan, zoom, and explore recycling locations
- **Custom Markers**: Color-coded markers for different recycling types
- **Location Details**: Tap markers to view location information
- **Directions**: Get directions to recycling locations
- **Location Services**: Show user's current location

## Location Types

1. **Container Deposit Scheme (CDS)**: 
   - Blue markers
   - Accepts drink containers for 10c refund

2. **Glass Recycling**:
   - Green markers
   - Specialized glass collection points

3. **E-Waste**:
   - Orange markers
   - Electronics and technology recycling

## Customization

### Adding New Locations

Edit the `allLocations` array in `MapView.swift`:

```swift
Location(
    name: "New Recycling Center",
    address: "123 Example St, City VIC 3000",
    latitude: -37.8136,
    longitude: 144.9631,
    type: .containerDeposit,
    openingHours: "9:00am-6:00pm Mon-Fri",
    website: "https://example.com",
    acceptedItems: ["Item 1", "Item 2"]
)
```

### Changing Default Location

Update the coordinates in `GoogleMapsConfig.swift`:

```swift
static let defaultLatitude = -37.8136
static let defaultLongitude = 144.9631
static let defaultZoom: Float = 10.0
```

## Troubleshooting

### Common Issues

1. **Build Errors**:
   - Clean build folder (Cmd+Shift+K)
   - Check that you're opening `.xcodeproj` file

2. **Location Permissions**:
   - Ensure location permissions are granted
   - Check project settings for proper permission descriptions

## License

This project is for educational and demonstration purposes.

## Support

For issues related to:
- **Apple Maps**: Refer to [Apple Developer Documentation](https://developer.apple.com/documentation/mapkit)
- **SwiftUI**: Refer to [Apple Developer Documentation](https://developer.apple.com/documentation/swiftui/)
