# Overview

This repository contains the Talabiyah Extract PoC - a comprehensive Flutter web application that serves as an advanced product and cart data extractor for e-commerce websites. The app uses sophisticated WebView technology with multi-method JavaScript injection to extract product and cart data from major e-commerce platforms (Shein, Noon, Amazon.ae) using JSON-LD parsing, DOM scraping, META tag analysis, and network request interception. The project is currently deployed and running successfully on port 5000.

## User Preferences

Preferred communication style: Simple, everyday language.

## System Architecture

### Web Framework
The application is built using Flutter (Dart) targeting web deployment specifically. The architecture follows a standard Flutter project structure optimized for web deployment with Material 3 design system. The current implementation is deployed on port 5000 and accessible through web browsers.

### WebView Integration
The core functionality relies on `webview_flutter` to embed web pages within the mobile application. JavaScript is enabled within the WebView to allow for dynamic content manipulation and data extraction.

### JavaScript Injection System
A sophisticated JavaScript injection system is implemented with multiple layers:

1. **Bootstrap Layer** (`bootstrap.js`): Initializes the global namespace (`__masab` or `__talabiyah`) and establishes communication bridge with Flutter through `TalaBridge.postMessage()`
2. **Collectors Layer** (`collectors.js`): Contains generic product and cart collection functions that work across different websites
3. **Adapters Layer**: Site-specific JavaScript modules for Amazon.ae, Noon, and Shein that handle unique DOM structures and CSS selectors for each platform

### Communication Architecture
Data flows from JavaScript to Flutter using a JavaScript channel named `TalaBridge`. The JavaScript code packages extracted product/cart data as JSON and sends it to the Flutter layer, which can then process and display the results.

### State Management
The applications are designed to use `flutter_riverpod` for state management, providing a reactive approach to handling extracted data and application state.

### Project Structure
Both applications follow an identical modular structure:
- `screens/`: Contains UI screens for store selection, WebView display, and results
- `state/`: Houses state management logic and data models
- `widgets/`: Reusable UI components including floating action buttons
- `services/`: Business logic for JavaScript injection and domain detection
- `assets/injection/`: JavaScript files organized by function and website-specific adapters

### Data Extraction Strategy
The system employs multiple extraction methods:
- DOM element querying using CSS selectors
- JSON-LD structured data parsing
- Meta tag analysis
- Network request interception (for cart data)

Each website adapter contains specific selectors optimized for that platform's HTML structure, ensuring robust data extraction even when websites update their layouts.

## External Dependencies

### Flutter Packages
- `webview_flutter`: Enables WebView functionality within Flutter applications
- `flutter_riverpod`: Provides state management capabilities
- `fluttertoast`: Displays toast notifications for user feedback
- `path_provider` and `permission_handler`: Optional packages for local file storage (developer mode)

### Target E-commerce Platforms
- **Shein**: Fashion and lifestyle e-commerce platform
- **Noon**: Middle Eastern e-commerce marketplace
- **Amazon.ae**: Amazon's UAE regional website

### Development Tools
- Flutter SDK 3.x+ for cross-platform mobile development
- Dart programming language
- Platform-specific build tools (Xcode for iOS, Android Studio/Gradle for Android)

### Asset Dependencies
The applications bundle JavaScript assets that are loaded into WebViews at runtime. These assets are platform-agnostic and work across different website structures by using adaptive CSS selectors and fallback mechanisms.