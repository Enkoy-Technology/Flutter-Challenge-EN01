# 💬 Flutter Chat App

A production-ready, real-time chat application built with **Flutter**, featuring **Clean Architecture**, **GetX state management**, **Firestore** real-time database, and **Cloudinary** media storage.

[![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-blue?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0%2B-blue?logo=dart)](https://dart.dev)
[![GetX](https://img.shields.io/badge/GetX-4.6%2B-green)](https://github.com/jonataslaw/getx)
[![Firebase](https://img.shields.io/badge/Firebase-Connected-yellow?logo=firebase)](https://firebase.google.com)

---

## 🎯 Overview

This Flutter Chat App demonstrates production-level best practices:

- ✅ **Clean Architecture** - Proper separation of concerns
- ✅ **Feature-Based Structure** - Organized by features
- ✅ **GetX State Management** - Efficient reactive programming
- ✅ **Animated Transitions** - Smooth page navigation
- ✅ **Real-time Messaging** - Firestore streams for instant updates
- ✅ **Media Sharing** - Cloudinary integration for images
- ✅ **Responsive Design** - Works on all devices

---

## ✨ Features

### 🔐 Authentication
- Email/password registration
- Secure login system
- Session persistence

### 💬 Messaging
- Real-time message delivery
- Message status indicators (sent, delivered, read)
- Auto-scroll to latest messages
- Message search & filtering

### 📸 Media Support
- Image sharing via Cloudinary
- Image preview in chat
- File size validation
- Automatic image optimization

### 👥 User Management
- User profiles with avatars
- Online/offline status
- Last seen timestamps

### 🎨 UI/UX Features
- Beautiful message bubbles
- Dark/Light theme support
- Loading & error states
- Empty state messages
- Smooth animations

### 🔔 Advanced Features
- Read receipts
- Unread message counters
- Chat list with sorting
- Search conversations
- Delete chats
- Message pagination

---

## 📊 Tech Stack

| Category | Technology |
|----------|------------|
| **Frontend** | Flutter 3.0+, Dart 3.0+ |
| **State Management** | GetX 4.6+ |
| **Authentication** | Firebase Authentication |
| **Database** | Cloud Firestore |
| **Media Storage** | Cloudinary |
| **Architecture** | Clean Architecture |
| **Pattern** | Repository Pattern |

---

## 🚀 Getting Started

### Prerequisites

```bash
- Flutter SDK 3.0+
- Dart 3.0+
- Firebase account
- Cloudinary account
- Android SDK 21+ or iOS 13.0+
```

### Step 1: Clone Repository



### Step 2: Install Dependencies


### Step 3: Firebase Setup



### Step 4: Firestore Security Rules

Go to Firebase Console → Firestore → Rules and replace:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }

    // Chats collection
    match /chats/{chatId} {
      allow read: if request.auth != null && 
                     request.auth.uid in resource.data.participants;
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
                       request.auth.uid in resource.data.participants;

      // Messages subcollection
      match /messages/{messageId} {
        allow read: if request.auth != null && 
                       request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.participants;
        allow create: if request.auth != null && 
                         request.auth.uid == request.resource.data.senderId;
        allow update, delete: if request.auth != null && 
                                 request.auth.uid == resource.data.senderId;
      }
    }
  }
}
```

Click **Publish**.

### Step 5: Cloudinary Setup

1. Sign up: https://cloudinary.com/users/register_free
2. Get **Cloud name** from Dashboard
3. Go to Settings → Upload
4. Create unsigned upload preset

### Step 6: Update Credentials

In `features/chat/data/datasources/chat_remote_datasource.dart`:

```dart
_cloudinaryService = CloudinaryService(
  cloudName: 'YOUR_CLOUD_NAME',
  uploadPreset: 'YOUR_UPLOAD_PRESET',
);
```

### Step 7: Run the App

```bash
flutter clean
flutter pub get
flutter run

```

---

## 📱 Usage Guide

### Creating Account
1. Tap **"Sign Up"**
2. Enter name, email, password
3. Confirm password
4. Tap **"Sign Up"**

### Logging In
1. Enter email and password
2. Tap **"Login"**

### Sending Messages
1. Go to Chat List
2. Select conversation
3. Type message
4. Tap send button

### Sharing Images
1. Tap image icon (gallery)
2. Select image or take photo
3. Image uploads automatically

### Profile
1. Tap person icon in header
2. View profile
3. Logout if needed

---

## 🏗️ Project Structure

```
lib/
├── main.dart
├── firebase_options.dart
├── app/
│   ├── routes/
│   ├── themes/
│   └── bindings/
├── core/
│   ├── utils/
│   ├── widgets/
│   └── services/
└── features/
    ├── auth/
    ├── chat/
    └── profile/
```

---

## 📚 Clean Architecture

```
PRESENTATION LAYER
├── Screens (Views)
├── Widgets
└── Controllers (GetX)
        ↓
DOMAIN LAYER
├── Entities
├── Repositories (Interfaces)
└── Use Cases
        ↓
DATA LAYER
├── Models
├── Repositories (Implementation)
└── Remote Data Sources
        ↓
CORE LAYER
├── Utils
├── Services
└── Constants
```

---
## 📚 Resources

- [Flutter Docs](https://flutter.dev/docs)
- [GetX Documentation](https://github.com/jonataslaw/getx)
- [Firebase Docs](https://firebase.google.com/docs)
- [Cloudinary Docs](https://cloudinary.com/documentation)
- [Clean Architecture Guide](https://resocoder.com/flutter-clean-architecture)

---

## 🤝 Contributing

1. **Fork** the repository
2. **Create** feature branch: \`git checkout -b feature/amazing-feature\`
3. **Commit** changes: \`git commit -m 'Add feature'\`
4. **Push** to branch: \`git push origin feature/amazing-feature\`
5. **Open** Pull Request

---

## 📄 License

MIT License - See LICENSE file for details

---

## 👨‍💻 Author

**Your Name**
- GitHub: [@TitusKI](https://github.com/TitusKI)
- Email: k.mariambezie@gmail.com


---

## 🙏 Acknowledgments

- Flutter team for amazing framework
- GetX community for state management
- Firebase for backend services
- Cloudinary for media hosting

---

## ⭐ Show Your Support

Give a star if you like this project!

---

**Made with ❤️ for Flutter developers**

Last Updated: November 3, 2025, 1:49 AM EAT  
Version: 1.0.0
