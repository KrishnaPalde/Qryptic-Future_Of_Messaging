import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qryptic/model/QrypticUser.dart';

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
