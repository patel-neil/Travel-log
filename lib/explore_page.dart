import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'entry_detail_page.dart'; // Import the EntryDetailPage

class ExplorePage extends StatelessWidget {
  final PocketBase pb;

  ExplorePage({required this.pb});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Explore'),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<List<RecordModel>>(
        future: pb.collection('entries').getFullList(sort: '-created'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No entries found'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final entry = snapshot.data![index];
              final userId = entry.data['user']; // Get the user ID from entry
              return FutureBuilder<RecordModel?>(
                future: pb.collection('users').getOne(userId),
                builder: (context, userSnapshot) {
                  String username = 'Unknown User'; // Default username
                  if (userSnapshot.hasData && userSnapshot.data != null) {
                    username = userSnapshot.data!.data['name'] ?? 'Unknown User';
                  }

                  return Card(
                    margin: EdgeInsets.all(8),
                    elevation: 5, // Add elevation for a shadow effect
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16), // Add padding
                      leading: Icon(Icons.place, size: 40, color: Colors.blueAccent),
                      title: Text(
                        entry.data['title'] ?? 'No Title',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4),
                          Text(
                            entry.data['location'] ?? 'No Location',
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Created by: $username',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      onTap: () {
                        // Navigate to detail page with entry data
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => EntryDetailPage(entry: entry, pb: pb),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
