# Flutter Real-Time Messaging App Challenge

Your task is to build a real-time chat app with a clean, production-friendly architecture.

## Requirements

### Real-time messaging
- Send and receive messages in real time (Firestore, Supabase Realtime, WebSockets, or similar).
- Each message shows sender name, text, and a formatted timestamp.
- Messages appear instantly without manual refresh.

### Chat interface
- Conversation-style UI (chat bubbles).
- Auto-scroll to newest message when messages arrive or are sent.
- Input field at the bottom to compose and send.

### Bonus (optional)
- Basic user identity (mock login or random user assignment).
- Chat list screen showing conversations.
- Message status (sent/delivered/seen).
- Offline handling and local caching.
- Unit tests for message formatting/time utils or basic logic.

## Engineering expectations
- Clean, feature-based or layered architecture.
- Consistent state management (Riverpod/Bloc/Provider/GetX).
- Repository pattern for data access.
- Reusable widgets and clear naming.
- Error, empty, and loading states.
- Clear separation of UI and business logic.

## How to run
Include all steps here in your submission (service keys, emulators, etc.).

## How to submit

1. **Fork** this repository.
2. Create a branch named with your full name:
   ```bash
   git checkout -b feature/your-full-name

