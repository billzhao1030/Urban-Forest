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

  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _userNameTextController = TextEditingController();
  final TextEditingController _confirmPasswordTextController = TextEditingController();

  final TextEditingController _firstNameTextController = TextEditingController();
  final TextEditingController _lastNameTextController = TextEditingController();

  final _formKey = GlobalKey<FormState>(); // for validation

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
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          profileInEdit = true;
                        });
                      }, 
                      child: Text("edit")
                    ),
                    profileInEdit ? FormTextBox(
                      labelText: "Edit User Name", 
                      icon: Icons.person_outline, 
                      isUserName: true, 
                      isPasswordType: false, 
                      controller: _userNameTextController
                    ) : Text(_userNameTextController.text),
              
                    profileInEdit ? FormTextBox(
                      labelText: "Edit First Name", 
                      icon: Icons.person_outline, 
                      isUserName: false, 
                      isPasswordType: false, 
                      controller: _firstNameTextController
                    ) : Text(_firstNameTextController.text),
              
                    profileInEdit ? FormTextBox(
                      labelText: "Edit Last Name", 
                      icon: Icons.person_outline, 
                      isUserName: false, 
                      isPasswordType: false, 
                      controller: _lastNameTextController
                    ) : Text(_lastNameTextController.text),
              
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          var uid = widget.model.modelUser.uid;
              
                          await dbUser.doc(uid).update({
                            "userName": _userNameTextController.text.trim(),
                            "firstName": _firstNameTextController.text.trim(),
                            "lastName": _lastNameTextController.text.trim()
                          }).then((value) => debugState("updated"),);
                
                          await widget.model.getUser();
                
                          setState(() {
                            profileInEdit = false;
                          });
                        }
                      }, 
                      child: const Text("Save")
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
