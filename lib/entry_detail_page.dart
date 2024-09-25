import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'update_entry_page.dart'; // Import the UpdateEntryPage

class EntryDetailPage extends StatelessWidget {
  final RecordModel entry;
  final PocketBase pb;

  EntryDetailPage({required this.entry, required this.pb});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(entry.data['title'] ?? 'Entry Details')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title: ${entry.data['title'] ?? 'No Title'}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Location: ${entry.data['location'] ?? 'No Location'}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Description: ${entry.data['description'] ?? 'No Description'}', style: TextStyle(fontSize: 14)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => UpdateEntryPage(pb: pb, entry: entry),
                  ),
                );
              },
              child: Text('Edit Entry'),
            ),
          ],
        ),
      ),
    );
  }
}
