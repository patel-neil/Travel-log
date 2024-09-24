import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel Journal',
      theme: ThemeData(
        primaryColor: Colors.blueAccent,
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.orangeAccent),
        textTheme: TextTheme(
          headlineMedium: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          bodyLarge: TextStyle(color: Colors.black54),
        ),
      ),
      home: HomePage(pb: PocketBase('http://127.0.0.1:8090')), // Initialize with the appropriate URL
    );
  }
}

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
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
      ),
    );
  }
}

class ExplorePage extends StatelessWidget {
  final PocketBase pb;

  ExplorePage({required this.pb});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Explore'),
        centerTitle: true,
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
              return Card(
                margin: EdgeInsets.all(8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(Icons.place),
                  title: Text(
                    entry.data['title'] ?? 'No Title',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    entry.data['location'] ?? 'No Location',
                    style: TextStyle(color: Colors.grey),
                  ),
                  onTap: () {
                    // Navigate to detail page
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AddEntryPage extends StatefulWidget {
  final PocketBase pb;

  AddEntryPage({required this.pb});

  @override
  _AddEntryPageState createState() => _AddEntryPageState();
}

class _AddEntryPageState extends State<AddEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  Future<void> _addEntry() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final data = {
          "title": _titleController.text,
          "location": _locationController.text,
          "description": _descriptionController.text,
          "user": widget.pb.authStore.model?.id,
        };
        await widget.pb.collection('entries').create(body: data);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Entry added successfully')),
        );
        _titleController.clear();
        _locationController.clear();
        _descriptionController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add entry: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Entry'), backgroundColor: Colors.blueAccent),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _addEntry,
                child: Text('Save Entry'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.blueAccent,
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
      appBar: AppBar(title: Text('Profile'), backgroundColor: Colors.blueAccent),
      body: Center(
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
              Text(username, style: Theme.of(context).textTheme.headlineMedium),
              SizedBox(height: 8),
              Text(email, style: TextStyle(color: Colors.grey)),
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
    );
  }
}
