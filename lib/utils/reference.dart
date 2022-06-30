import 'package:cloud_firestore/cloud_firestore.dart';


const String fireStoreUsers = "users";
const String fireStoreRequests = "requests";
const String fireStoreBug = "bug_report";
const String fireStoreFeedback = "feedback";
CollectionReference dbUser = FirebaseFirestore.instance.collection(fireStoreUsers);
CollectionReference dbRequests = FirebaseFirestore.instance.collection(fireStoreRequests);
CollectionReference dbBug = FirebaseFirestore.instance.collection(fireStoreBug);
CollectionReference dbFeedback = FirebaseFirestore.instance.collection(fireStoreFeedback);

const backgroundColorArray = ["afef8d", "23cb23", "225508"];



const String apiAIKey = "2b100KCG6O3OeIMqokoAQCliz";
const apiAIRecognition = "https://my-api.plantnet.org/v2/identify/all?api-key=$apiAIKey";

const String loggedInEmail = "UserEmail";
const String loggedInPassword = "UserPassword";
const String loggedInUID = "UserUID";

int globalLevel = 1;

List<String> locClassItems = ["Roads", "Not Applicable"];
List<String> locCategoryItems = ["Urban", "Rural"];
List<String> treeLocItems = ["Street", "Park"];


// Shared preference String list
const String ack = "Acknowledgement"; // for terms of service