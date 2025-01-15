import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pages/splash_screen.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/admin_dashboard.dart';
import 'pages/restaurant_dashboard.dart';
import 'pages/driver_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(KoboApp());
}

class KoboApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kobo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      debugShowCheckedModeBanner: false,
      // Supprimez la route '/' et utilisez uniquement home
      routes: {
        '/home': (context) => HomePage(),
        '/login': (context) => LoginPage(),
        '/admin-dashboard': (context) => AdminDashboard(),
        '/restaurant-dashboard': (context) => RestaurantDashboard(),
        '/driver-dashboard': (context) => DriverDashboard(),
      },
      home: AuthenticationWrapper(),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(snapshot.data!.uid)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                FirebaseAuth.instance.signOut();
                return LoginPage();
              }

              final userData = userSnapshot.data!.data() as Map<String, dynamic>;
              final String role = userData['role'] ?? 'pending';

              if (!['admin', 'restaurant', 'driver'].contains(role)) {
                FirebaseAuth.instance.signOut();
                return LoginPage();
              }

              switch (role) {
                case 'admin':
                  return AdminDashboard();
                case 'restaurant':
                  return RestaurantDashboard();
                case 'driver':
                  return DriverDashboard();
                default:
                  FirebaseAuth.instance.signOut();
                  return LoginPage();
              }
            },
          );
        }
        return LoginPage();
      },
    );
  }
}
