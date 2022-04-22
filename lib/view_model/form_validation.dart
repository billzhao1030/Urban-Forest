import '../utils/string_validate.dart';

// function that assign to the validator
String? validateAccount(String? value, bool isPasswordType, bool isUserName) {
  if (isPasswordType) {
    if (value == null || value.isEmpty) {
      return "Please enter password";
    } 
    else if (!value.isValidPassword) {
      return "Password should contains 1 Uppercase 1 lowercase and 1 number, length between 6 to 20";
    } 
  } else {
    if (isUserName) {
      if (value == null || value.isEmpty) {
        return "Please enter username";
      } else if (!value.isValidUserName) {
        return "Invalid user, should contains only letter, number or _-." 
        "(must not be the first or last character, not appear consecutively), length between 5 and 20";
      }
    } else {
      if (value == null || value.isEmpty) {
        return "Please enter email";
      } else if (!value.isValidEmail) {
        return "Invalid email";
      } 
    }
  }
  
  return null;
}

String? validateName(String? value) {
  if (value == null || value.isEmpty) {
    return "Please enter";
  } else if (!value.isValidName) {
    return "Invalid name, please contain only letters, spaces and -";
  }

  return null;
}