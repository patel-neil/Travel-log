import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:http/http.dart' as http;

class UpdateEntryPage extends StatefulWidget {
  final PocketBase pb;
  final RecordModel entry;

  UpdateEntryPage({required this.pb, required this.entry});

  @override
  _UpdateEntryPageState createState() => _UpdateEntryPageState();
}

class _UpdateEntryPageState extends State<UpdateEntryPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry.data['title']);
    _locationController = TextEditingController(text: widget.entry.data['location']);
    _descriptionController = TextEditingController(text: widget.entry.data['description']);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateEntry() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final data = {
          "title": _titleController.text,
          "location": _locationController.text,
          "description": _descriptionController.text,
        };

        // Update the entry
        await widget.pb.collection('entries').update(widget.entry.id, body: data);

        // Upload the image if selected
        if (_imageFile != null) {
          final fileBytes = await _imageFile!.readAsBytes();
          final file = http.MultipartFile.fromBytes(
            'image',
            fileBytes,
            filename: 'image.jpg',
          );

          await widget.pb.collection('entries').update(
            widget.entry.id,
            body: {},
            files: [file],
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Entry updated successfully')),
        );
        Navigator.pop(context); // Go back to the previous page
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update entry: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Update Entry')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Location'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Select Image'),
              ),
              if (_imageFile != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Image.file(_imageFile!, height: 100, fit: BoxFit.cover),
                ),
              SizedBox(height: 16),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _updateEntry,
                child: Text('Update Entry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}