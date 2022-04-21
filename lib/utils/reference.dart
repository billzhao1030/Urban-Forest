import 'package:cloud_firestore/cloud_firestore.dart';


const String fireStoreUsers = "users";
CollectionReference dbUser = FirebaseFirestore.instance.collection(fireStoreUsers);

