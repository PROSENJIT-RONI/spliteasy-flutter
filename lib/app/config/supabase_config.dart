class SupabaseConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://hbxqtmjokuhufemekdhs.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhieHF0bWpva3VodWZlbWVrZGhzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODk0NTU5OTIsImV4cCI6MjEwNTAzMTk5Mn0.mNGor6LL2roIvQ4sZ6sc8uoEVbzfp8mQr4hzXwYqEH8',
  );
}
