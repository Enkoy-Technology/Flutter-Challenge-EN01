# Flutter Real-Time Chat App

A modern, real-time messaging application built with Flutter and Firebase. This project is a submission for the Flutter Developer Challenge, designed to showcase a clean, scalable architecture, a polished user experience, and a rich feature set.

<img width="900" height="680" alt="App Screenshot" src="https://github.com/user-attachments/assets/78ff4712-9a69-4395-8993-b1f4fb8eb646" />

## ✨ Features

### Core Requirements
- ✅ **Real-time Messaging**: Messages are sent and received instantly using Firestore streams.
- ✅ **Message Display**: Each message bubble clearly displays the message text and a formatted timestamp.
- ✅ **Instant Updates**: The UI updates automatically without any need for manual refresh.
- ✅ **Conversation UI**: A modern, conversation-style UI with distinct chat bubbles for the sender and receiver.
- ✅ **Auto-Scroll**: The chat view automatically scrolls to the latest message upon sending or receiving.
- ✅ **Message Input**: A clean and simple input field at the bottom for composing and sending messages.

### 🚀 Bonus Features Implemented
- ✅ **User Authentication**: Full email/password authentication flow with separate, beautifully designed Login and Signup screens.
- ✅ **User Profile**: A dedicated profile page displaying the user's name, avatar (initials), and email, with a logout option.
- ✅ **Dynamic Chat List**: The main screen displays a list of active conversations, automatically sorted by the most recent message activity.
- ✅ **"Seen" Status Indicators**: Sent messages display a single tick (✓) for sent and a double tick (✓✓) for seen, providing clear feedback.
- ✅ **"Typing..." Indicator**: A real-time typing indicator appears when the other user is composing a message.
- ✅ **Unit Tests**: Includes unit tests for the timestamp formatting logic to ensure reliability.
- ✅ **Modern UI/UX**: A creative and polished user interface with custom themes, animations, and a focus on a great user experience.

## 🏗️ Architecture & Tech Stack

This project follows a clean, layered architecture to ensure separation of concerns, maintainability, and scalability.

*   **Presentation Layer**: Contains all UI-related components, including views (screens), custom widgets, and GetX controllers that manage the UI state.
*   **Domain Layer**: Defines the core business logic and data models of the application (e.g., `AppUser`, `Message`).
*   **Data Layer**: Manages all data operations through repositories, abstracting the data source (Firebase) from the rest of the application.

### Tech Stack
- **Framework**: Flutter
- **Language**: Dart
- **Backend**: Firebase (Authentication, Cloud Firestore, App Check)
- **State Management**: GetX
- **UI Design**: Material 3
- **Fonts**: `google_fonts`
- **Formatting**: `intl`

## ⚙️ Getting Started

### Prerequisites
- Flutter SDK installed.
- A Firebase project set up.

### Installation
1.  **Clone the repository:**
    ```sh
    git clone <your-fork-url>
    cd Flutter-Challenge-EN01
    ```

2.  **Set up Firebase:**
    -   Follow the FlutterFire CLI documentation to configure the app with your own Firebase project. This will generate a `lib/firebase_options.dart` file.
    -   In the Firebase Console, enable **Authentication** (with Email/Password provider) and **Cloud Firestore**.
    -   Create the necessary Firestore composite index by following the link that appears in the debug console on the first run.

3.  **Install dependencies:**
    ```sh
    flutter pub get
    ```

4.  **Run the application:**
    ```sh
    flutter run
    ```

## 📂 Folder Structure

```
lib
├── app.dart              # Root MyApp widget
├── main.dart             # Application entry point
├── injection_dependec.dart # Handles dependency injection
├── config/
│   └── routes.dart       # Defines all application routes
├── data/
│   └── repositories/     # Handles data operations (e.g., AuthRepository)
├── domain/
│   └── models/           # Core data models (e.g., AppUser, Message)
└── presentation/
    ├── controllers/      # GetX controllers for state management
    ├── views/            # UI screens (e.g., ChatListScreen, ChatScreen)
    └── widgets/          # Reusable UI components (e.g., MessageBubble)
```

---

## Submission Instructions

1.  **Fork the challenge repository**
    -   (https://github.com/Enkoy-Technology/Flutter-Challenge-EN01)

2.  **Create a new branch** named after your full name:
    ```sh
    git checkout -b feature/Your-first-Name
    ```

3.  **Build your solution** and commit your work with clear messages:
    ```sh
    git add .
    git commit -m "Complete real-time chat challenge"
    ```

4.  **Push your branch** to your fork:
    ```sh
    git push origin feature/Your-first-Name
    ```

5.  **Open a Pull Request** to the main repository's `main` branch.
    -   **PR title format:** `Flutter Challenge Submission - Your First Name`
</code></pre>
