import 'package:community/components/wall_posts.dart';
import 'package:community/helper/helper_method.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Import fluttertoast package for showing toast messages
import 'new_post.dart'; // Import the new post page

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final String currentUserEmail = "madhawaawishka@gmail.com"; // Hardcoded user email

  // Function to delete a post
  void deletePost(String postId) {
    FirebaseFirestore.instance.collection('User Posts').doc(postId).delete();
    Fluttertoast.showToast(msg: "Post deleted successfully.");
  }

  // Function to edit a post
  void editPost(BuildContext context, String postId, String currentMessage) {
    TextEditingController editController = TextEditingController(text: currentMessage);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Post"),
          content: TextField(
            controller: editController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: "Edit your post",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance.collection('User Posts').doc(postId).update({
                  'Message': editController.text
                });
                Navigator.pop(context);
                Fluttertoast.showToast(msg: "Post updated successfully.");
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Explore Communities",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewPostPage()),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection("User Posts").orderBy("TimeStamps", descending: false).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final post = snapshot.data!.docs[index];
                        final postId = post.id;
                        final postMessage = post['Message'];
                        final postUserEmail = post['User email'];

                        return Dismissible(
                          key: Key(postId),
                          background: Container(
                            color: Colors.green,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            child: const Icon(Icons.edit, color: Colors.white),
                          ),
                          secondaryBackground: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.startToEnd) {
                              // Swipe right to edit
                              if (postUserEmail == currentUserEmail) {
                                editPost(context, postId, postMessage);
                                return false; // Prevent dismissal after editing
                              } else {
                                Fluttertoast.showToast(msg: "You can only edit your own posts.");
                                return false; // Do not dismiss if not post owner
                              }
                            } else if (direction == DismissDirection.endToStart) {
                              // Swipe left to delete
                              if (postUserEmail == currentUserEmail) {
                                deletePost(postId);
                                return true; // Allow dismissal after deletion
                              } else {
                                Fluttertoast.showToast(msg: "You cannot delete someone else's post.");
                                return false; // Do not dismiss if not post owner
                              }
                            }
                            return false;
                          },
                          child: WallPosts(
                            message: postMessage,
                            user: postUserEmail,
                            postId: postId,
                            likes: List<String>.from(post['Likes'] ?? []),
                            time: formatDate(post['TimeStamps']),
                          ),
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
          ],
        ),
      ),
    );
  }
}
