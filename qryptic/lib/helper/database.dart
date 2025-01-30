import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qryptic/helper/StaticData.dart';
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

Future<Map<String, String>> connectUserViaQR(String qpr) async {
  try {
    final response = await FirebaseFirestore.instance
        .collection('users')
        .where(
          "qrypticPhrase",
          isEqualTo: qpr,
        )
        .get();
    if (response.docs.isNotEmpty) {
      if (response.docs.length == 1) {
        QrypticUser _tempUser = QrypticUser.fromMap(response.docs.first.data());
        if (_tempUser.contacts!
            .contains(FirebaseAuth.instance.currentUser!.uid)) {
          return {"message": "Already Connected."};
        }
        var tokenUrl = Uri.http('3.110.196.16', '/token');
        var startQKDUrl = Uri.http('3.110.196.16', '/start_qkd');
        Map<String, String> tokenBody = {
          'username': FirebaseAuth.instance.currentUser!.uid.toString(),
          'password': '',
        };
        var tokenResponse =
            await http.post(tokenUrl, body: tokenBody, headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        });

        if (tokenResponse.statusCode == 200) {
          var token;
          token = jsonDecode(tokenResponse.body)['access_token'];
          Fluttertoast.showToast(msg: token);
          var startQKDResponse = await http.post(startQKDUrl, headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          });

          if (startQKDResponse.statusCode == 200) {
            bool isSessionFinished = false;
            print(startQKDResponse.body);
            var qkdSessionId = jsonDecode(startQKDResponse.body)['session_id'];

            if (qkdSessionId != null) {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(_tempUser.userId)
                  .update({
                "qkdSessionId": qkdSessionId.toString(),
              });
              print("code here 1");
              await for (var event in FirebaseFirestore.instance
                  .collection('users')
                  .doc(_tempUser.userId)
                  .snapshots()) {
                if (event.exists) {
                  isSessionFinished =
                      event.data()!['isSessionFinished'] ?? false;
                  print('Session finished: $isSessionFinished');
                  if (isSessionFinished) {
                    break; // Exit once the session is finished
                  }
                }
              }
              print("code here 2");
              if (isSessionFinished) {
                var getKeyURL = Uri.http('3.110.196.16',
                    '/get_shared_key/${qkdSessionId.toString()}');
                var getKeyResponse = await http.get(getKeyURL, headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                  'Authorization': 'Bearer $token',
                });

                if (getKeyResponse.statusCode == 200) {
                  Fluttertoast.showToast(
                      msg:
                          "Key: ${jsonDecode(getKeyResponse.body)['shared_key']}");
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(_tempUser.userId)
                      .update({
                    "qkdSessionId": "",
                    "isSessionFinished": false,
                  });
                }
              }
            }
          }
        }
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({
          "contacts": FieldValue.arrayUnion([_tempUser.userId]),
        });
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_tempUser.userId)
            .update({
          "contacts":
              FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid]),
        });
        return {
          "name": _tempUser.displayName.toString(),
          "QPC": _tempUser.qrypticPhrase.toString(),
        };
      } else {
        return {"error": "Invalid QPC QR Code"};
      }
    } else {
      return {"error": "Invalid QPC QR Code"};
    }
  } catch (e) {
    return {"error": e.toString()};
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
  if (StaticData.hasJoinedSession) {
    return;
  } else {
    StaticData.hasJoinedSession = true;
    print("code here 1");
    var tokenUrl = Uri.http('3.110.196.16', '/token');
    var tokenResponse = await http.post(tokenUrl, body: {
      'username': FirebaseAuth.instance.currentUser!.uid.toString(),
      'password': ''
    });

    if (tokenResponse.statusCode == 200) {
      print("code here 2");
      var token;
      token = jsonDecode(tokenResponse.body)['access_token'];

      var joinSessionResponse = await http
          .post(Uri.http('3.110.196.16', '/join_qkd/$sessionId'), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });
      print(joinSessionResponse.statusCode);
      if (joinSessionResponse.statusCode == 200) {
        print("code here 3");
        Fluttertoast.showToast(
            msg: "Key: ${jsonDecode(joinSessionResponse.body)['shared_key']}",
            toastLength: Toast.LENGTH_LONG);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({
          "isSessionFinished": true,
        });
      }
    }
  }
}
