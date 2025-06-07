import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lottie/lottie.dart';
import 'package:qryptic/helper/database.dart';
import 'package:qryptic/model/QrypticUser.dart';
import 'package:qryptic/widget/CustomProgressIndicator.dart';
import 'package:qryptic/widget/FuturisticTextField.dart';
import 'package:qryptic/widget/FuturisticToast.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController qpcController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Edit Profile',
          style: GoogleFonts.nunito(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.cyanAccent),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.cyanAccent),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: StreamBuilder(
            stream: userDataStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                QrypticUser _user = QrypticUser.fromMap(snapshot.data!.data()!);

                nameController.text = _user.displayName ?? "";
                mobileController.text = "+91 ${_user.phoneNumber ?? ""}";
                qpcController.text = _user.qrypticPhrase ?? "";
                emailController.text = _user.email ?? "";
                bioController.text = _user.bio ?? "";
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Glowing Profile Picture
                      BounceInDown(
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.cyanAccent.withOpacity(0.7),
                                    blurRadius: 15,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 60,
                                child: LottieBuilder.asset(
                                    'assets/animations/profile.json'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: FuturisticTextField(
                          controller: nameController,
                          label: "Full Name",
                          isObscure: false,
                          onChange: (p0) {},
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: FuturisticTextField(
                          controller: emailController,
                          label: "Email",
                          isObscure: false,
                          onChange: (p0) {},
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: FuturisticTextField(
                          controller: mobileController,
                          label: "Mobile Number",
                          isObscure: false,
                          onChange: (p0) {},
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: FuturisticTextField(
                          controller: qpcController,
                          label: "Qryptic Phrase Code (QPC)",
                          isObscure: false,
                          onChange: (p0) {},
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: FuturisticTextField(
                          controller: bioController,
                          label: "Bio",
                          isObscure: false,
                          onChange: (p0) {},
                        ),
                      ),
                      SizedBox(height: 40),
                      // Save Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 12),
                          backgroundColor: Colors.cyanAccent.withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: BorderSide(color: Colors.cyanAccent),
                          ),
                        ),
                        onPressed: () async {
                          CustomProgressIndicator().show(context);
                          bool isNameChanged = false;
                          bool isEmailChanged = false;
                          bool isMobileChanged = false;
                          bool isBioChanged = false;
                          if (nameController.text != _user.displayName) {
                            isNameChanged = true;
                          } else if (emailController.text != _user.email) {
                            isEmailChanged = true;
                          } else if (mobileController.text.substring(4) !=
                              _user.phoneNumber) {
                            isMobileChanged = true;
                          } else if (bioController.text != (_user.bio ?? "")) {
                            isBioChanged = true;
                          } else {
                            CustomProgressIndicator().dismiss();
                            return;
                          }

                          if (isNameChanged ||
                              isEmailChanged ||
                              isMobileChanged ||
                              isBioChanged) {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .update({
                              "displayName": nameController.text.trim(),
                              "email": emailController.text.trim(),
                              "phoneNumber":
                                  mobileController.text.substring(4).trim(),
                              "bio": bioController.text.trim(),
                            });
                            CustomProgressIndicator().dismiss();
                            FuturisticToast.show(context,
                                message:
                                    "User Details Updated Succussfully...");
                            return;
                          } else {
                            CustomProgressIndicator().dismiss();
                            return;
                          }
                        },
                        child: Text(
                          'Save Changes',
                          style: GoogleFonts.nunito(
                            fontSize: 18,
                            color: Colors.cyanAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return Container(
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: SpinKitWave(
                            color: Colors.cyanAccent.withOpacity(0.8),
                            size: 40),
                      ),
                    ],
                  ),
                );
              }
            }),
      ),
    );
  }
}
