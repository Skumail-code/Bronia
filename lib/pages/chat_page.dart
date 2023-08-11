import 'package:chatapp/pages/group_info.dart';
import 'package:chatapp/services/database_service.dart';
import 'package:chatapp/widgets/messagetile.dart';
import 'package:chatapp/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userName;
  ChatPage(
      {super.key,
      required this.groupId,
      required this.groupName,
      required this.userName});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  ScrollController _scrollController = ScrollController();
  Stream<QuerySnapshot>? chats;
  TextEditingController messageController = TextEditingController();
  String admin = "";

  @override
  void initState() {
    getChatandAdmin();
    super.initState();
  }

  getChatandAdmin() {
    DatabaseService().getChats(widget.groupId).then((val) {
      setState(() {
        chats = val;
      });
    });
    DatabaseService().getGroupAdmin(widget.groupId).then((val) {
      setState(() {
        admin = val;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        title:
            Text(widget.groupName, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
              onPressed: () {
                nextScreen(
                    context,
                    GroupInfo(
                      groupId: widget.groupId,
                      groupName: widget.groupName,
                      adminName: admin,
                    ));
              },
              icon: const Icon(
                Icons.info,
                color: Colors.black,
              ))
        ],
      ),
      //old code
      // body: Stack(
      //   children: [
      //     // chat messages here
      //     chatMessages(),
      //     Container(
      //       alignment: Alignment.bottomCenter,
      //       width: MediaQuery.of(context).size.width,
      //       child: Container(
      //         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      //         width: MediaQuery.of(context).size.width,
      //         color: Colors.grey[300]?.withOpacity(0.7),
      //         height: 70,
      //         child: Row(
      //           children: [
      //             Expanded(
      //                 child: TextFormField(
      //               controller: messageController,
      //               style: TextStyle(color: Theme.of(context).primaryColor),
      //               decoration: InputDecoration(
      //                   hintText: "Send a message...",
      //                   hintStyle: TextStyle(
      //                       color: Theme.of(context).primaryColor,
      //                       fontSize: 16),
      //                   border: InputBorder.none),
      //             )),
      //             const SizedBox(
      //               width: 12,
      //             ),
      //             GestureDetector(
      //               onTap: () {
      //                 sendMessage();
      //               },
      //               child: Container(
      //                 height: 50,
      //                 width: 50,
      //                 decoration: BoxDecoration(
      //                   color: Theme.of(context).primaryColor,
      //                   borderRadius: BorderRadius.circular(30),
      //                 ),
      //                 child: const Center(
      //                     child: Icon(
      //                   Icons.send,
      //                   color: Colors.white,
      //                 )),
      //               ),
      //             )
      //           ],
      //         ),
      //       ),
      //     )
      //   ],
      // ),
      body: Stack(
        children: [
          // chat messages here
          Positioned(
            top: 0,
            bottom: 70, // Adjust this value based on your needs
            left: 0,
            right: 0,
            child: chatMessages(),
          ),
          Positioned(
            bottom: 0,
            width: MediaQuery.of(context).size.width,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              width: MediaQuery.of(context).size.width,
              color: Colors.grey[300],
              height: 70,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: messageController,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                      decoration: InputDecoration(
                        hintText: "Send a message...",
                        hintStyle: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  GestureDetector(
                    onTap: () {
                      sendMessage();
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // chatMessages() {
  //   return StreamBuilder(
  //     stream: chats,
  //     builder: (context, AsyncSnapshot snapshot) {
  //       return snapshot.hasData
  //           ? ListView.builder(
  //               controller: _scrollController,
  //               reverse: true,
  //               itemCount: snapshot.data.docs.length,
  //               itemBuilder: (context, index) {
  //                 return MessageTile(
  //                     message: snapshot.data.docs[index]['message'],
  //                     sender: snapshot.data.docs[index]['sender'],
  //                     sentByMe: widget.userName ==
  //                         snapshot.data.docs[index]['sender']);
  //               },
  //             )
  //           : Container();
  //     },
  //   );
  // }

  chatMessages() {
    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      itemCount: 1, // Using a single item here
      itemBuilder: (context, index) {
        return StreamBuilder(
          stream: chats,
          builder: (context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                return MessageTile(
                  message: snapshot.data.docs[index]['message'],
                  sender: snapshot.data.docs[index]['sender'],
                  sentByMe:
                      widget.userName == snapshot.data.docs[index]['sender'],
                );
              },
            );
          },
        );
      },
    );
  }

  sendMessage() {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": messageController.text,
        "sender": widget.userName,
        "time": DateTime.now().millisecondsSinceEpoch,
      };

      DatabaseService().sendMessage(widget.groupId, chatMessageMap);
      setState(() {
        messageController.clear();
      });
    }
  }
}
