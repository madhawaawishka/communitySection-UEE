import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community/components/wall_posts.dart';
import 'package:community/helper/helper_method.dart';
import 'package:flutter/material.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final textController = TextEditingController();
  final String currentUserEmail = "madhawaawishka@gmail.com"; // Hardcoded current user

  void postMessage() {
    if (textController.text.isNotEmpty) {
      FirebaseFirestore.instance.collection("User Posts").add({
        'User email': currentUserEmail, // Use hardcoded user
        'Message': textController.text,
        'TimeStamps': Timestamp.now(),
        'Likes': [],
      });
      textController.clear(); // Clear the input field after posting
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Explore Communites",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ), // Set the text color to white
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        centerTitle: true, // Center the title
      ),
      backgroundColor: Colors.grey[200], // Change this color to any you like
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection("User Posts").orderBy("TimeStamps", descending: false).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length, // Add itemCount
                      itemBuilder: (context, index) {
                        final post = snapshot.data!.docs[index];
                        return WallPosts(
                          message: post['Message'],
                          user: post['User email'],
                          postId: post.id,
                          likes: List<String>.from(post['Likes'] ?? []),
                          time: formatDate(post['TimeStamps']),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: textController,
                      decoration: const InputDecoration(
                        hintText: "Enter your message",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: postMessage,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
            Text("Logged in as " + currentUserEmail!, style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0))), // Display hardcoded user email
          ],
        ),
      ),
    );
  }
}
