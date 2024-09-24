import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'home_page.dart';

void main() {
  runApp(TravelJournalApp());
}

class TravelJournalApp extends StatelessWidget {
  final PocketBase pb = PocketBase('http://127.0.0.1:8090');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel Journal',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(pb: pb, onLogin: () {
          Navigator.pushReplacementNamed(context, '/home');
        }),
        '/signup': (context) => SignupPage(pb: pb),
        '/home': (context) => HomePage(pb: pb),
      },
    );
  }
}