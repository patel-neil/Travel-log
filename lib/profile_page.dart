import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

class ProfilePage extends StatelessWidget {
  final PocketBase pb;

  ProfilePage({required this.pb});

  @override
  Widget build(BuildContext context) {
    final user = pb.authStore.model;

    // Check if user is logged in
    if (!pb.authStore.isValid || user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/login');
      });
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),  // Show loading state
        ),
      );
    }

    final username = user.data['name'] ?? 'No name available';
    final email = user.data['email'] ?? 'No email available';

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade800, Colors.blue.shade400],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade300,
                  child: Icon(Icons.person, size: 50, color: Colors.blueAccent),
                ),
                SizedBox(height: 16),
                Text(
                  username,
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(color: Colors.white),
                ),
                SizedBox(height: 8),
                Text(
                  email,
                  style: TextStyle(color: Colors.white70),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    pb.authStore.clear(); // Log out user
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                  child: Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.redAccent,
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
