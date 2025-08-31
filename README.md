# EcoVision - iOS Recycling App

A SwiftUI-based iOS application that helps users identify recyclable items and find nearby recycling locations using Google Maps integration via CocoaPods.

## Features

- **AI-Powered Waste Classification**: Advanced ChatGPT integration for accurate waste identification
- **Ballarat Recycling Standards**: Localized recycling rules for Ballarat, Victoria, Australia
- **Smart Bin Recommendations**: Get specific bin type and disposal instructions
- **Confidence Scoring**: See AI confidence levels for classifications
- **Special Collection Detection**: Identify items requiring special disposal
- **Container Deposit Scheme (CDS)**: Automatic detection of eligible drink containers
- **Interactive Google Maps**: View recycling locations on an interactive Google Maps interface
- **Location Filtering**: Filter locations by type (Container Deposit, Glass, E-Waste)
- **Detailed Location Information**: View opening hours, accepted items, and get directions
- **Waste Collection Calendar**: Track upcoming waste collection dates
- **User Profile Management**: Manage address and preferences

## AI Integration

This app uses OpenAI's GPT-4o model for intelligent waste classification according to Ballarat, Australia recycling standards.

### AI Setup

1. **Get an OpenAI API Key**:
   - Go to [OpenAI Platform](https://platform.openai.com/api-keys)
   - Create a new API key
   - Ensure you have access to GPT-4o model

2. **Configure the API Key**:
   - Open `EcoVision/AIConfig.swift`
   - Replace `YOUR_OPENAI_API_KEY` with your actual API key

3. **AI Features**:
   - **Real-time Image Analysis**: Upload photos for instant waste classification
   - **Local Standards**: Tailored for Ballarat, Victoria recycling rules
   - **Confidence Scoring**: See how confident the AI is in its classification
   - **Special Collections**: Automatic detection of items requiring special disposal
   - **CDS Detection**: Identify Container Deposit Scheme eligible items

## Maps Integration

This app uses Google Maps for location display and interaction via CocoaPods integration.

### Setup

1. **Get a Google Maps API Key**:
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Create a new project or select an existing one
   - Enable the following APIs:
     - Maps SDK for iOS
     - Places API
   - Create credentials (API Key) for iOS applications

2. **Configure the API Key**:
   - Open `EcoVision/GoogleMapsConfig.swift`
   - Replace `YOUR_GOOGLE_MAPS_API_KEY_HERE` with your actual API key

3. **Install Dependencies**:
   ```bash
   pod install
   ```

4. **Open Workspace**:
   - Open `EcoVision.xcworkspace` (not .xcodeproj) after running pod install

## Project Structure

```
EcoVision/
├── EcoVision/
│   ├── EcoVisionApp.swift          # Main app entry point
│   ├── ContentView.swift           # Main navigation and tab structure
│   ├── HomeView.swift              # Camera and image picker interface
│   ├── MapView.swift               # Google Maps integration
│   ├── GoogleMapsConfig.swift      # Google Maps configuration
│   ├── GooglePlacesService.swift   # Google Places API service
│   ├── AddressSearchView.swift     # Address search UI component
│   ├── AIService.swift             # ChatGPT integration for waste classification
│   ├── AIConfig.swift              # AI configuration and settings
│   ├── AILoadingView.swift         # AI processing loading screen
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

## AI Features

- **Smart Waste Classification**: Advanced AI analysis using GPT-4o model
- **Ballarat Standards**: Tailored for local recycling rules in Ballarat, Victoria
- **Bin Type Detection**: Automatic classification into Yellow, Red, Green, Special, or CDS bins
- **Confidence Scoring**: Visual indicators for AI confidence levels
- **Special Collection Items**: Automatic detection of items requiring special disposal
- **Container Deposit Scheme**: Identify eligible drink containers for 10c refund
- **Detailed Instructions**: Specific disposal instructions for each item
- **Real-time Processing**: Fast image analysis with loading animations
- **Text-based Search**: Manual search with AI-powered classification
- **Search Button**: Interactive search button with loading states
- **Error Handling**: Graceful error handling for search failures

## Maps Features

- **Interactive Google Maps**: Pan, zoom, and explore recycling locations
- **Custom Markers**: Color-coded markers for different recycling types
- **Location Details**: Tap markers to view location information
- **Directions**: Get directions to recycling locations via Google Maps
- **Custom Map Styling**: Eco-friendly map appearance

## Address Search Features

- **Google Places Autocomplete**: Smart address search powered by Google Places API
- **Real-time Suggestions**: Get address suggestions as you type (minimum 3 characters)
- **Location Bias**: Results prioritized for Melbourne, Australia area
- **Waste Collection Integration**: Automatically fetch collection data for selected addresses
- **User-friendly Interface**: Clean dropdown with address details and clear button
- **Error Handling**: Graceful handling of network issues and API errors

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
- **Google Maps**: Refer to [Google Maps iOS SDK Documentation](https://developers.google.com/maps/documentation/ios-sdk)
- **CocoaPods**: Refer to [CocoaPods Documentation](https://cocoapods.org/)
- **SwiftUI**: Refer to [Apple Developer Documentation](https://developer.apple.com/documentation/swiftui/)
