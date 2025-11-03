# Supabase Database Setup

This document contains the SQL schema and setup instructions for the real-time messaging application.

## Prerequisites

1. Create a Supabase account at https://supabase.com
2. Create a new project in Supabase
3. Get your project URL and anon key from Project Settings > API

## Database Schema

Run the following SQL commands in your Supabase SQL Editor (in order):

### 1. Create Users Table

```sql
-- Create users table
CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL UNIQUE,
  display_name TEXT NOT NULL,
  avatar_url TEXT,
  bio TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_seen TIMESTAMP WITH TIME ZONE,
  is_online BOOLEAN DEFAULT FALSE
);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Create policies for users table
CREATE POLICY "Users can view all profiles"
  ON users FOR SELECT
  USING (true);

CREATE POLICY "Users can update own profile"
  ON users FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON users FOR INSERT
  WITH CHECK (auth.uid() = id);
```

### 2. Create Chats Table

```sql
-- Create chats table
CREATE TABLE chats (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  participant_ids UUID[] NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE chats ENABLE ROW LEVEL SECURITY;

-- Create policies for chats table
CREATE POLICY "Users can view their chats"
  ON chats FOR SELECT
  USING (auth.uid() = ANY(participant_ids));

CREATE POLICY "Users can create chats"
  ON chats FOR INSERT
  WITH CHECK (auth.uid() = ANY(participant_ids));

CREATE POLICY "Users can update their chats"
  ON chats FOR UPDATE
  USING (auth.uid() = ANY(participant_ids));

-- Create index for faster queries
CREATE INDEX idx_chats_participant_ids ON chats USING GIN (participant_ids);
CREATE INDEX idx_chats_updated_at ON chats (updated_at DESC);
```

### 3. Create Messages Table

```sql
-- Create messages table
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chat_id UUID NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  message_type TEXT DEFAULT 'text' CHECK (message_type IN ('text', 'image', 'video')),
  media_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  status TEXT DEFAULT 'sent' CHECK (status IN ('sent', 'delivered', 'read')),
  is_read BOOLEAN DEFAULT FALSE,
  read_at TIMESTAMP WITH TIME ZONE
);

-- Enable Row Level Security
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Create policies for messages table
CREATE POLICY "Users can view messages in their chats"
  ON messages FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM chats
      WHERE chats.id = messages.chat_id
      AND auth.uid() = ANY(chats.participant_ids)
    )
  );

CREATE POLICY "Users can insert messages in their chats"
  ON messages FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM chats
      WHERE chats.id = messages.chat_id
      AND auth.uid() = ANY(chats.participant_ids)
    )
    AND auth.uid() = sender_id
  );

CREATE POLICY "Users can update their own messages"
  ON messages FOR UPDATE
  USING (auth.uid() = sender_id);

CREATE POLICY "Users can delete their own messages"
  ON messages FOR DELETE
  USING (auth.uid() = sender_id);

-- Create indexes for faster queries
CREATE INDEX idx_messages_chat_id ON messages (chat_id);
CREATE INDEX idx_messages_created_at ON messages (created_at);
CREATE INDEX idx_messages_sender_id ON messages (sender_id);
```

### 4. Create Storage Buckets

```sql
-- Create storage buckets for avatars and media
INSERT INTO storage.buckets (id, name, public)
VALUES 
  ('avatars', 'avatars', true),
  ('media', 'media', true);

-- Create storage policies for avatars bucket
CREATE POLICY "Avatar images are publicly accessible"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'avatars');

CREATE POLICY "Users can upload their own avatar"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'avatars'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can update their own avatar"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'avatars'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- Create storage policies for media bucket
CREATE POLICY "Media files are publicly accessible"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'media');

CREATE POLICY "Authenticated users can upload media"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'media'
    AND auth.role() = 'authenticated'
  );
```

### 5. Enable Realtime

```sql
-- Enable realtime for all tables
ALTER PUBLICATION supabase_realtime ADD TABLE users;
ALTER PUBLICATION supabase_realtime ADD TABLE chats;
ALTER PUBLICATION supabase_realtime ADD TABLE messages;
```

### 6. Create Functions and Triggers

```sql
-- Function to update chat's updated_at timestamp
CREATE OR REPLACE FUNCTION update_chat_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE chats
  SET updated_at = NOW()
  WHERE id = NEW.chat_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update chat timestamp when a new message is inserted
CREATE TRIGGER update_chat_timestamp_trigger
AFTER INSERT ON messages
FOR EACH ROW
EXECUTE FUNCTION update_chat_timestamp();

-- Function to automatically update user's last_seen
CREATE OR REPLACE FUNCTION update_user_last_seen()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE users
  SET last_seen = NOW()
  WHERE id = auth.uid();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

## Configuration

After setting up the database:

1. Go to your Supabase project settings
2. Navigate to API section
3. Copy the following values:
   - Project URL
   - Anon/Public Key

4. Update `lib/core/constants/app_constants.dart`:

```dart
class AppConstants {
  static const String supabaseUrl = 'YOUR_PROJECT_URL';
  static const String supabaseAnonKey = 'YOUR_ANON_KEY';
  // ... rest of the constants
}
```

## Testing the Setup

You can test the setup by:

1. Creating a test user through the app's signup flow
2. Checking if the user appears in the `users` table
3. Creating a chat and sending messages
4. Verifying real-time updates work correctly

## Realtime Subscriptions

The app uses Supabase Realtime to listen for:
- New messages in chat rooms
- Chat list updates
- User online status changes

Make sure Realtime is enabled in your Supabase project settings.

## Security Notes

- Row Level Security (RLS) is enabled on all tables
- Users can only access chats they are participants in
- Users can only send messages in their own chats
- Storage policies ensure users can only upload to their own folders
- All sensitive operations require authentication

