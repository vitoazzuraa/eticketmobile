import 'package:supabase_flutter/supabase_flutter.dart';

// Panggil ini sekali di main.dart sebelum runApp()
Future<void> initSupabase() async {
  await Supabase.initialize(
    url: 'https://lzzsdnzuqknjmzvrzmtc.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx6enNkbnp1cWtuam16dnJ6bXRjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE1NDQ0NDIsImV4cCI6MjA5NzEyMDQ0Mn0.UXyJxamUwa7ItOgYr72IAwihQuiDYIwP_WgceqmRFIU',
  );
}

// Dipakai di service lain untuk akses Supabase
final supabase = Supabase.instance.client;