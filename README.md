# Dealsdray

A Flutter app for onboarding users with phone verification, email registration, and device data logging.

## Overview

Dealsdray is a Flutter app that provides onboarding features, including phone number-based OTP verification, email-based registration, and device info logging. The app transitions smoothly between different screens and integrates with APIs to verify user data.

## Features

1. **Main.dart**
   - Entry point of the application
   - Initializes the Flutter app with `MaterialApp`
   - Sets up the initial route to `SplashScreen`
   - Disables the debug banner

2. **Splashscreen.dart**
   - Handles initial app loading and setup
   - Implements device information collection
     - Location permission checks
     - Device info gathering
     - IP address detection
   - Sends device data to API
   - Transitions to phone verification screen

3. **Login.dart**
   - Handles phone number-based authentication
   - Features:
     - Phone number validation
     - OTP sending functionality
     - Toggle between phone/email login
     - Custom UI with branded elements
     - Error handling and user feedback

4. **Emailsignup.dart**
   - Manages email-based registration
   - Features:
     - Email validation
     - Password creation
     - Optional referral code system
     - API integration for registration
     - Form validation and error handling

5. **Home.dart**
   - Main dashboard of the application
   - Features:
     - Search functionality
     - Banner slider with indicators
     - KYC status display
     - Category grid display
     - Product listings
     - Bottom navigation
     - Chat floating action button
     - API integration for home data

6. **Verification.dart**
   - Handles OTP verification process
   - Features:
     - 4-digit OTP input
     - Timer countdown (117 seconds)
     - Resend OTP functionality
     - Custom UI elements
     - Google Fonts integration

## Modular Approach

Each file follows a modular approach and implements specific functionality while maintaining consistent UI/UX patterns throughout the application. The codebase uses modern Flutter practices and includes proper error handling, state management, and API integrations.

## Getting Started

### Prerequisites

- Flutter 2.x or higher
- Android Studio or Visual Studio Code for development

### Setup

1. Clone this repository:
   ```bash
   git clone <[repository-url](https://github.com/nope3472/DealsDray.git)>
   flutter pub get
   flutter run

