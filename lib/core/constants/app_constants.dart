class AppConstants {
  // Supabase Configuration
  static const String supabaseUrl = 'https://sepqtryulowfzjnnapsv.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNlcHF0cnl1bG93Znpqbm5hcHN2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIwNjQyMDUsImV4cCI6MjA3NzY0MDIwNX0.bhiLgWU6_J_9IpOSZfVBWnWUY98qApyla8tXC5Y3dK4';
  
  // Table Names
  static const String usersTable = 'users';
  static const String chatsTable = 'chats';
  static const String messagesTable = 'messages';
  static const String messageStatusTable = 'message_status';
  
  // Storage Buckets
  static const String mediaStorageBucket = 'media';
  static const String avatarsStorageBucket = 'avatars';
  
  // Message Types
  static const String messageTypeText = 'text';
  static const String messageTypeImage = 'image';
  static const String messageTypeVideo = 'video';
  
  // Message Status
  static const String messageStatusSent = 'sent';
  static const String messageStatusDelivered = 'delivered';
  static const String messageStatusRead = 'read';
}

