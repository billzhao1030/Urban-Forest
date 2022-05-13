import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urban_forest/reusable_widgets/reusable_methods.dart';
import 'package:urban_forest/utils/reference.dart';
import 'package:urban_forest/view/account/sign_in.dart';

class Acknowledge extends StatefulWidget {
  const Acknowledge({ Key? key }) : super(key: key);

  @override
  State<Acknowledge> createState() => _AcknowledgeState();
}

class _AcknowledgeState extends State<Acknowledge> {
  bool confirm = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          backgroundDecoration(context, null),
          acknowledgeDialog()
        ],
      )
    );
  }

  Center acknowledgeDialog() {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.75,
        child: AlertDialog(
          title: const Text(
            "Terms & Conditions",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic
            ),
            textAlign: TextAlign.center,
          ),
          backgroundColor: const Color.fromARGB(255, 247, 244, 199),
          content: Scrollbar(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                    child: Column(
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
                    ),
                  ),
                  
                  ListTile(
                    onTap: () {},
                    title: const Text("I have read and acknowledge"),
                    leading: Checkbox(
                      value: confirm, 
                      onChanged: (value) {
                        setState(() {
                          confirm = !confirm;
                        });
                      }
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            MaterialButton(
              elevation: 5.0,
              textColor: const Color.fromARGB(255, 9, 133, 13),
              child: const Text(
                "Confirm",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold
                ),
              ),
              onPressed: confirm ? () async {
                final prefs = await SharedPreferences.getInstance();
                prefs.setBool(ack, true);
    
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignInView(
                      filledEmail: "",
                    )
                  )
                );
              } : null,
            )
          ],
        ),
      ),
    );
  }

  Text normalText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600
      ),
      //textAlign: TextAlign.justify,
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
}