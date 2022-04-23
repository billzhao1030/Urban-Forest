import 'package:cloud_firestore/cloud_firestore.dart';


const String fireStoreUsers = "users";
CollectionReference dbUser = FirebaseFirestore.instance.collection(fireStoreUsers);

const backgroundColorArray = ["afef8d", "23cb23", "225508"];

const String ack = "Acknowledgement";