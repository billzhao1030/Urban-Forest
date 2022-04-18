import '../utils/string_validate.dart';

String? validate_account(String? value, bool isPasswordType, bool isUserName) {
  if (isPasswordType) {
    if (value == null || value.isEmpty) {
      return "Please enter password";
    } 
    else if (!value.isValidPassword) {
      return "Password should contains 1 Uppercase 1 lowercase and 1 number, length between 6 to 20";
    } 
  } else {
    if (isUserName) {
      
    } else {
      if (value == null || value.isEmpty) {
        return "Please enter email";
      } else if (!value.isValidEmail) {
        return "Invalid email!";
      } 
    }
  }
  
  return null;
}