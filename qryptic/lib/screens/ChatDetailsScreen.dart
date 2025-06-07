// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:qryptic/helper/StaticData.dart';
// import 'package:qryptic/helper/encryptionServices.dart';
// import 'package:qryptic/model/Chat.dart';
// import 'package:qryptic/model/Message.dart';
// import 'package:qryptic/model/QrypticUser.dart';

// class ChatDetailScreen extends StatefulWidget {
//   final String chatId;
//   QrypticUser user = QrypticUser();
//   String userId = '';

//   ChatDetailScreen(this.user, this.userId, {super.key, required this.chatId});

//   @override
//   _ChatDetailScreenState createState() => _ChatDetailScreenState();
// }

// class _ChatDetailScreenState extends State<ChatDetailScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//         future: widget.user.userId == null
//             ? FirebaseFirestore.instance
//                 .collection('users')
//                 .doc(widget.userId)
//                 .get()
//             : Future.delayed(Duration.zero),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState != ConnectionState.done) {
//             return const Center(
//               child: SpinKitWave(color: Colors.black, size: 24),
//             );
//           }
//           widget.user = snapshot.hasData
//               ? QrypticUser.fromMap(
//                   snapshot.data.data() as Map<String, dynamic>)
//               : widget.user;
//           return Scaffold(
//             appBar: AppBar(
//               title: Text(widget.user.displayName ?? ""),
//             ),
//             body: Column(
//               children: [
//                 Expanded(
//                   child: StreamBuilder(
//                     stream: _firestore
//                         .collection('chats')
//                         .doc(widget.chatId)
//                         .collection('messages')
//                         .orderBy('timestamp', descending: true)
//                         .snapshots(),
//                     builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return const Center(
//                             child: SpinKitWave(color: Colors.black, size: 24));
//                       }

//                       if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                         return const Center(
//                           child: Text('No messages yet.',
//                               style: TextStyle(color: Colors.white70)),
//                         );
//                       }

//                       _firestore
//                           .collection('chats')
//                           .doc(widget.chatId)
//                           .get()
//                           .then(
//                         (value) {
//                           if (value.data()!['lastSenderId'] !=
//                               _auth.currentUser!.uid) {
//                             _firestore
//                                 .collection('chats')
//                                 .doc(widget.chatId)
//                                 .update({
//                               "unreadCount": 0,
//                             });
//                           }
//                         },
//                       );

//                       final messages = snapshot.data!.docs;

//                       return ListView.builder(
//                         reverse: true,
//                         itemCount: messages.length,
//                         itemBuilder: (context, index) {
//                           Message message = Message.fromFirestore(
//                               messages[index].data() as Map<String, dynamic>);
//                           final isMe =
//                               message.senderId == _auth.currentUser?.uid;

//                           return FutureBuilder(
//                               future: EncryptionService.decryptMessage(
//                                   isMe ? message.receiverId! : message.senderId,
//                                   message.content),
//                               builder: (context, snapshot) {
//                                 if (snapshot.connectionState ==
//                                     ConnectionState.done) {
//                                   return Align(
//                                     alignment: isMe
//                                         ? Alignment.centerRight
//                                         : Alignment.centerLeft,
//                                     child: Container(
//                                       margin: const EdgeInsets.symmetric(
//                                           vertical: 4, horizontal: 8),
//                                       padding: const EdgeInsets.all(12),
//                                       decoration: BoxDecoration(
//                                         color: isMe
//                                             ? Colors.blue
//                                             : Colors.grey.shade800,
//                                         borderRadius: BorderRadius.circular(8),
//                                       ),
//                                       child: Text(
//                                         snapshot.data!,
//                                         style: const TextStyle(
//                                             color: Colors.white),
//                                       ),
//                                     ),
//                                   );
//                                 } else {
//                                   return Center(
//                                     child: SpinKitWave(
//                                         color: Colors.black, size: 24),
//                                   );
//                                 }
//                               });
//                         },
//                       );
//                     },
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   color: Colors.grey.shade900,
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           controller: _messageController,
//                           decoration: const InputDecoration(
//                             hintText: 'Type a message...',
//                             border: InputBorder.none,
//                             hintStyle: TextStyle(color: Colors.white70),
//                           ),
//                           style: const TextStyle(color: Colors.white),
//                         ),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.send, color: Colors.blue),
//                         onPressed: () async {
//                           await _sendMessage();
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           );
//         });
//   }

// Future<void> _sendMessage() async {
//   if (_messageController.text.trim().isEmpty) return;

//   final messageRef = _firestore
//       .collection('chats')
//       .doc(widget.chatId)
//       .collection('messages')
//       .doc();

//   final m = await EncryptionService.encryptMessage(
//       widget.user.userId ?? widget.userId, _messageController.text.trim());
//   if (m == null) {
//     Fluttertoast.showToast(msg: "Error");
//     return;
//   }
//   final Message _message = Message(
//     messageId: messageRef.id,
//     chatId: widget.chatId,
//     senderId: _auth.currentUser!.uid,
//     senderName: StaticData.user.displayName ?? '',
//     content: m,
//     messageType: "text",
//     encryptionKeyId: "",
//     encryptionAlgorithm: "",
//     isEncrypted: false,
//     timestamp: DateTime.now(),
//     readBy: [],
//     deliveredAt: DateTime.now(),
//     isDelivered: true,
//     isRead: false,
//     receiverId: widget.user.userId,
//   );

//   await messageRef.set(_message.toMap());

//   Chat chatDoc = Chat.fromFirestore(
//       (await _firestore.collection('chats').doc(widget.chatId).get()).data()
//           as Map<String, dynamic>);

//   await _firestore.collection('chats').doc(chatDoc.chatId).update({
//     "lastMessage": m,
//     "lastMessageTime": DateTime.now(),
//     "unreadCount": FieldValue.increment(1),
//     "lastSenderId": _auth.currentUser!.uid,
//   });

//   _messageController.clear();
// }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qryptic/helper/StaticData.dart';
import 'package:qryptic/helper/encryptionServices.dart';
import 'package:qryptic/model/Chat.dart';
import 'package:qryptic/model/Message.dart';
import 'package:qryptic/model/QrypticUser.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  QrypticUser user = QrypticUser();
  String userId = '';

  ChatDetailScreen(this.user, this.userId, {super.key, required this.chatId});

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: widget.user.userId == null
            ? FirebaseFirestore.instance
                .collection('users')
                .doc(widget.userId)
                .get()
            : Future.delayed(Duration.zero),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: SpinKitWave(color: Colors.blueAccent, size: 24),
            );
          }
          widget.user = snapshot.hasData
              ? QrypticUser.fromMap(
                  snapshot.data.data() as Map<String, dynamic>)
              : widget.user;
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              title: Text(widget.user.displayName ?? "",
                  style: TextStyle(color: Colors.cyanAccent, fontSize: 18)),
              backgroundColor: Colors.black,
              elevation: 2,
            ),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: _firestore
                        .collection('chats')
                        .doc(widget.chatId)
                        .collection('messages')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: SpinKitWave(
                                color: Colors.cyanAccent, size: 24));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text('No messages yet.',
                              style: TextStyle(color: Colors.white70)),
                        );
                      }

                      _firestore
                          .collection('chats')
                          .doc(widget.chatId)
                          .get()
                          .then(
                        (value) {
                          if (value.data()!['lastSenderId'] !=
                              _auth.currentUser!.uid) {
                            _firestore
                                .collection('chats')
                                .doc(widget.chatId)
                                .update({"unreadCount": 0});
                          }
                        },
                      );

                      final messages = snapshot.data!.docs;

                      return ListView.builder(
                        reverse: true,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          Message message = Message.fromFirestore(
                              messages[index].data() as Map<String, dynamic>);
                          final isMe =
                              message.senderId == _auth.currentUser?.uid;

                          return FutureBuilder(
                              future: EncryptionService.decryptMessage(
                                  isMe ? message.receiverId! : message.senderId,
                                  message.content),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  return Align(
                                    alignment: isMe
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 4, horizontal: 8),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isMe
                                            ? Colors.cyanAccent
                                            : Colors.grey.shade900,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.cyanAccent
                                                  .withOpacity(0.5),
                                              blurRadius: 5,
                                              spreadRadius: 1)
                                        ],
                                      ),
                                      child: Text(
                                        snapshot.data!,
                                        style: TextStyle(
                                          color: isMe
                                              ? Colors.black87
                                              : Colors
                                                  .white, // Darker text for cyan background
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  );
                                } else {
                                  return Center(
                                    child: SpinKitWave(
                                        color: Colors.cyanAccent, size: 24),
                                  );
                                }
                              });
                        },
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: TextStyle(color: Colors.white70),
                            border: InputBorder.none,
                          ),
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.cyanAccent),
                        onPressed: () async {
                          await _sendMessage();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final messageRef = _firestore
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .doc();

    final m = await EncryptionService.encryptMessage(
        widget.user.userId ?? widget.userId, _messageController.text.trim());
    if (m == null) {
      Fluttertoast.showToast(msg: "Error");
      return;
    }
    final Message _message = Message(
      messageId: messageRef.id,
      chatId: widget.chatId,
      senderId: _auth.currentUser!.uid,
      senderName: StaticData.user.displayName ?? '',
      content: m,
      messageType: "text",
      encryptionKeyId: "",
      encryptionAlgorithm: "",
      isEncrypted: false,
      timestamp: DateTime.now(),
      readBy: [],
      deliveredAt: DateTime.now(),
      isDelivered: true,
      isRead: false,
      receiverId: widget.user.userId,
    );

    await messageRef.set(_message.toMap());

    Chat chatDoc = Chat.fromFirestore(
        (await _firestore.collection('chats').doc(widget.chatId).get()).data()
            as Map<String, dynamic>);

    await _firestore.collection('chats').doc(chatDoc.chatId).update({
      "lastMessage": m,
      "lastMessageTime": DateTime.now(),
      "unreadCount": FieldValue.increment(1),
      "lastSenderId": _auth.currentUser!.uid,
    });

    _messageController.clear();
  }
}
