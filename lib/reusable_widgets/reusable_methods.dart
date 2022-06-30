import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:urban_forest/reusable_widgets/reusable_wiget.dart';

import '../utils/color_utils.dart';
import '../utils/reference.dart';

// show the snack bar message
void showHint(BuildContext context, String message, {bool verify = false, double b = 12}) {
  ScaffoldMessenger.of(context).showSnackBar(snackBarHint(message, verify: verify, context: context, b: b));
}

// background for most of screen
Container backgroundDecoration(BuildContext context, Widget? child, {bool? dismiss = true}) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: MediaQuery.of(context).size.height,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          hexStringToColor(backgroundColorArray[0]),
          hexStringToColor(backgroundColorArray[1]),
          hexStringToColor(backgroundColorArray[2]),
        ], 
        begin: Alignment.topCenter, 
        end: Alignment.bottomCenter
      )
    ),
    child: Scrollbar(
      isAlwaysShown: false,
      child: SingleChildScrollView(
        keyboardDismissBehavior: 
          dismiss == true ? ScrollViewKeyboardDismissBehavior.onDrag : ScrollViewKeyboardDismissBehavior.manual,
        scrollDirection: Axis.vertical,
        child: child
      ),
    ),
  );
}

Container settingIcon(IconData icon, Color color) {
  return Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color,
    ),
    child: Icon(
      icon, color: Colors.white,
    ),
  );
}

void showError(BuildContext context, String message, double paddingBottom) {
  try {
    ScaffoldMessenger.of(context).showSnackBar(snackBarHint(message, b: paddingBottom));
  } catch(e) {
    log(e.toString());
  }
}

Column privacyPolicy() {
  return Column(
    children: [
      normalText(
        "The Launceston City Council GIS team is committed to "
        "providing quality services to you and this policy outlines our "
        "ongoing obligations to you in respect of how we manage your Personal Information.\n\n"
        "We have adopted the Australian Privacy Principles (APPs) contained "
        "in the Privacy Act 1988 (Cth) (the Privacy Act). The NPPs govern the "
        "way in which we collect, use, disclose, store, secure and dispose of your Personal Information.\n\n"
        "A copy of the Australian Privacy Principles may be obtained from the website of The Office "
        "of the Australian Information Commissioner at www.aoic.gov.au\n"
      ),

      headerText("What is Personal Information and why do we collect it?"),
      normalText(
        "Personal Information is information or an opinion that identifies an "
        "individual. Examples of Personal Information we collect include: names, locations "
        "(i.e location of a submitted tree), email addresses.\n\n"
        "This Personal Information is obtained in via our mobile application. We do not guarantee "
        "website links or policy of authorised third parties.\n\n"
        "We collect your Personal Information for the primary purpose of providing our services to you, providing "
        "information to our clients and marketing. We may also use your Personal Information"
        " for secondary purposes closely related to the primary purpose, in circumstances "
        "where you would reasonably expect such use or disclosure. You may unsubscribe from"
        " our mailing/marketing lists at any time by contacting us in writing.\n\n"
        "When we collect Personal Information we will, where appropriate and where possible, explain to you why"
        " we are collecting the information and how we plan to use it.\n"
      ),

      headerText("Sensitive Information"),
      normalText(
        "Sensitive information is defined in the Privacy Act to include information or opinion about such things"
        " as an individual's racial or ethnic origin, political opinions, membership of a political "
        "association, religious or philosophical beliefs, membership of a trade union or other professional "
        "body, criminal record or health information.\n\n"
        "Sensitive information will be used by us only:\n"
        "--For the primary purpose for which it was obtained\n"
        "--For a secondary purpose that is directly related to the primary purpose\n"
        "--With your consent; or where required or authorised by law.\n\n"
      ),

      headerText("Third Parties"),
      normalText(
        "Where reasonable and practicable to do so, we will collect your Personal Information only from"
        " you. However, in some circumstances we may be provided with information by third "
        "parties. In such a case we will take reasonable steps to ensure that you are made "
        "aware of the information provided to us by the third party.\n"
      ),

      headerText("Disclosure of Personal Information"),
      normalText(
        "Your Personal Information may be disclosed in a number of circumstances including the following:\n"
        "--Third parties where you consent to the use or disclosure; and\n"
        "--Where required or authorised by law.\n"
      ),

      headerText("Security of Personal Information"),
      normalText(
        "Your Personal Information is stored in a manner that reasonably protects it from misuse and "
        "loss and from unauthorized access, modification or disclosure.\n\n"
        "When your Personal Information is no longer needed for the purpose for which "
        "it was obtained, we will take reasonable steps to destroy or permanently "
        "de-identify your Personal Information. However, most of the Personal Information"
        " is or will be stored in client files which will be kept by us for a minimum of"
        " 7 years.\n"
      ),

      headerText("Access to your Personal Information"),
      normalText(
        "You may access the Personal Information we hold about you and to update and/or correct"
        " it, subject to certain exceptions. If you wish to access your Personal "
        "Information, please contact us in writing.\n\n"
        "The Launceston City Council will not charge any fee for your access request, but may charge "
        "an administrative fee for providing a copy of your Personal Information.\n\n"
        "In order to protect your Personal Information we may require identification from you before releasing the requested information.\n"
      ),

      headerText("Maintaining the Quality of your Personal Information"),
      normalText(
        "It is an important to us that your Personal Information is up to date. We will take "
        "reasonable steps to make sure that your Personal Information is accurate, complete "
        "and up-to-date. If you find that the information we have is not up to date or is "
        "inaccurate, please advise us as soon as practicable so we can update our records "
        "and ensure we can continue to provide quality services to you.\n"
      ),

      headerText("Policy Updates"),
      normalText(
        "This Policy may change from time to time and is via our mobile application.\n"
      ),

      normalText(
        "\n\nPrivacy policy template was retrieved from: "
        "https://business.vic.gov.au/tools-and-templates/privacy-policy-template\n\n"
      )
    ],
  );
}

Text normalText(String text, {bool isJust = false}) {
  return Text(
    text,
    style: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600
    ),
    textAlign: isJust ? TextAlign.justify : null,
  );
}

Text headerText(String text) {
  return Text(
    "\n$text\n",
    style: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold
    ),
    textAlign: TextAlign.center
  );
}

AlertDialog settingAlert(BuildContext context, String title, String content, Function onTap) {
  return AlertDialog(
    title: Text(title),
    content: Text(content),
    actions: <Widget>[
      TextButton(
        onPressed: () {
          Navigator.pop(context, "No");
        },
        child: const Text(
          'No',
          style: TextStyle(
            fontSize: 22
          ),
        ),
      ),
      TextButton(
        onPressed: () async {
          Navigator.pop(context, "Yes");
          onTap();
        },
        child: const Text(
          'Yes',
          style: TextStyle(
              fontSize: 22
          ),
        ),
      ),
    ],
  );
}

// the form text in cupertino
DefaultTextStyle formText(String text, {
  double fontsize = 20, 
  FontStyle fontStyle = FontStyle.normal,
  Color fontColor = Colors.white
  }) {
  return DefaultTextStyle(
    textAlign: TextAlign.center,
    style: TextStyle(
      color: fontColor,
      fontSize: fontsize,
      fontWeight: FontWeight.bold,
      fontStyle: fontStyle,
    ),
    child: Text(text),
  );
}