# AdvancedChatChallenge Blueprint

## Overview

This document outlines the architecture, features, and implementation plan for the **AdvancedChatChallenge** application. This is a full-stack Flutter mobile application using GetX for state management and Firebase for the backend.

## Architecture

The application will follow a layered architecture:

*   **Presentation:** Contains the UI (Widgets and Views) and the GetX controllers that manage the UI state.
*   **Domain:** Defines the core business logic and data models of the application.
*   **Data:** Handles data operations, including communication with Firebase services through repositories.

## Implemented Features

This section will be updated as features are implemented.

### Version 1.0 (Initial Setup)

*   **Project Structure:** Created the basic folder structure for the application.
*   **Dependencies:** Added necessary packages to `pubspec.yaml`.
*   **Firebase Setup:** Configured Firebase for the project.
*   **Models:** Created `AppUser` and `Message` models.
*   **Repositories:** Created `AuthRepository` and `ChatRepository`.
*   **Controllers:** Created `AuthController` and `ChatController`.
*   **Views:** Created basic UI for sign-up, chat list, and chat screens.

## Current Plan

The following steps will be taken to build the application:

1.  **Project Setup:**
    *   Create the necessary folders: `data`, `domain`, `presentation`.
    *   Create subfolders within `data`: `repositories`.
    *   Create subfolders within `domain`: `models`.
    *   Create subfolders within `presentation`: `controllers`, `views`, `widgets`.

2.  **Add Dependencies:**
    *   `get`: For state management.
    *   `firebase_core`: To connect to Firebase.
    *   `firebase_auth`: For authentication.
    *   `cloud_firestore`: For the database.
    *   `firebase_storage`: For file storage.
    *   `image_picker`: To pick images from the gallery.

3.  **Implement Models:**
    *   Create `app_user.dart` in `lib/domain/models`.
    *   Create `message.dart` in `lib/domain/models`.

4.  **Implement Repositories:**
    *   Create `auth_repository.dart` in `lib/data/repositories`.
    *   Create `chat_repository.dart` in `lib/data/repositories`.

5.  **Implement Controllers:**
    *   Create `auth_controller.dart` in `lib/presentation/controllers`.
    *   Create `chat_controller.dart` in `lib/presentation/controllers`.

6.  **Implement Views:**
    *   Create `signup_screen.dart` in `lib/presentation/views`.
    *   Create `chat_list_screen.dart` in `lib/presentation/views`.
    *   Create `chat_screen.dart` in `lib/presentation/views`.

7.  **Implement Widgets:**
    *   Create `message_bubble.dart` in `lib/presentation/widgets`.
    *   Create `chat_input.dart` in `lib/presentation/widgets`.
    *   Create `profile_avatar.dart` in `lib/presentation/widgets`.

8.  **Implement Firebase Security Rules:**
    *   Create `firestore.rules` with the specified security rules.

9.  **Implement Unit Test:**
    *   Create a test file for the timestamp formatting utility.
