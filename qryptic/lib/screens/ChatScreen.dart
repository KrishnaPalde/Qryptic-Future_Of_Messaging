import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qryptic/helper/StaticData.dart';
import 'package:qryptic/model/Chat.dart';
import 'package:qryptic/model/Message.dart';
import 'package:qryptic/model/QrypticUser.dart';

class ChatScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chats',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Connected People Section
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 100,
              child: StreamBuilder(
                stream: _firestore.collection('users').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No users available.',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    );
                  }

                  final QrypticUser _cUser = QrypticUser.fromMap(snapshot
                      .data!.docs
                      .where((element) =>
                          element['userId'] == _auth.currentUser!.uid)
                      .first
                      .data() as Map<String, dynamic>);

                  final userDocs = snapshot.data!.docs.where(
                      // (doc) => doc['userId'] != _auth.currentUser?.uid,
                      (doc) => _cUser.contacts!.contains(doc['userId']));

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: userDocs.length,
                    itemBuilder: (context, index) {
                      final user = userDocs.elementAt(index).data()
                          as Map<String, dynamic>;
                      return GestureDetector(
                        onTap: () => _startChat(user, _cUser, context),
                        child: Container(
                          width: 80,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            children: [
                              CircleAvatar(
                                backgroundImage: user['profilePic'] != null
                                    ? NetworkImage(user['profilePic'])
                                    : null,
                                backgroundColor: Colors.grey.shade800,
                                child: user['profilePic'] == null
                                    ? const Icon(Icons.person,
                                        color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                user['displayName'] ?? 'Unknown',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          const Divider(color: Colors.grey, height: 1),
          // Chat List Section
          Expanded(
            child: FutureBuilder(
                future: _firestore.collection('users').get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  List<QrypticUser> users = [];

                  if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                    snapshot.data!.docs.forEach((element) {
                      users.add(QrypticUser.fromMap(element.data()));
                    });
                  }

                  return StreamBuilder(
                    stream: _firestore
                        .collection('chats')
                        .where('participants',
                            arrayContains: _auth.currentUser?.uid)
                        .orderBy('lastMessageTime', descending: true)
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text(
                            'No chats yet.',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        );
                      }

                      final chatDocs = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: chatDocs.length,
                        itemBuilder: (context, index) {
                          final chatDoc = chatDocs[index];
                          final Chat chatData = Chat.fromFirestore(
                              chatDoc.data() as Map<String, dynamic>);
                          final chatId = chatDoc.id;

                          // final participant =
                          //     (chatData['participants'] as List?)?.firstWhere(
                          //   (p) => p != _auth.currentUser?.uid,
                          //   orElse: () => {
                          //     'userId': _auth.currentUser?.uid ?? '',
                          //     'name': 'Unknown',
                          //     'qpc': '',
                          //     'profilePictureUrl': '',
                          //   },
                          // );
                          QrypticUser participant = QrypticUser();

                          chatData.participants.forEach((element) {
                            if (element != _auth.currentUser!.uid) {
                              participant =
                                  users.firstWhere((e) => e.userId == element);
                            }
                          });
                          print(chatData.lastSenderId != null &&
                              chatData.lastSenderId == _auth.currentUser!.uid);
                          return ListTile(
                            trailing: ((chatData.lastSenderId != null &&
                                        chatData.lastSenderId ==
                                            _auth.currentUser!.uid) ||
                                    chatData.unreadCount == 0)
                                ? Container(
                                    width: 0,
                                    height: 0,
                                  )
                                : Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.08,
                                    height: MediaQuery.of(context).size.height *
                                        0.03,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.red),
                                    child: Center(
                                      child: Text(
                                        chatData.unreadCount.toString(),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                            leading: CircleAvatar(
                              backgroundImage: participant.profilePictureUrl !=
                                      null
                                  ? NetworkImage(participant.profilePictureUrl!)
                                  : null,
                              backgroundColor: Colors.grey.shade800,
                              child: participant.profilePictureUrl == null
                                  ? const Icon(Icons.person,
                                      color: Colors.white)
                                  : null,
                            ),
                            title: Text(
                              participant.displayName ?? 'Unknown',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              chatData.lastMessage ?? '',
                              style: const TextStyle(color: Colors.white70),
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatDetailScreen(
                                      chatId: chatId,
                                      QrypticUser(),
                                      participant.userId!),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                }),
          ),
        ],
      ),
    );
  }

  void _startChat(Map<String, dynamic> user, QrypticUser cUser,
      BuildContext context) async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) return;
    print(user['userId']);
    final chatRef = _firestore.collection('chats');

    Chat chat = Chat(
        chatId: '',
        isGroupChat: false,
        participants: [],
        lastMessage: '',
        lastMessageTime: DateTime.now(),
        unreadCount: 0);

    // Check if chat already exists
    print([cUser.userId, user['userId']]);

    final chatSnapshot =
        await chatRef.where('participants', arrayContains: cUser.userId).get();

    bool b = false;
    if (chatSnapshot.docs.length == 1) {
      if (!(chatSnapshot.docs.first.data()['participants'] as List<dynamic>)
          .contains(user['userId'])) {
        b = true;
      } else {}
    } else {
      chatSnapshot.docs.removeWhere((element) {
        return !((element.data()['participants'] as List<dynamic>)
            .contains(user['userId']));
      });
    }
    // final existingChat = await chatRef
    //     .where('participants', arrayContains: cUser.userId)
    //     .get();

    // print(existingChat.data());
    if (chatSnapshot.docs.isNotEmpty && !b) {
      final Chat existing = Chat.fromFirestore(chatSnapshot.docs.first.data());
      final chatId = existing.chatId;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ChatDetailScreen(chatId: chatId, QrypticUser.fromMap(user), ""),
        ),
      );
    } else {
      // Create a new chat
      final newChatRef = chatRef.doc();

      // Participant p1 = Participant(
      //     userId: cUser.userId!,
      //     name: cUser.displayName ?? "",
      //     qpc: cUser.qrypticPhrase ?? "",
      //     profilePictureUrl: cUser.profilePictureUrl ?? "");

      // Participant p2 = Participant(
      //     userId: user["userId"]!,
      //     name: user["displayName"] ?? "",
      //     qpc: user["qrypticPhrase"] ?? "",
      //     profilePictureUrl: user["profilePictureUrl"] ?? "");

      chat = Chat(
        chatId: newChatRef.id,
        isGroupChat: false,
        // participants: [p1, p2],
        participants: [cUser.userId.toString(), user["userId"].toString()],
        lastMessage: 'Start a new Chat with ${user['displayName']}',
        lastMessageTime: null,
        unreadCount: 0,
      );

      await newChatRef.set(chat.toMap());

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatDetailScreen(
              chatId: newChatRef.id, QrypticUser.fromMap(user), ""),
        ),
      );
    }
  }
}

// ignore: must_be_immutable
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
              child: CircularProgressIndicator(),
            );
          }
          widget.user = snapshot.hasData
              ? QrypticUser.fromMap(
                  snapshot.data.data() as Map<String, dynamic>)
              : widget.user;
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.user.displayName ?? ""),
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
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text('No messages yet.',
                              style: TextStyle(color: Colors.white70)),
                        );
                      }

                      _firestore.collection('chats').doc(widget.chatId).update({
                        "unreadCount": 0,
                      });
                      final messages = snapshot.data!.docs;

                      return ListView.builder(
                        reverse: true,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final Message message = Message.fromFirestore(
                              messages[index].data() as Map<String, dynamic>);

                          final isMe =
                              message.senderId == _auth.currentUser?.uid;

                          return Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    isMe ? Colors.blue : Colors.grey.shade800,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                message.content,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.grey.shade900,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: const InputDecoration(
                            hintText: 'Type a message...',
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.white70),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.blue),
                        onPressed: _sendMessage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final messageRef = _firestore
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .doc();

    final Message _message = Message(
      messageId: messageRef.id,
      chatId: widget.chatId,
      senderId: _auth.currentUser!.uid,
      senderName: StaticData.user.displayName ?? '',
      content: _messageController.text.trim(),
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

    chatDoc.lastMessage = _messageController.text.trim();
    chatDoc.lastMessageTime = DateTime.now();
    chatDoc.unreadCount += 1;
    chatDoc.lastSenderId = _auth.currentUser!.uid;

    await _firestore
        .collection('chats')
        .doc(chatDoc.chatId)
        .update(chatDoc.toMap());

    _messageController.clear();
  }
}
