import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_api_availability/google_api_availability.dart';
import 'package:l_f/Backend/Login/login.dart';
import 'package:l_f/Frontend/Top/home_screen.dart';
import 'package:l_f/firebase_options.dart';

void main() async {
  BindingBase.debugZoneErrorsAreFatal = true;
  WidgetsFlutterBinding.ensureInitialized();

  Future<void> checkGooglePlayServices() async {
    GooglePlayServicesAvailability availability = await GoogleApiAvailability
        .instance
        .checkGooglePlayServicesAvailability();

    switch (availability) {
      case GooglePlayServicesAvailability.success:
        print('Google Play Services is available');
        break;
      case GooglePlayServicesAvailability.serviceMissing:
      case GooglePlayServicesAvailability.serviceVersionUpdateRequired:
      case GooglePlayServicesAvailability.serviceDisabled:
        // Show a message to the user or prompt them to update Google Play Services
        print('Google Play Services needs to be updated or enabled');
        break;
      default:
        print('Google Play Services status: $availability');
        break;
    }
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  PaintingBinding.instance.imageCache.clear();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CampusTracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthWrapper2(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Listen to FirebaseAuth's authStateChanges stream
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show a loading screen while Firebase is determining the auth status
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If the user is signed in, show HomePage; otherwise, show LoginPage
        if (snapshot.hasData) {
          return const HomePage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}

class AuthWrapper2 extends StatelessWidget {
  const AuthWrapper2({super.key});
// Trigger deployment
  @override
  Widget build(BuildContext context) {
    // Check if the user is signed in
    User? user = FirebaseAuth.instance.currentUser;

    // If the user is signed in, navigate to HomePage, otherwise navigate to LoginPage
    if (user != null) {
      return const HomePage();
    } else {
      return const LoginPage();
    }
  }
}
