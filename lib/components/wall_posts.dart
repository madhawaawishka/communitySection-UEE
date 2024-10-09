import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community/components/comment.dart';
import 'package:community/components/comment_button.dart';
import 'package:community/components/like_button.dart';
import 'package:community/helper/helper_method.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart'; // For image storage
import 'package:image_picker/image_picker.dart'; // For selecting images
import 'dart:io';

class WallPosts extends StatefulWidget {
  final String message;
  final String user;
  final String time;
  final String postId;
  final List<String> likes;
  final String? imageUrl; // Add imageUrl to the constructor for image fetching

  const WallPosts({
    super.key,
    required this.message,
    required this.user,
    required this.postId,
    required this.likes,
    required this.time,
    this.imageUrl, // Optional image URL
  });

  @override
  State<WallPosts> createState() => _WallPostsState();
}

class _WallPostsState extends State<WallPosts> {
  final String currentUserEmail = "madhawaawishka@gmail.com";
  bool isLiked = false;
  final _commentTextController = TextEditingController();
  File? _imageFile; // To store the selected image

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
        'Likes': FieldValue.arrayUnion([currentUserEmail])
      });
    } else {
      postRef.update({
        'Likes': FieldValue.arrayRemove([currentUserEmail])
      });
    }
  }

  // Select image from gallery
  Future<void> _selectImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      _uploadImage();
    }
  }

  // Upload image to Firebase Storage and get the URL
  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    Reference storageRef = FirebaseStorage.instance.ref().child('post_images').child(fileName);

    UploadTask uploadTask = storageRef.putFile(_imageFile!);
    TaskSnapshot snapshot = await uploadTask;

    String downloadUrl = await snapshot.ref.getDownloadURL();
    
    // Update the Firestore document with the image URL
    FirebaseFirestore.instance.collection('User Posts').doc(widget.postId).update({
      'imageUrl': downloadUrl,
    });
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEBF4FB),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 4),
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
              // Button to select image from gallery,
            ],
          ),
          const SizedBox(height: 20),

          // Show uploaded image if it exists
          if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Image.network(widget.imageUrl!),
            ),

         // Inside the build method
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
        // Replace '0' with a StreamBuilder to get the comment count
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("User Posts")
              .doc(widget.postId)
              .collection("Comments")
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Text('0', style: TextStyle(color: Colors.grey));
            }
            // Get the number of comments
            final commentCount = snapshot.data!.docs.length;
            return Text(
              commentCount.toString(),
              style: const TextStyle(color: Colors.grey),
            );
          },
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
