import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/session_picker_screen.dart';
import 'screens/create_account_screen.dart';
import 'screens/chat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ShadowChat());
}

class ShadowChat extends StatelessWidget {
  const ShadowChat({super.key});

  // This widget is the root of your application. TEST
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      initialRoute: WelcomeScreen.id,
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        CreateAccountScreen.id: (context) => CreateAccountScreen(),
        SessionPickerScreen.id: (context) => SessionPickerScreen(),
        ChatScreen.id: (context) => ChatScreen(),
      },
    );
  }
}
