import 'dart:io'; // For working with files
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart'; // For picking images
import 'package:firebase_storage/firebase_storage.dart'; // For uploading to Firebase Storage

class NewPostPage extends StatefulWidget {
  const NewPostPage({super.key});

  @override
  _NewPostPageState createState() => _NewPostPageState();
}

class _NewPostPageState extends State<NewPostPage> {
  final TextEditingController postController = TextEditingController();
  final String currentUserEmail = "madhawaawishka@gmail.com";
  File? _selectedImage; // To store the selected image
  bool isLoading = false; // To show a loading spinner while uploading

  // Function to pick an image
  Future<void> pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  // Function to upload image to Firebase Storage and get the download URL
  Future<String> uploadImage(File image) async {
    final storageRef = FirebaseStorage.instance.ref().child('post_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await storageRef.putFile(image);
    return await storageRef.getDownloadURL();
  }

  // Function to add a new post with an optional image
  Future<void> addNewPost() async {
    if (postController.text.isNotEmpty || _selectedImage != null) {
      setState(() {
        isLoading = true;
      });

      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await uploadImage(_selectedImage!);
      }

      FirebaseFirestore.instance.collection('User Posts').add({
        'User email': currentUserEmail,
        'Message': postController.text,
        'TimeStamps': Timestamp.now(),
        'Likes': [],
        'ImageURL': imageUrl, // Store the image URL if it exists
      }).then((_) {
        setState(() {
          isLoading = false;
        });
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create New Post", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: postController,
                    decoration: const InputDecoration(
                      labelText: "Write your post",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                  ),
                  const SizedBox(height: 20),
                  _selectedImage != null
                      ? Image.file(_selectedImage!, height: 150)
                      : const Text('No image selected'),
                  ElevatedButton(
                    onPressed: pickImage,
                    child: const Text("Pick Image from Gallery"),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: addNewPost,
                    child: const Text("Post"),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    postController.dispose();
    super.dispose();
  }
}
