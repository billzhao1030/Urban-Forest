import 'package:urban_forest/utils/debug_format.dart';

class AIResponse {
  // possible name list and accuracy (first two response)
  List<String> commonName = [];
  List<String> scientificName = [];
  List<double> accuracyList = [];

  // best response
  String bestMatch = "";
  double bestAccuracy = 0;

  // judge if it's a bad recognition
  bool lowAccuracy = false;

  AIResponse();

  AIResponse.fromJson(Map<String, dynamic> json)
  : 
    bestMatch = json['bestMatch'],
    bestAccuracy = json['results'][0]['score'] * 100
    {
      lowAccuracy = (bestAccuracy < 50);
      for (var i = 0; i < 2; i++) {
        var result = json['results'][i];

        scientificName.add(result['species']['scientificNameWithoutAuthor']);
        accuracyList.add(result['score'] * 100);

        if (lowAccuracy || i == 0) {
          for (var name in result['species']['commonNames']) {
            commonName.add(name);
          }
        }
      }
    }


  void todebug() {
    var str = "\nBest match: $bestMatch "
    "With $bestAccuracy% accuracy\n"
    "Low accuracy: $lowAccuracy\n"
    "The accuracy list: $accuracyList\n"
    "The common names: $commonName\n"
    "The scientific names: $scientificName";

    debugState(str);
  }
}