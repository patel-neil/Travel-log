import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'explore_page.dart';
import 'add_entry_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  final PocketBase pb;

  HomePage({required this.pb});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      ExplorePage(pb: widget.pb),
      AddEntryPage(pb: widget.pb),
      ProfilePage(pb: widget.pb),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add Entry'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
