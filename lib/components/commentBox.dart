import 'package:comment_box/comment/comment.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class TestMe extends StatefulWidget {
  @override
  _TestMeState createState() => _TestMeState();
}

class _TestMeState extends State<TestMe> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController commentController = TextEditingController();
  List filedata = [
    {
      'name': 'Chamal Lakshan', 
      'pic': 'https://randomuser.me/api/portraits/men/1.jpg',
      'message': 'I love to learn those',
      'date': '2021-01-01 12:00:00'
    },
    {
      'name': 'Nuwan Malinda',
      'pic': 'https://randomuser.me/api/portraits/men/2.jpg',
      'message': 'Very cool Teachers',
      'date': '2021-01-01 12:00:00'
    },
    {
      'name': 'John Martins',
      'pic': 'https://randomuser.me/api/portraits/men/3.jpg',
      'message': 'Very cool',
      'date': '2021-01-01 12:00:00'
    },
    {
      'name': 'Kamal Perera',
      'pic': 'https://randomuser.me/api/portraits/men/4.jpg',
      'message': 'Very cool',
      'date': '2021-01-01 12:00:00'
    },
  ];

  Widget commentChild(data) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        return Dismissible(
          key: UniqueKey(),
          background: slideLeftBackground(), // Left swipe
          secondaryBackground: slideRightBackground(), // Right swipe
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              // Swipe Right to delete
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
                          setState(() {
                            filedata.removeAt(index);
                          });
                          Navigator.of(context).pop(true);
                        },
                        child: Text("Delete"),
                      ),
                    ],
                  );
                },
              );
            } else {
              // Swipe Left to edit
              commentController.text = data[index]['message'];
              await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Edit Comment"),
                    content: TextFormField(
                      controller: commentController,
                      decoration: InputDecoration(hintText: "Edit your comment"),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            filedata[index]['message'] = commentController.text;
                          });
                          commentController.clear();
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
                  // Display the image in large form.
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

  Widget slideLeftBackground() {
    return Container(
      color: Colors.red,
      child: Align(
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
        alignment: Alignment.centerLeft,
      ),
    );
  }

  Widget slideRightBackground() {
    return Container(
      color: Colors.blue,
      child: Align(
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
        alignment: Alignment.centerRight,
      ),
    );
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
          sendButtonMethod: () {
            if (formKey.currentState!.validate()) {
              print(commentController.text);
              setState(() {
                var now = DateTime.now();
                var formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now); // Format date
                var value = {
                  'name': 'Madhawa Awishka',
                  'pic': 'https://randomuser.me/api/portraits/men/${filedata.length % 100}.jpg',
                  'message': commentController.text,
                  'date': formattedDate, // Store the current date and time
                };
                filedata.insert(0, value);
              });
              commentController.clear();
              FocusScope.of(context).unfocus();
            } else {
              print("Not validated");
            }
          },
          formKey: formKey,
          commentController: commentController,
          backgroundColor: Colors.pink,
          textColor: Colors.white,
          sendWidget: Icon(Icons.send_sharp, size: 30, color: Colors.white),
        ),
      ),
    );
  }
}
