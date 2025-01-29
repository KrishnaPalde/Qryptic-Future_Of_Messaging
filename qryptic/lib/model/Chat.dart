import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String chatId; // Unique ID for the chat
  final bool isGroupChat; // Flag to determine if the chat is a group chat
  final List<String> participants; // List of participants in the chat
  final String? groupName; // Name of the group (nullable for direct chats)
  final String? groupIcon; // Icon of the group (nullable for direct chats)
  String lastMessage; // Last message preview
  DateTime? lastMessageTime; // Timestamp of the last message
  String? lastSenderId;
  int unreadCount; // Count of unread messages

  Chat({
    required this.chatId,
    required this.isGroupChat,
    required this.participants,
    this.groupName,
    this.groupIcon,
    required this.lastMessage,
    this.lastMessageTime,
    this.lastSenderId,
    required this.unreadCount,
  });

  // Factory constructor to create a Chat instance from Firestore data
  factory Chat.fromFirestore(Map<String, dynamic> data) {
    return Chat(
      chatId: data['chatId'] as String,
      isGroupChat: data['isGroupChat'] as bool,
      participants:
          (data['participants'] as List).map((e) => e.toString()).toList(),
      groupName: data['groupName'] as String?,
      groupIcon: data['groupIcon'] as String?,
      lastMessage: data['lastMessage'] as String,
      lastMessageTime: data['lastMessageTime'] != null
          ? (data['lastMessageTime'] as Timestamp).toDate()
          : null,
      lastSenderId: data['lastSenderId'],
      unreadCount: data['unreadCount'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'isGroupChat': isGroupChat,
      'participants': participants,
      'groupName': groupName,
      'groupIcon': groupIcon,
      'lastMessage': lastMessage,
      'lastMessageTime':
          lastMessageTime != null ? Timestamp.fromDate(lastMessageTime!) : null,
      'lastSenderId': lastSenderId,
      'unreadCount': unreadCount,
    };
  }
}

// class Participant {
//   final String userId; // User ID of the participant
//   final String name; // Name of the participant
//   final String qpc; // QPC (profile picture or avatar)
//   final String profilePictureUrl;

//   Participant({
//     required this.userId,
//     required this.name,
//     required this.qpc,
//     required this.profilePictureUrl,
//   });

//   // Factory constructor to create a Participant instance from Map data
//   factory Participant.fromMap(Map<String, dynamic> data) {
//     return Participant(
//       userId: data['userId'] as String,
//       name: data['name'] as String,
//       qpc: data['qpc'] as String,
//       profilePictureUrl: data['profilePictureUrl'] as String,
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'userId': userId,
//       'name': name,
//       'qpc': qpc,
//       'profilePictureUrl': profilePictureUrl,
//     };
//   }
// }
