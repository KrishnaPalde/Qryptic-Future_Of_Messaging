import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String messageId; // Unique ID for the message
  String chatId; // ID of the associated chat
  String senderId; // ID of the sender
  String senderName; // Name of the sender
  String content; // Message content
  String messageType; // 'text', 'image', 'file', 'video', etc.
  DateTime timestamp; // Timestamp of when the message was sent
  String encryptionKeyId; // ID of the encryption key for this message
  String encryptionAlgorithm; // Algorithm used for encryption (e.g., AES-256)
  bool isEncrypted; // Whether the message is encrypted
  Map<String, dynamic>? qkdMetadata; // QKD-related metadata
  bool isDelivered; // Delivery status
  bool isRead; // Read status
  DateTime? deliveredAt; // Timestamp of delivery
  DateTime? readAt; // Timestamp of being read
  String? attachmentUrl; // URL for any attached file or media
  Map<String, String>? metadata; // Additional metadata for future extensibility
  List<ReadReceipt> readBy; // List of users who have read the message
  String?
      receiverId; // Receiver ID for direct messages (nullable for group chats)

  Message({
    required this.messageId,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.messageType,
    required this.encryptionKeyId,
    required this.encryptionAlgorithm,
    required this.isEncrypted,
    this.qkdMetadata,
    this.isDelivered = false,
    this.isRead = false,
    required this.timestamp,
    this.deliveredAt,
    this.readAt,
    this.attachmentUrl,
    this.metadata,
    required this.readBy,
    this.receiverId,
  });

  factory Message.fromFirestore(Map<String, dynamic> data) {
    return Message(
      messageId: data['messageId'] as String,
      chatId: data['chatId'] as String,
      senderId: data['senderId'] as String,
      senderName: data['senderName'] as String,
      content: data['content'] as String,
      messageType: data['messageType'] as String,
      encryptionKeyId: data['encryptionKeyId'] as String,
      encryptionAlgorithm: data['encryptionAlgorithm'] as String,
      isEncrypted: data['isEncrypted'] as bool,
      qkdMetadata: data['qkdMetadata'] as Map<String, dynamic>?,
      isDelivered: data['isDelivered'] as bool,
      isRead: data['isRead'] as bool,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      deliveredAt: data['deliveredAt'] != null
          ? (data['deliveredAt'] as Timestamp).toDate()
          : null,
      readAt: data['readAt'] != null
          ? (data['readAt'] as Timestamp).toDate()
          : null,
      attachmentUrl: data['attachmentUrl'] as String?,
      metadata: data['metadata'] as Map<String, String>?,
      readBy:
          (data['readBy'] as List).map((e) => ReadReceipt.fromMap(e)).toList(),
      receiverId: data['receiverId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'messageType': messageType,
      'encryptionKeyId': encryptionKeyId,
      'encryptionAlgorithm': encryptionAlgorithm,
      'isEncrypted': isEncrypted,
      'qkdMetadata': qkdMetadata,
      'isDelivered': isDelivered,
      'isRead': isRead,
      'timestamp': Timestamp.fromDate(timestamp),
      'deliveredAt':
          deliveredAt != null ? Timestamp.fromDate(deliveredAt!) : null,
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
      'attachmentUrl': attachmentUrl,
      'metadata': metadata,
      'readBy': readBy.map((e) => e.toMap()).toList(),
      'receiverId': receiverId,
    };
  }
}

class ReadReceipt {
  final String userId;
  final DateTime timestamp;

  ReadReceipt({
    required this.userId,
    required this.timestamp,
  });

  factory ReadReceipt.fromMap(Map<String, dynamic> data) {
    return ReadReceipt(
      userId: data['userId'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
