import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:urban_forest/reusable_widgets/reusable_methods.dart';
import 'package:urban_forest/view_model/form_validation.dart';

import '../utils/debug_format.dart';

// get the logo image form the image file name
Image logoWidget(String imageName) {
  return Image.asset(
    imageName,
    fit: BoxFit.fitWidth,
    width: 300,
    height: 300,
    color: Colors.white,
  );
}

// widget that used for form text,
// especially for sign in, sign up, and reset
class FormTextBox extends StatefulWidget {
  const FormTextBox({ 
    Key? key, 
    required this.labelText, 
    required this.icon, 
    required this.isUserName, 
    required this.isPasswordType,
    required this.controller,  
    this.nameField
  }) : super(key: key);

  final TextEditingController controller;
  final String labelText;
  final IconData icon;
  final bool isUserName;
  final bool isPasswordType;
  final bool? nameField;

  @override
  State<FormTextBox> createState() => _FormTextBoxState();
}

class _FormTextBoxState extends State<FormTextBox> {
  bool _canViewPassword = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPasswordType && !_canViewPassword,
          enableSuggestions: !widget.isPasswordType,
          autocorrect: !widget.isPasswordType,
          cursorColor: Colors.white,
          style: TextStyle(color: Colors.white.withOpacity(0.9)),
          decoration: InputDecoration(
            errorMaxLines: 3,
            prefixIcon: Icon(
              widget.icon,
              color: Colors.white70,
            ),
            
            // suffix eye button for password type to view password
            suffixIcon: widget.isPasswordType ? IconButton(
              icon: Icon(
                _canViewPassword ? Icons.visibility : Icons.visibility_off
              ),
              onPressed: () {
                setState(() {
                  _canViewPassword = !_canViewPassword;
                });
              },
            ) : null,

            labelText: widget.labelText,
            labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
            filled: true,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            fillColor: Colors.white.withOpacity(0.3),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: const BorderSide(width: 0, style: BorderStyle.none)
            ),
          ),
          
          keyboardType: (widget.isPasswordType || widget.isUserName)
              ? TextInputType.visiblePassword
              : TextInputType.emailAddress,
          
          validator: (value) {
            if (widget.nameField == null) {
              return validateAccount(value, widget.isPasswordType, widget.isUserName);
            } else {
              return validateName(value);
            }
          },
        ),
      ],
    );
  }
}

// sign-in and sign-up
Container firebaseButton(
  BuildContext context, String title, Function onTap) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: 50,
    margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(90)
    ),
    child: ElevatedButton(
      onPressed: () {
        onTap();
      },
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 19
        ),
      ),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.pressed)) {
            return Colors.black26;
          }
          return Colors.white;
        }),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30)
          )
        )
      ),
    )
  );
}



// snack bar hint about authentication state
SnackBar snackBarHint(String hint, {bool verify = false, BuildContext? context}) {
  return SnackBar(
    backgroundColor: const Color.fromARGB(255, 187, 173, 132),
    padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
    margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
    behavior: SnackBarBehavior.floating,
    content: Text(
      hint,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.black87,
        fontWeight: FontWeight.bold,
        fontSize: 15
      ),
    ),
    duration: verify ? 
      const Duration(days: 1) : 
      const Duration(milliseconds: 3000),
    action: verify ? SnackBarAction(
      label: "Verify",
      textColor: const Color.fromARGB(221, 35, 5, 168),
      onPressed: () async {
        try {
          final user = FirebaseAuth.instance.currentUser!;
          await user.sendEmailVerification();
        } catch (error) {
          var errorText = error.toString().substring(15, 18);
          if (errorText.contains("too")) {
            showHint(context!, "Too many request in a short period! Try again later");
          } else {
            showHint(context!, "Unknown error! Please try again later");
          }
        }
      },
    ) : null,
  );
}

