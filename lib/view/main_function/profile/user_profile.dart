import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:urban_forest/reusable_widgets/reusable_wiget.dart';
import 'package:urban_forest/utils/debug_format.dart';
import 'package:urban_forest/utils/reference.dart';

import '../../../provider/account_provider.dart';
import '../../../reusable_widgets/reusable_methods.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({ Key? key, required this.model }) : super(key: key);

  final AccountModel model;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool profileInEdit = false;

  final TextEditingController _userNameTextController = TextEditingController();
  final TextEditingController _firstNameTextController = TextEditingController();
  final TextEditingController _lastNameTextController = TextEditingController();

  bool profileUploading = false;
  bool resetEmailSending = false;

  final _formKey = GlobalKey<FormState>(); // for validation

  TextStyle infoStyle = const TextStyle(
    color: Colors.white,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
  TextStyle advInfoStyle = const TextStyle(
    color: Colors.black54,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    fontStyle: FontStyle.italic
  );

  @override
  void initState() {
    _userNameTextController.text = widget.model.modelUser.userName;
    _firstNameTextController.text = widget.model.modelUser.firstName;
    _lastNameTextController.text = widget.model.modelUser.lastName;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (profileInEdit) {
          showDialog(
            context: context, 
            builder: (BuildContext context) {
              return profileSave(context);
            }
          );
        } else {
          Navigator.pop(context, false);
        }
        
        return Future.value(false);
      },
      child: SettingsScreen(
        title: "User Profile",
        children: [
          backgroundDecoration(
            context, 
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    profileInEdit ? FormTextBox(
                      labelText: "Edit User Name", 
                      icon: Icons.person_outline, 
                      isUserName: true, 
                      isPasswordType: false, 
                      controller: _userNameTextController
                    ) : Text(
                      "Username: ${_userNameTextController.text}",
                      style: infoStyle,
                    ),
                    const SizedBox(height: 16,),
              
                    profileInEdit ? FormTextBox(
                      labelText: "Edit First Name", 
                      icon: Icons.person_outline, 
                      isUserName: true, 
                      isPasswordType: false, 
                      controller: _firstNameTextController,
                      nameField: true,
                    ) : Text(
                      "First name: ${_firstNameTextController.text}",
                      style: infoStyle,
                    ),
                    const SizedBox(height: 16,),
              
                    profileInEdit ? FormTextBox(
                      labelText: "Edit Last Name", 
                      icon: Icons.person_outline, 
                      isUserName: true, 
                      isPasswordType: false, 
                      controller: _lastNameTextController,
                      nameField: true,
                    ) : Text(
                      "Last name: ${_lastNameTextController.text}",
                      style: infoStyle,
                    ),
                    const SizedBox(height: 16,),

                    firebaseButton(context, "Edit", () {
                        setState(() {
                          profileInEdit = true;
                        });
                      }
                    ),
              
                    profileInEdit ? firebaseButton(context, "Save", () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            profileUploading = true;
                          });
                          var uid = widget.model.modelUser.uid;
              
                          await dbUser.doc(uid).update({
                            "userName": _userNameTextController.text.trim(),
                            "firstName": _firstNameTextController.text.trim(),
                            "lastName": _lastNameTextController.text.trim()
                          }).then((value) => debugState("updated"),);
                
                          await widget.model.getUser();
                
                          setState(() {
                            profileInEdit = false;
                            profileUploading = false;

                            showHint(context, "Profile saved");
                          });
                        }
                      }
                    ) : Container (),

                    !resetEmailSending ? firebaseButton(context, "Reset password", () async {
                      var response = await showDialog(context: context, builder: (BuildContext context) {
                        return resetPasswordInProfile(context);
                      });

                      if (!response.toString().contains("No")) {
                        showHint(context, 'Please follow the steps in the email we sent you to reset the password');
                      }
                    }) : Container (
                      margin: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12,),
                    ExpandableSettingsTile(
                      expanded: true,
                      leading: const Icon(Icons.info),
                      title: 'Advanced information',
                      children: <Widget>[
                        Column(
                          //crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "UID: ${widget.model.modelUser.uid}",
                              style: advInfoStyle,
                            ),
                            const SizedBox(height: 16,),

                            Text(
                              "Email: ${widget.model.modelUser.emailAddress}",
                              style: advInfoStyle,
                            ),
                            const SizedBox(height: 16,),

                            Text(
                              "Access Level: ${widget.model.modelUser.accessLevel}",
                              style: advInfoStyle,
                            ),
                            const SizedBox(height: 16,),
                          ],
                        )
                      ],
                    ) 
                  ],
                ),
              )
            )
          )
        ]
      ),
    );
  }

  AlertDialog resetPasswordInProfile(BuildContext context) {
    return settingAlert(
      context, 
      "Reset password", 
      "Confirm sending the reset email", 
      () {
        setState(() {
          resetEmailSending = true;
        });

        FirebaseAuth.instance
        .sendPasswordResetEmail(email: widget.model.modelUser.emailAddress)
        .then((value) {
          setState(() {
            resetEmailSending = false;
          });
        })
        .onError((error, stackTrace) {
          debugState("Error: ${error.toString()}");

          var errText = error.toString().substring(15, 21);
          debugState("Firebase error: $errText");
            
          if (errText.contains("too")) {
            showHint(context, "Too many request in a short period! Try again later");
          } else if (errText.contains("user-d")) {
            showHint(context, "The user account has been disabled by an administrator");
          } else if (errText.contains("user-n")){
            showHint(context, "This email doesn't link to an account! Please sign up");
          } else if (errText.contains("inv")) {
            showHint(context, "This email address doen't exist!");
          } else if (errText.contains("netw")) {
            showHint(context, "There's network issue! Please try again later");
          }
        });
    });
  }

  AlertDialog profileSave(BuildContext context) {
    return AlertDialog(
      title: const Text("Save your profile"),
      content: const Text("Your profile hasn't been saved, you may lose your change if go back"),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'OK',
            style: TextStyle(
              fontSize: 22
            ),
          ),
        ),
      ],
    );
  }
}
