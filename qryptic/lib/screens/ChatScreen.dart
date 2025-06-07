import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qryptic/helper/encryptionServices.dart';
import 'package:qryptic/model/Chat.dart';
import 'package:qryptic/model/QrypticUser.dart';
import 'package:qryptic/screens/ChatDetailsScreen.dart';

class ChatHomeScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/animations/chatHomeBackground.jpg'),
                fit: BoxFit.cover),
          ),
        ),
        title: const Text(
          'Chats',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.blueAccent,
                blurRadius: 20,
              ),
            ],
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/animations/chatHomeBackground.jpg'),
              fit: BoxFit.cover),
        ),
        child: Column(
          children: [
            // Connected People Section
            SizedBox(
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
                        onTap: () async {
                          await _startChat(user, _cUser, context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            width: 80,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.blueAccent.withOpacity(0.5),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 25,
                                    backgroundImage: user['profilePic'] != null
                                        ? NetworkImage(user['profilePic'])
                                        : null,
                                    backgroundColor: Colors.grey.shade800,
                                    child: user['profilePic'] == null
                                        ? const Icon(Icons.person,
                                            color: Colors.white)
                                        : null,
                                  ),
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
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const Divider(color: Colors.grey, height: 1),
            SizedBox(
              height: 20,
            ),
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
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text(
                              'No chats yet.',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          );
                        }

                        final chatDocs = snapshot.data!.docs;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: ListView.builder(
                            itemCount: chatDocs.length,
                            itemBuilder: (context, index) {
                              final chatDoc = chatDocs[index];
                              final Chat chatData = Chat.fromFirestore(
                                  chatDoc.data() as Map<String, dynamic>);
                              final chatId = chatDoc.id;

                              QrypticUser participant = QrypticUser();

                              chatData.participants.forEach((element) {
                                if (element != _auth.currentUser!.uid) {
                                  participant = users
                                      .firstWhere((e) => e.userId == element);
                                }
                              });
                              print(chatData.lastSenderId != null &&
                                  chatData.lastSenderId ==
                                      _auth.currentUser!.uid);
                              String m = '';
                              String participantId = '';
                              bool isMe = false;
                              if (chatData.lastSenderId != null) {
                                isMe = chatData.lastSenderId! ==
                                        _auth.currentUser!.uid
                                    ? true
                                    : false;
                              }
                              if (chatData.lastSenderId == null) {
                                m = chatData.lastMessage;
                              } else {
                                if (isMe) {
                                  chatData.participants.forEach(
                                    (element) {
                                      if (element != _auth.currentUser!.uid) {
                                        participantId = element;
                                      }
                                    },
                                  );
                                }
                              }
                              print(m);
                              return FutureBuilder(
                                  future: chatData.lastSenderId != null
                                      ? EncryptionService.decryptMessage(
                                          isMe
                                              ? participantId
                                              : chatData.lastSenderId!,
                                          chatData.lastMessage)
                                      : Future.delayed(Duration.zero),
                                  builder: (context, snapshot) {
                                    if (chatData.lastSenderId != null) {
                                      m = snapshot.data.toString();
                                    }
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                            color:
                                                Colors.white.withOpacity(0.2)),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: ListTile(
                                        trailing: ((chatData.lastSenderId !=
                                                        null &&
                                                    chatData.lastSenderId ==
                                                        _auth.currentUser!
                                                            .uid) ||
                                                chatData.unreadCount == 0)
                                            ? Container(
                                                width: 0,
                                                height: 0,
                                              )
                                            : Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.08,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.03,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  color: Colors.red,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.redAccent
                                                          .withOpacity(0.8),
                                                      blurRadius: 10,
                                                      spreadRadius: 2,
                                                    ),
                                                  ],
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    chatData.unreadCount
                                                        .toString(),
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                        leading: CircleAvatar(
                                          backgroundImage:
                                              participant.profilePictureUrl !=
                                                      null
                                                  ? NetworkImage(participant
                                                      .profilePictureUrl!)
                                                  : null,
                                          backgroundColor: Colors.grey.shade800,
                                          child:
                                              participant.profilePictureUrl ==
                                                      null
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
                                          m,
                                          style: const TextStyle(
                                              color: Colors.white70),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ChatDetailScreen(
                                                      chatId: chatId,
                                                      QrypticUser(),
                                                      participant.userId!),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  });
                            },
                          ),
                        );
                      },
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startChat(Map<String, dynamic> user, QrypticUser cUser,
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
