import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urban_forest/provider/account_provider.dart';
import 'package:urban_forest/provider/user.dart';
import 'package:urban_forest/reusable_widgets/reusable_methods.dart';
import 'package:urban_forest/view/account/sign_in.dart';
import 'package:urban_forest/view/main_function/profile/account_setting.dart';

import '../../../utils/debug_format.dart';
import '../../../utils/reference.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({ Key? key, required this.user, required this.model }) : super(key: key);

  final UserAccount user;
  final AccountModel model;

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final user = FirebaseAuth.instance.currentUser!;
  var email = "";

  final TextEditingController _bugController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();

  TextStyle greyTextStyle = const TextStyle(
    color: Colors.grey,
    fontWeight: FontWeight.bold,
    fontStyle: FontStyle.italic
  );

  @override
  void dispose() {
    _bugController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    debugState("Profile section");
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        var currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Profile & Setting",
            textAlign: TextAlign.center,
          ),
          automaticallyImplyLeading: false,
        ),
        body: settingArea(context),
      ),
    );
  }

  Widget settingArea(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            widget.model.modelUser.userName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 26,
              fontStyle: FontStyle.italic
            )
          ),
          const SizedBox(height: 4,),
          Text(
            widget.user.emailAddress,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey
            ),
          ),

          const SizedBox(height: 24,),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text("Add Tree: ${widget.model.modelUser.requestAdd}", style: greyTextStyle,),
              Text("Edit Tree: ${widget.model.modelUser.requestUpdate}", style: greyTextStyle,),
              Text("Accepted: ${widget.model.modelUser.requestAccepted}", style: greyTextStyle,),
            ],
          ),
          const SizedBox(height: 8,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${widget.model.modelUser.levelName} (${widget.model.modelUser.levelPoints}):",
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                child: Transform.scale(
                  scale: 0.9,
                  child: LinearProgressIndicator(
                    value: widget.model.modelUser.levelProgress,
                    minHeight: 10,
                  ),
                ),
              ),
              Text(
                "${widget.model.modelUser.thisLevelProgress}/${widget.model.modelUser.thisLevelTotal}",
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold
                ),
              ),
            ],
          ),


          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("What is level?", style: TextStyle(color: Colors.grey),),
              Transform.scale(
                scale: 0.75,
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("What is level?"),
                          content: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                              child: Column(
                                children: [
                                  // level points description
                                  headerText("Level Point"),
                                  normalText(
                                    "To engage people to upload add/update tree request, "
                                    "users could earn level points based on the following rule:\n",
                                    isJust: true
                                  ),
                                  const SizedBox(height: 6,),
                                  normalText(
                                    " \u2022 6 points if add a new tree\n"
                                    " \u2022 4 points if edit a tree\n"
                                    " \u2022 10 points if request is accepted\n"
                                  ),

                                  // level name decription
                                  const SizedBox(height: 12,),
                                  headerText("Level Name"),
                                  normalText(
                                    "Different level points would have a unique level, the "
                                    "higher level means you have more contributes to the tree database. "
                                    "The level names and the points required are: \n",
                                    isJust: true
                                  ),
                                  const SizedBox(height: 6,),
                                  normalText(
                                    " \u2022 Tree Starter if points < 10\n"
                                    " \u2022 Tree Junior if 10 <= points < 30\n"
                                    " \u2022 Tree Senior if 30 <= points < 70\n"
                                    " \u2022 Tree Hero if 70 <= points < 150\n"
                                    " \u2022 Tree Legend if points < 150\n"
                                  ),

                                  // spam request description
                                  const SizedBox(height: 12,),
                                  headerText("Fallacious request"),
                                  normalText(
                                    "If the user keep uploading the unreasonable or redundant "
                                    "tree request just for earning points, the user account will be disabled "
                                    "if found. Please upload the useful and constructive request/data only",
                                    isJust: true
                                  ),

                                  const SizedBox(height: 12,),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    }, 
                                    child: const Text("OK")
                                  )
                                ]
                              ),
                            ),
                          ),
                        );
                      }
                    );
                  }, 
                  child: const Icon(
                    Icons.question_mark_outlined,
                    color: Colors.white,
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    primary: const Color.fromARGB(1, 1, 1, 1),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12,),
          
          SettingsGroup(
            title: "General", 
            children: <Widget>[
              AccountPage(model: widget.model,),
              buildLogout(),
              buildClear(),
              buildDeleteAccount()
            ]
          ),

          const SizedBox(height: 16,),

          SettingsGroup(
            title: "Feedback", 
            children: <Widget>[
              buildReportBug(),
              buildFeedback()
            ]
          ),
        ],
      ),
    );
  }

  Widget buildLogout() => SimpleSettingsTile(
    title: 'Logout',
    subtitle: '',
    leading: settingIcon(Icons.logout, Colors.blueAccent),
    onTap: () async {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return settingAlert(
            context,
            "Logout your account",
            "Confirm to sign out?",
            () async {
              debugState("Logout");
              FirebaseAuth.instance.signOut();

              // set preference
              final prefs = await SharedPreferences.getInstance();
              prefs.setString(loggedInPassword, "");

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => SignInView(filledEmail: email),
                )
              );
            }
          );
        }
      );
    },
  );

  Widget buildDeleteAccount() => SimpleSettingsTile(
    title: 'Delete Account',
    subtitle: '',
    leading: settingIcon(Icons.delete, Colors.redAccent),
    onTap: () async {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return settingAlert(
            context,
            "Delete this account",
            "Confirm to delete this account, "
            "notice that all your account data would be deleted and can't be recoverd!",
            () async {
              debugState("Delete Account");

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const SignInView(filledEmail: ""),
                )
              );

              var uid = FirebaseAuth.instance.currentUser!.uid;
              await dbUser.doc(uid).delete();

              FirebaseAuth.instance.currentUser!.delete();

              Settings.clearCache();
            }
          );
        }
      );
    },
  );

  Widget buildClear() => SimpleSettingsTile(
    title: 'Clear Data',
    subtitle: '',
    leading: settingIcon(Icons.clear_all, Colors.yellow),
    onTap: () async {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return settingAlert(
            context,
            "Clear data",
            "Confirm to clear all cache and shared perference for this device?",
            () async {
              debugState("Clear Data");

              FirebaseAuth.instance.signOut();
                          
              // set preference
              final prefs = await SharedPreferences.getInstance();
              prefs.clear();
              Settings.clearCache();

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => SignInView(filledEmail: email),
                )
              );
            }
          );
        }
      );
    },
  );

  Widget buildReportBug() => SimpleSettingsTile(
    title: 'Report a bug',
    subtitle: '',
    leading: settingIcon(Icons.bug_report, Colors.teal),
    child: WillPopScope(
      onWillPop: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        Navigator.pop(context, false);
        return Future.value(false);
      },
      child: SettingsScreen(
        title: "Report a bug",
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                TextField(
                  controller: _bugController,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  minLines: 3,
                  maxLines: 7,
                  autofocus: true
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.35,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_bugController.text.trim().isEmpty) {
                        showHint(context, "The content is empty!");
                      } else if (_bugController.text.trim().length < 8) {
                        showHint(context, "The bug detail is too short\nPlease give more description");
                      } else {
                        DateFormat dateFormatID = DateFormat("yyyyMMddHHmmss");
                        String uid = FirebaseAuth.instance.currentUser!.uid;
                        var bugID = dateFormatID.format(DateTime.now()) + "!$uid";
                        var time = DateTime.now().millisecondsSinceEpoch;
                        dbBug.doc(bugID)
                          .set({
                            "bug_content": _bugController.text.trim(),
                            "time": time,
                            "uid": uid
                          })
                          .then((value) async {
                            debugState("Send a bug");
                            showHint(context, "You have uploaded the bug report!");
                            await Future.delayed(const Duration(milliseconds: 1500));
                            // hide the current snackbar
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            
                            _bugController.clear();
    
                            Navigator.pop(context);
                          })
                          .catchError((error) {
                            debugState(error.toString());
                          });
                      }
                    },  
                    child: const Text("Upload")
                  ),
                )
              ],
            ),
          )
        ]
      ),
    ),
  );

  Widget buildFeedback() => SimpleSettingsTile(
    title: 'Send Feedback',
    subtitle: '',
    leading: settingIcon(Icons.thumb_up, Colors.purple),
    child: WillPopScope(
      onWillPop: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        Navigator.pop(context, false);
        return Future.value(false);
      },
      child: SettingsScreen(
        title: "Send feedback",
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                TextField(
                  controller: _feedbackController,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  minLines: 3,
                  maxLines: 7,
                  autofocus: true
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.35,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_feedbackController.text.trim().isEmpty) {
                        showHint(context, "The content is empty!");
                      } else {
                        DateFormat dateFormatID = DateFormat("yyyyMMddHHmmss");
                        String uid = FirebaseAuth.instance.currentUser!.uid;
                        var feedbackID = dateFormatID.format(DateTime.now()) + "#$uid";
                        var time = DateTime.now().millisecondsSinceEpoch;
                        dbFeedback.doc(feedbackID)
                          .set({
                            "feedback_content": _feedbackController.text.trim(),
                            "time": time,
                            "uid": uid
                          })
                          .then((value) async {
                            debugState("Send a feedback");
                            showHint(context, "You have uploaded the feedback!");
                            await Future.delayed(const Duration(milliseconds: 1500));
                            // hide the current snackbar
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            
                            _feedbackController.clear();
                            
                            Navigator.pop(context);
                          })
                          .catchError((error) {
                            debugState(error.toString());
                          });
                      }
                    },  
                    child: const Text("Upload")
                  ),
                )
              ],
            ),
          )
        ]
      ),
    ),
  );
}