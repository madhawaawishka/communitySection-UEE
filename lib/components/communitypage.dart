import 'package:community/components/wall_posts.dart';
import 'package:community/helper/helper_method.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'new_post.dart'; // Import the new post page

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Explore Communities",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ), // Set the text color to black
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        centerTitle: true, // Center the title
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.black), // Plus icon in black color
            onPressed: () {
              // Navigate to new_post.dart
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewPostPage()),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[200], // Change this color to any you like
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("User Posts")
                    .orderBy("TimeStamps", descending: false)
                    .snapshots(),
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
            // Remove the message input section here
          ],
        ),
      ),
    );
  }
}
