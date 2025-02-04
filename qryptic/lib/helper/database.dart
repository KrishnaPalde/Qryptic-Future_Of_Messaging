import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qryptic/helper/StaticData.dart';
import 'package:qryptic/helper/encryptionServices.dart';
import 'package:qryptic/model/QrypticUser.dart';
import 'package:http/http.dart' as http;

Future<int> createUser(String email, String uid) async {
  try {
    QrypticUser _user = QrypticUser(
        email: email,
        userId: uid,
        createdAt: DateTime.now(),
        enableQuantumEncryption: true);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set(_user.toMap());
    return 1;
  } catch (e) {
    print(e);
    return -1;
  }
}

Future<int> onboardUserData(
    String name, String mobile, String qpc, String bio, String uid) async {
  try {
    final response =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    QrypticUser _user = QrypticUser.fromMap(response.data()!);
    _user.displayName = name;
    _user.phoneNumber = mobile;
    _user.qrypticPhrase = qpc;
    _user.bio = bio;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update(_user.toMap());

    return 1;
  } catch (e) {
    return -1;
  }
}

Future<int> isUserExist(String email) async {
  try {
    final result = await FirebaseFirestore.instance
        .collection('users')
        .where("email", isEqualTo: email)
        .get();

    if (result.docs.isEmpty) {
      return 0;
    } else {
      final data = result.docs.first.data();
      if (data['displayName'] == null || data['phoneNumber'] == null) {
        return 2;
      }
      return 1;
    }
  } catch (e) {
    print(e);
    return -1;
  }
}

Future<QrypticUser> getUserData(String uid) async {
  try {
    final response =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return QrypticUser.fromMap(response.data()!);
  } catch (e) {
    return QrypticUser();
  }
}

Future<Map<String, String>> connectUserViaQR(String qpc) async {
  try {
    if (qpc.isEmpty) {
      return {"error": "Invalid QPC input."};
    }
    print("Scanning QPC: $qpc");

    // Fetch user from Firestore using the QPC value
    final response = await FirebaseFirestore.instance
        .collection('users')
        .where("qrypticPhrase", isEqualTo: qpc)
        .get();

    if (response.docs.isEmpty) {
      return {"error": "Invalid QPC QR Code"};
    }

    if (response.docs.length > 1) {
      return {"error": "Duplicate QPC detected. Please contact support."};
    }

    QrypticUser targetUser = QrypticUser.fromMap(response.docs.first.data());
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return {"error": "User not authenticated."};
    }

    if (targetUser.contacts?.contains(currentUser.uid) ?? false) {
      return {"message": "Already Connected."};
    }

    print("Initiating Quantum Key Distribution...");

    // Obtain authentication token
    var tokenUrl = Uri.http('13.233.31.125', '/token');
    var tokenResponse = await http.post(tokenUrl, body: {
      'username': currentUser.uid,
      'password': '',
    }, headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Accept': 'application/json',
    });

    if (tokenResponse.statusCode != 200) {
      return {"error": "Failed to authenticate with QKD server."};
    }

    String token = jsonDecode(tokenResponse.body)['access_token'];
    if (token.isEmpty) {
      return {"error": "Invalid authentication token."};
    }

    Fluttertoast.showToast(msg: "Token received.");

    // Start QKD session
    var startQKDUrl = Uri.http('13.233.31.125',
        '/start_qkd/${FirebaseAuth.instance.currentUser!.uid}');
    var startQKDResponse = await http.post(startQKDUrl, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (startQKDResponse.statusCode != 200) {
      return {"error": "Failed to initiate QKD session."};
    }

    String? qkdSessionId = jsonDecode(startQKDResponse.body)['session_id'];
    if (qkdSessionId == null) {
      return {"error": "Invalid QKD session ID."};
    }

    // Update Firestore with session ID
    await FirebaseFirestore.instance
        .collection('users')
        .doc(targetUser.userId)
        .update({
      "qkdSessionId": qkdSessionId,
    });

    // Monitor session completion
    bool isSessionFinished = false;
    await for (var event in FirebaseFirestore.instance
        .collection('users')
        .doc(targetUser.userId)
        .snapshots()) {
      if (event.exists) {
        isSessionFinished = event.data()?['isSessionFinished'] ?? false;
        if (isSessionFinished) {
          break;
        }
      }
    }

    if (!isSessionFinished) {
      return {"error": "QKD session did not complete successfully."};
    }

    // Retrieve shared key
    var getKeyURL = Uri.http('13.233.31.125', '/get_shared_key/$qkdSessionId');
    var getKeyResponse = await http.get(getKeyURL, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (getKeyResponse.statusCode != 200) {
      return {"error": "Failed to retrieve shared key."};
    }

    String? sharedKey = jsonDecode(getKeyResponse.body)['shared_key'];
    if (sharedKey == null || sharedKey.isEmpty) {
      return {"error": "Invalid shared key received."};
    }

    // Store shared key securely
    await EncryptionService.storeQuantumKey(targetUser.userId!, sharedKey);
    Fluttertoast.showToast(msg: "Key stored successfully.");

    // Reset session fields in Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(targetUser.userId)
        .update({
      "qkdSessionId": "",
      "isSessionFinished": false,
    });

    // Update user contacts
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .update({
      "contacts": FieldValue.arrayUnion([targetUser.userId]),
    });
    await FirebaseFirestore.instance
        .collection('users')
        .doc(targetUser.userId)
        .update({
      "contacts": FieldValue.arrayUnion([currentUser.uid]),
    });

    return {
      "name": targetUser.displayName ?? "Unknown",
      "QPC": targetUser.qrypticPhrase ?? "N/A",
    };
  } catch (e) {
    print("Error: $e");
    return {"error": "An unexpected error occurred: ${e.toString()}"};
  }
}

Future<bool> checkQPCAvailability(String qpc) async {
  final usersRef = FirebaseFirestore.instance.collection('users');

  try {
    final querySnapshot =
        await usersRef.where('qrypticPhrase', isEqualTo: qpc).get();
    return querySnapshot
        .docs.isEmpty; // If no document is found, the QPC is available
  } catch (e) {
    print("Error checking QPC availability: $e");
    return false; // In case of an error, return false (unavailable)
  }
}

Future<bool> isUserOnboarded(String uid) async {
  final response =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();
  if (response.data() != null) {
    return response.data()!['displayName'].toString().isNotEmpty;
  } else {
    return false;
  }
}

Future<void> joinQKDSession(String sessionId) async {
  try {
    var tokenUrl = Uri.http('13.233.31.125', '/token');
    var tokenResponse = await http.post(tokenUrl, body: {
      'username': FirebaseAuth.instance.currentUser!.uid.toString(),
      'password': ''
    });

    if (tokenResponse.statusCode == 200) {
      var token;
      token = jsonDecode(tokenResponse.body)['access_token'];

      var joinSessionResponse = await http
          .post(Uri.http('13.233.31.125', '/join_qkd/$sessionId'), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (joinSessionResponse.statusCode == 200) {
        try {
          await EncryptionService.storeQuantumKey(
              jsonDecode(joinSessionResponse.body)['userId'],
              jsonDecode(joinSessionResponse.body)['shared_key']);
          await FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .update({
            "isSessionFinished": true,
          });
        } catch (e) {
          print(e);
        }
      }
    }
  } catch (e) {
    print("ERROR $e");
  }
}
