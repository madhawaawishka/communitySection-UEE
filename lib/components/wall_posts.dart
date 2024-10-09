import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community/components/comment.dart';
import 'package:community/components/comment_button.dart';
import 'package:community/components/like_button.dart';
import 'package:community/helper/helper_method.dart';
import 'package:flutter/material.dart';

class WallPosts extends StatefulWidget {
  final String message;
  final String user;
  final String time;
  final String postId;
  final List<String> likes;

  const WallPosts({
    super.key,
    required this.message,
    required this.user,
    required this.postId,
    required this.likes,
    required this.time,
  });

  @override
  State<WallPosts> createState() => _WallPostsState();
}

class _WallPostsState extends State<WallPosts> {
  final String currentUserEmail = "madhawaawishka@gmail.com";
  bool isLiked = false;
  final _commentTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isLiked = widget.likes.contains(currentUserEmail);
  }

  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });

    DocumentReference postRef = FirebaseFirestore.instance.collection('User Posts').doc(widget.postId);

    if (isLiked) {
      postRef.update({
        'Likes': FieldValue.arrayUnion([
          currentUserEmail
        ])
      });
    } else {
      postRef.update({
        'Likes': FieldValue.arrayRemove([
          currentUserEmail
        ])
      });
    }
  }

  void addComment(String commentText) {
    FirebaseFirestore.instance.collection('User Posts').doc(widget.postId).collection("Comments").add({
      "CommentText": commentText,
      "CommentedBy": currentUserEmail,
      "CommentTime": Timestamp.now(),
    });
  }

  void showCommentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add a comment"),
        content: TextField(
          controller: _commentTextController,
          decoration: const InputDecoration(hintText: "Write a comment..."),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _commentTextController.clear();
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (_commentTextController.text.isNotEmpty) {
                addComment(_commentTextController.text);
                Navigator.pop(context);
                _commentTextController.clear();
              }
            },
            child: const Text("Post"),
          ),
        ],
      ),
    );
  }

  void deletePost() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Post"),
        content: const Text("Are you sure you want to delete this post?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              try {
                final commentDocs = await FirebaseFirestore.instance.collection("User Posts").doc(widget.postId).collection("Comments").get();

                for (var doc in commentDocs.docs) {
                  await FirebaseFirestore.instance.collection("User Posts").doc(widget.postId).collection("Comments").doc(doc.id).delete();
                }

                await FirebaseFirestore.instance.collection("User Posts").doc(widget.postId).delete();

                print("Post Deleted");
              } catch (error) {
                print("Failed to delete the post: $error");
              }

              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEBF4FB), // White background for better contrast
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 4), // Soft shadow
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.message,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.user,
                            style: TextStyle(color: Colors.grey[600]),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Text("•", style: TextStyle(color: Colors.grey)),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            widget.time,
                            style: TextStyle(color: Colors.grey[600]),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Removed the DeleteButton here
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  LikeButton(isLiked: isLiked, onTap: toggleLike),
                  const SizedBox(height: 5),
                  Text(
                    widget.likes.length.toString(),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              Column(
                children: [
                  CommentButton(onTap: showCommentDialog),
                  const SizedBox(height: 5),
                  const Text(
                    '0',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection("User Posts").doc(widget.postId).collection("Comments").orderBy("CommentTime", descending: true).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: snapshot.data!.docs.map((doc) {
                  final commentData = doc.data() as Map<String, dynamic>;
                  final commentUser = commentData["CommentedBy"] ?? "Unknown user";

                  return Comment(
                    text: commentData["CommentText"],
                    user: commentUser,
                    time: formatDate(commentData["CommentTime"]),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
