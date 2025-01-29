import 'package:cloud_firestore/cloud_firestore.dart';

class QrypticUser {
  String? userId; // Unique user identifier (Firebase UID)
  String? phoneNumber; // QrypticUser's phone number
  String? displayName; // Optional user nickname
  String? email; // Optional email address
  String? profilePictureUrl; // URL to the user's profile picture
  String? qrypticPhrase; // Unique Qryptic Phrase Code
  DateTime? createdAt; // Account creation timestamp
  DateTime? lastActive; // Last activity timestamp
  bool? isVerified; // Indicates if the user is verified
  bool? isOnline; // Online status
  List<String>? contacts; // List of userIds of contacts
  List<String>? blockedUsers; // List of userIds the user has blocked
  String qkdSessionId;
  bool isSessionFinished;
  String? bio; // QrypticUser's optional bio or status message
  bool? enableNotifications; // Push notification preference
  bool? enableQuantumEncryption; // Preference for quantum encryption
  String? language; // Preferred language for the app

  QrypticUser({
    this.userId,
    this.phoneNumber,
    this.displayName,
    this.email,
    this.profilePictureUrl,
    this.qrypticPhrase,
    this.createdAt,
    this.lastActive,
    this.isVerified,
    this.isOnline,
    this.contacts,
    this.blockedUsers,
    this.qkdSessionId = "",
    this.isSessionFinished = false,
    this.bio,
    this.enableNotifications,
    this.enableQuantumEncryption,
    this.language,
  });

  // Factory method to create a QrypticUser instance from Firestore document
  factory QrypticUser.fromMap(Map<String, dynamic> map) {
    return QrypticUser(
      userId: map['userId'],
      phoneNumber: map['phoneNumber'],
      displayName: map['displayName'],
      email: map['email'],
      profilePictureUrl: map['profilePictureUrl'],
      qrypticPhrase: map['qrypticPhrase'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      lastActive: (map['lastActive'] as Timestamp?)?.toDate(),
      isVerified: map['isVerified'],
      isOnline: map['isOnline'],
      contacts: List<String>.from(map['contacts'] ?? []),
      blockedUsers: List<String>.from(map['blockedUsers'] ?? []),
      qkdSessionId: map['qkdSessionId'] ?? "",
      isSessionFinished: map['isSessionFinished'],
      bio: map['bio'],
      enableNotifications: map['enableNotifications'],
      enableQuantumEncryption: map['enableQuantumEncryption'],
      language: map['language'],
    );
  }

  // Method to convert a QrypticUser instance to a Firestore-compatible map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'email': email,
      'profilePictureUrl': profilePictureUrl,
      'qrypticPhrase': qrypticPhrase,
      'createdAt': createdAt,
      'lastActive': lastActive,
      'isVerified': isVerified,
      'isOnline': isOnline,
      'contacts': contacts,
      'blockedUsers': blockedUsers,
      'qkdSessionId': qkdSessionId,
      'isSessionFinished': isSessionFinished,
      'bio': bio,
      'enableNotifications': enableNotifications,
      'enableQuantumEncryption': enableQuantumEncryption,
      'language': language,
    };
  }
}
