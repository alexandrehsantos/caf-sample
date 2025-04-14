# CAF Flutter Test

A Flutter application demonstrating integration with CAF Document Detector using a middleware API.

## Setup Instructions

1. Make sure you have Flutter installed and set up on your development machine

2. Install dependencies:
   ```
   flutter pub get
   ```

3. Ensure your middleware server is running at the correct address:
   - The app is configured to connect to: `http://localhost:34775/api/KYC/caf-token`
   - If your server is at a different address, update the `apiUrl` in `lib/services/auth_service.dart`

4. Run the app:
   ```
   flutter run
   ```

## Features

- Connects to your middleware server to obtain CAF tokens
- Uses tokens to initialize the CAF Document Detector SDK
- Supports multiple document capture flows:
  - RG Front and Back
  - CNH Front and Back
  - CNH Full
- Toggle between test and production environments
- Displays detailed capture results

## Usage

1. Enter a valid CPF/ID in the text field
2. Tap "Get Token & Continue" to request a token from your middleware
3. Select a document type to capture
4. Follow the on-screen instructions to capture the document
5. View the capture results

## Project Structure

```
lib/
├── main.dart                        # App entry point
├── screens/                         # UI screens
│   ├── home_screen.dart             # User input & token request
│   └── document_capture_screen.dart # Document detection
├── services/                        # Business logic
│   ├── auth_service.dart            # Token handling
│   └── caf_service.dart             # CAF SDK integration
└── models/                          # Data models
    └── token_response.dart          # Token response structure
```

## Middleware Integration

This app connects to a middleware server that generates CAF tokens according to CAF's security requirements. The server must implement an endpoint that:

1. Accepts a POST request with the user's ID: `{"exchangeUserId": "12345678900"}`
2. Returns a JWT token in the format: `{"token": "...", "expiresAt": 1234567890}`

For more details on the middleware implementation, see the `CAFConnector` in your server project. 