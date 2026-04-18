import 'package:flutter/foundation.dart';

class BackendConfig {
  // Use http://10.0.2.2:8000 for Android Emulator
  // Use http://localhost:8000 for Windows/Web
  // Use your local IP (e.g., http://192.168.1.x:8000) for real devices
  static String get baseUrl => kIsWeb || defaultTargetPlatform == TargetPlatform.windows 
      ? "http://127.0.0.1:8000" 
      : "http://10.0.2.2:8000";
}
