import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'signup_page.dart'; // Import the signup page

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final PocketBase pb = PocketBase('http://10.0.2.2:8090');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Travel Journal',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(pb: pb, onLogin: () {
          Navigator.of(context).pushReplacementNamed('/home');
        }),
        '/home': (context) => HomePage(pb: pb),
        '/signup': (context) => SignupPage(pb: pb), // Add the signup route
      },
    );
  }
}
