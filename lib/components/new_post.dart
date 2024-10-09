import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewPostPage extends StatefulWidget {
  const NewPostPage({super.key});

  @override
  _NewPostPageState createState() => _NewPostPageState();
}

class _NewPostPageState extends State<NewPostPage> {
  final TextEditingController postController = TextEditingController();
  final String currentUserEmail = "madhawaawishka@gmail.com"; // Hardcoded user email

  void addNewPost() {
    if (postController.text.isNotEmpty) {
      FirebaseFirestore.instance.collection('User Posts').add({
        'User email': currentUserEmail,
        'Message': postController.text,
        'TimeStamps': Timestamp.now(),
        'Likes': [],
      }).then((_) {
        Navigator.pop(context); // Go back to CommunityPage after posting
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create New Posts",style: TextStyle(color: Colors.black,
            fontWeight: FontWeight.bold,)),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: postController,
              decoration: const InputDecoration(
                labelText: "Write your post",
                border: OutlineInputBorder(),
              ),
              maxLines: 5, // Allow multiline input
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
    postController.dispose(); // Clean up the controller when not needed
    super.dispose();
  }
}
