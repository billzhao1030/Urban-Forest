import '../utils/string_validate.dart';

String? validate_account(String? value, bool isPasswordType, bool isUserName) {
  if (isPasswordType) {
    if (value == null || value.isEmpty) {
      return "Please enter email";
    } 
    else if (!value.isValidPassword) {
      return "Not valid password";
    } 
  } else {
    if (isUserName) {
      
    } else {
      if (value == null || value.isEmpty) {
        return "Please enter password";
      } else if (!value.isValidEmail) {
        return "Not valid email";
      } 
    }
  }
  
  return null;
}