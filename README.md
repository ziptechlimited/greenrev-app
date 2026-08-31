# GreenRev - Mobile App

The official mobile companion app for the GreenRev automotive ecosystem. Built entirely in Flutter, this app delivers a seamless luxury automotive marketplace and concierge experience to iOS and Android users. It brings the full power of the GreenRev platform to your pocket with high-fidelity animations, real-time push notifications, mobile-optimized live chats, and an interactive radar-style map for discovering certified mechanics worldwide.

## Key Features

- **The Showroom & Selection (Cart)**:
  - Browse high-end performance vehicles with a smooth, glassmorphic UI matching the web aesthetic.
  - "Your Selection" interface allows seamless checkout and acquisition request generation.
- **My Requests (Acquisitions)**:
  - Track active orders, negotiations, and delivery statuses.
  - Interactive status badges (`PENDING`, `PROCESSING`, `COMPLETED`, `CANCELLED`).
- **Real-Time Concierge Chat**:
  - WebSockets-powered messaging for negotiating with vendors or speaking with GreenRev support.
  - Fully integrated local push notifications for new messages and status updates.
- **Global Expert Care Map**:
  - Interactive map integration using `flutter_map` with CartoDB Dark Matter tiles.
  - Pulsing radar animations precisely mimicking the web app's Framer Motion effects, allowing users to find and book certified mechanics.
- **Floating Navigation & UI**:
  - Features an intuitive floating bottom navigation bar and a globally accessible floating user avatar for profile management.

## Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (Dart)
- **State Management**: `provider`
- **Networking**: `http` (REST), `socket_io_client` (WebSockets)
- **Map Engine**: `flutter_map` & `latlong2` (OpenStreetMap / CartoDB)
- **Notifications**: `flutter_local_notifications`
- **UI/UX**: Custom `CustomPainter` elements, `google_fonts`, `shimmer` loading states.

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.12.2 or higher)
- Android Studio / Xcode for device simulation
- A running instance of the **GreenRev Backend Server**.

### Installation

1. Navigate to the mobile directory:
   ```bash
   cd greenrev-mobile
   ```

2. Get Flutter dependencies:
   ```bash
   flutter pub get
   ```

3. Configure Environment / API URL:
   By default, the app points to the production URL (`https://api.greenrevs.com`). 
   To connect to your local backend for development, pass the override flag when running:
   ```bash
   flutter run --dart-define=API_BASE_URL=http://localhost:4000
   ```
   *(For Android emulators, use `http://10.0.2.2:4000` instead of localhost).*

## Project Structure

- `lib/core`: App-wide utilities, theme definitions (`AppTheme`), network clients (`ApiClient`), and the global `SocketService`.
- `lib/modules`: Domain-driven feature sets:
  - `/home`: Splash screens and the `MainShell` layout containing the bottom navigation.
  - `/shop`: The Showroom UI and inventory cards.
  - `/cart`: "Your Selection" management.
  - `/acquisitions`: "My Requests" transaction tracking.
  - `/mechanics`: The "Expert Care" interactive map interface.
  - `/chat`: Real-time WebSockets messaging screens.
  - `/onboarding`: Login, Register, and Splash flows.

## License

All rights reserved to GreenRev.
