import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:urban_forest/reusable_widgets/reusable_wiget.dart';

import '../utils/color_utils.dart';
import '../utils/reference.dart';

// show the snack bar message
void showHint(BuildContext context, String message, {bool verify = false, double b = 12, keep = false}) {
  ScaffoldMessenger.of(context).showSnackBar(snackBarHint(message, verify: verify, context: context, b: b, keep: keep));
}

// background for most of screen
Container backgroundDecoration(BuildContext context, Widget? child, {bool? dismiss = true}) {
  List<Color> colorArray = [];
  for (var i=0; i<18; i++) {
    colorArray.add(hexStringToColor(backgroundColorArray[i]));
  }
  return Container(
    width: MediaQuery.of(context).size.width,
    height: MediaQuery.of(context).size.height,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: colorArray, 
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

Column plantNetpp() {
  return Column(
    children: [
      normalText(
        "These Terms and Conditions govern the conditions in which you may "
        "access and use the Pl@ntNet API services (https://my.plantnet.org/). Any and "
        "all users of the Pl@ntNet API service accept the present General Terms and "
        "Conditions."
      ),
      headerText("User account"),
      normalText(
        "Using Pl@ntNet API requires the creation of a user account.\n"
        "When you create an account, we collect your e-mail address ("
        "useful for password reset; might be used very occasionally to"
        " contact users), your name and first name (optionally) and a "
        "username (to log in)."
      ),
      normalText(
        "For security reasons, passwords are not directly stored in the"
        " database. They pass through a cryptographic hash function whose "
        "result is stored (the hashing action cannot be reversed). A unique"
        " numeric identifier is attributed to each account and will be as"
        "sociated with every data collected from this account (user account"
        " data, history of queries)."
      ),
      headerText("Main Pl@ntNet API feature: Identify a plant with a query"),
      normalText(
        "Pl@ntNet API is free of use up to 500 identification queries per day"
        ". It is also free of use for specific non-profit educational and scien"
        "tific purposes: please contact us and indicate (i) the name and url of"
        " your non-profit organization, (ii) a short description of the usage "
        "of Pl@ntNet API you are targeting.\n"
        "Pl@ntNet API is paying for commercial usage beyond 500 identification req"
        "uests per day. This paying access requires signing the following agreement:"
        "https://my.plantnet.org/documents/agreement_PlantNet_API_english_v4.pdf\n"
        "In any case, the usage of Pl@ntNet API is limited to 10 simultaneous requests per client."
      ),
      headerText("Use of the Pl@ntNet API"),
      normalText(
        "Your personal account and your login information provided by Pl@ntNet"
        " are placed under your exclusive responsibility. You will not share you"
        "r password nor let anyone else access your account, or do anything else"
        " that might jeopardize the security of your account. You are solely res"
        "ponsible for the use made of your login information. You are solely res"
        "ponsible for any loss, diversion or non-authorized use of your login in"
        "formation and their consequences. All remarks and images submitted on t"
        "his application must be in compliance with French laws and regulations "
        "in force. You expressly commit not to using any racist, pornographic or"
        " slanderous words on the application. It is reminded that you are entir"
        "ely responsible for the content you spread and that Pl@ntNet will not b"
        "e considered responsible for the content you have issued."
      ),
      headerText("Limitation of liability"),
      normalText(
        "You acknowledge having been informed and accept the fact that under no c"
        "ircumstance whatsoever shall Pl@ntNet be liable for the creation, modifica"
        "tion, suppression of your personal data, which is under your full responsi"
        "bility. You use Pl@ntNet API at your own risks. Under no circumstance what"
        "soever shall Pl@ntNet be liable for any direct or indirect damages, in par"
        "ticular material prejudice, data loss or financial prejudice related to th"
        "e access or use of this application. The Pl@ntNet's contents are displayed"
        " without any warranty whatsoever.\n"
        "In no event shall Pl@ntNet be liable for the accuracy of the results obtain"
        "ed by the use of the Pl@ntNet API. Pl@ntNet shall by no means be responsible "
        "for any direct or indirect damages that may incur as a result of the use of"
        " the application."
      ),
      headerText("Users' rights and obligations"),
      normalText(
        "The contents of this site are protected under literary and artistic property "
        "law, the Bern Convention, EU directive 96/9/CE and book 1 of the French Code "
        "de la propriété intellectuelle . All reproductions other than for the persona"
        "l use of visitors to the site, notably with a view to publication in any form"
        ", are strictly forbidden without the express written permission of Pl@ntNet.\n"
        "Visitors are responsible for their interpretation and use of the information con"
        "sulted, and for the data they provide on forms included in the site. They are"
        " bound by the prevailing rules and regulations."
      ),
      headerText("Intellectual property rights"),
      normalText(
        "No element of the Pl@ntNet application shall be copied, reproduced, mod"
        "ified, republished, downloaded, distorted, transmitted or distributed, howsoe"
        "ver done, partially or integrally, without the written and prior authorizatio"
        "n from Pl@ntNet, except for the strict needs of the press and provided that "
        "the intellectual property rights and any other mentioned property rights are "
        "being respected."
      ),
      headerText("Personal data"),
      normalText(
        "By registering to the Pl@ntNet API application, you accept that your identity,"
        " under the names, surnames and email address you specified when registering, "
        "is stored by Pl@ntNet until the account is cancelled.\n"
        "In accordance with Articles 49 and following of Law No 78-17 of 6 January 1978 "
        "on data processing, files and freedoms and Articles 15 and following of Regul"
        "ation (EU) 2016/679 of the European Parliament and of the Council of 27 April"
        " 2016 on the protection of individuals with regard to the processing of perso"
        "nal data and on the free movement of such data, and repealing Directive 95/46"
        "/EC (RGPD or GDPR), any person may:\n"
        "  \u2022 have confirmation that personal data relating to him/her are or are not process"
        "ed and, where they are processed, access to such personal data,\n"
        "  \u2022 request the correction or deletion of his/her personal data,\n"
        "  \u2022 request that the processing of his/her personal data be limited,\n"
        "  \u2022 request the portability of his/her personal data if the processing is based on consent or a contract."
        "Any person may also, for legitimate reasons, object to the processing of data concerning him/her.\n"
        "Any person may give general or specific instructions regarding the storage, erasure and communication"
        " of your personal data after your death.\n"
      ),
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