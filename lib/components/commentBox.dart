import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comment_box/comment/comment.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class TestMe extends StatefulWidget {
  @override
  _TestMeState createState() => _TestMeState();
}

class _TestMeState extends State<TestMe> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController commentController = TextEditingController(); // For new comments
  final TextEditingController editCommentController = TextEditingController(); // For editing comments
  String? selectedCommentId; // Holds the ID of the comment being edited

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp(); // Initialize Firebase
    fetchComments(); // Fetch comments on page load
  }

  List filedata = [];

  Future<void> fetchComments() async {
    // Fetch comments from Firebase
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Comments').orderBy('date', descending: true).get();
    setState(() {
      filedata = snapshot.docs.map((doc) => {
        'id': doc.id,
        'name': doc['name'],
        'pic': doc['pic'],
        'message': doc['message'],
        'date': doc['date'],
      }).toList();
    });
  }

  // This method provides the background when swiping left (for delete)
  Widget slideLeftBackground() {
    return Container(
      color: Colors.red,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(width: 20),
            Icon(Icons.delete, color: Colors.white),
            Text(
              "Delete",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }

  // This method provides the background when swiping right (for edit)
  Widget slideRightBackground() {
    return Container(
      color: Colors.blue,
      child: Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Icon(Icons.edit, color: Colors.white),
            Text(
              " Edit",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.right,
            ),
            SizedBox(width: 20),
          ],
        ),
      ),
    );
  }

  Widget commentChild(data) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        return Dismissible(
          key: UniqueKey(),
          background: slideLeftBackground(), // Swipe left to delete
          secondaryBackground: slideRightBackground(), // Swipe right to edit
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              // Swipe Left to delete
              return await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Delete Confirmation"),
                    content: Text("Are you sure you want to delete this comment?"),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          deleteComment(data[index]['id']);
                          Navigator.of(context).pop(true);
                        },
                        child: Text("Delete"),
                      ),
                    ],
                  );
                },
              );
            } else {
              // Swipe Right to edit
              editCommentController.text = data[index]['message']; // Set the message in the edit controller
              selectedCommentId = data[index]['id']; // Store the comment ID for editing
              await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Edit Comment"),
                    content: TextFormField(
                      controller: editCommentController, // Use the edit controller here
                      decoration: InputDecoration(hintText: "Edit your comment"),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          editComment(selectedCommentId!, editCommentController.text);
                          Navigator.of(context).pop();
                        },
                        child: Text("Save"),
                      ),
                    ],
                  );
                },
              );
              return false;
            }
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(2.0, 8.0, 2.0, 0.0),
            child: ListTile(
              leading: GestureDetector(
                onTap: () async {
                  print("Comment Clicked");
                },
                child: Container(
                  height: 50.0,
                  width: 50.0,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: CommentBox.commentImageParser(imageURLorPath: data[index]['pic']),
                  ),
                ),
              ),
              title: Text(
                data[index]['name'],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(data[index]['message']),
              trailing: Text(data[index]['date'], style: TextStyle(fontSize: 10)),
            ),
          ),
        );
      },
    );
  }

  Future<void> postComment() async {
    if (formKey.currentState!.validate()) {
      // Get the current date and time
      var now = DateTime.now();
      var formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

      // Add the new comment to Firebase
      await FirebaseFirestore.instance.collection('Comments').add({
        'name': 'Madhawa Awishka', // Hardcoded name
        'pic': 'https://randomuser.me/api/portraits/men/${filedata.length % 100}.jpg', // Placeholder image
        'message': commentController.text,
        'date': formattedDate,
      });

      // Fetch the updated comments after posting
      fetchComments();

      commentController.clear(); // Clear the new comment controller
      FocusScope.of(context).unfocus();
    }
  }

  Future<void> deleteComment(String commentId) async {
    // Delete the comment from Firebase
    await FirebaseFirestore.instance.collection('Comments').doc(commentId).delete();

    // Fetch the updated comments after deletion
    fetchComments();
  }

  Future<void> editComment(String commentId, String newMessage) async {
    // Edit the comment in Firebase
    await FirebaseFirestore.instance.collection('Comments').doc(commentId).update({
      'message': newMessage,
      'date': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()), // Update timestamp
    });

    // Fetch the updated comments after editing
    fetchComments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Comment Page"),
        backgroundColor: Colors.pink,
      ),
      body: Container(
        child: CommentBox(
          userImage: CommentBox.commentImageParser(imageURLorPath: "assets/img/userpic.jpg"),
          child: commentChild(filedata),
          labelText: 'Write a comment...',
          errorText: 'Comment cannot be blank',
          withBorder: false,
          sendButtonMethod: postComment, // Send comment to Firebase
          formKey: formKey,
          commentController: commentController, // Use for new comment
          backgroundColor: Colors.pink,
          textColor: Colors.white,
          sendWidget: Icon(Icons.send_sharp, size: 30, color: Colors.white),
        ),
      ),
    );
  }
}
