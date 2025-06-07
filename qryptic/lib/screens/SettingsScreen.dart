import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lottie/lottie.dart';
import 'package:qryptic/helper/database.dart';
import 'package:qryptic/model/QrypticUser.dart';
import 'package:qryptic/screens/EditProfileScreen.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProfileSettingsScreen extends StatefulWidget {
  @override
  _ProfileSettingsScreenState createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  bool isNotificationsEnabled = false;
  bool isQuantumSecurityEnabled = false;
  bool isDarkMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: StreamBuilder(
          stream: userDataStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              QrypticUser _user = QrypticUser.fromMap(snapshot.data!.data()!);
              isNotificationsEnabled = _user.enableNotifications ?? false;
              isQuantumSecurityEnabled = _user.enableQuantumEncryption ?? false;

              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                        child: GestureDetector(
                          onTap: () =>
                              Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => EditProfileScreen(),
                          )),
                          child: CircleAvatar(
                            radius: 60,
                            child: LottieBuilder.asset(
                                'assets/animations/profile.json'),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        _user.displayName ?? "",
                        style: GoogleFonts.nunito(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.cyanAccent,
                        ),
                      ),
                      Text(
                        "@${_user.qrypticPhrase ?? ""}",
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 30),
                      _buildSwitchOption(
                          Icons.notifications,
                          'Enable Notifications',
                          isNotificationsEnabled, (value) async {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .update({
                          "enableNotifications": value,
                        });
                        setState(() {
                          isNotificationsEnabled = value;
                        });
                      }),
                      _buildSwitchOption(
                          Icons.security,
                          'Enable Quantum Security',
                          isQuantumSecurityEnabled, (value) async {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .update({
                          "enableQuantumEncryption": value,
                        });
                        setState(() {
                          isQuantumSecurityEnabled = value;
                        });
                      }),
                      _buildSettingOption(Icons.help_outline, 'Help & Support'),
                      SizedBox(height: 40),
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
                          await FirebaseAuth.instance.signOut();
                        },
                        child: Text(
                          'Log Out',
                          style: GoogleFonts.nunito(
                            fontSize: 18,
                            color: Colors.cyanAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return Container();
            } else {
              return Container(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: SpinKitWave(
                          color: Colors.cyanAccent.withOpacity(0.8), size: 40),
                    ),
                  ],
                ),
              );
            }
          }),
    );
  }

  Widget _buildSwitchOption(
      IconData icon, String title, bool value, Function(bool) onChanged) {
    return ListTile(
      leading: Icon(icon, color: Colors.cyanAccent),
      title: Text(
        title,
        style: GoogleFonts.nunito(
          fontSize: 18,
          color: Colors.white,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.cyanAccent,
        inactiveTrackColor: Colors.grey,
      ),
    );
  }

  Widget _buildSettingOption(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.cyanAccent),
      title: Text(
        title,
        style: GoogleFonts.nunito(
          fontSize: 18,
          color: Colors.white,
        ),
      ),
      onTap: () {},
    );
  }
}
