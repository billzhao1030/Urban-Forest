import '../utils/string_validate.dart';

// function that assign to the validator
String? validateAccount(String? value, bool isPasswordType, bool isUserName) {
  if (isPasswordType) {
    if (value == null || value.isEmpty) {
      return "Please enter password";
    } 
    else if (!value.trim().isValidPassword) {
      return "Password should contains 1 Uppercase 1 lowercase and 1 number, length between 6 to 20";
    } 
  } else {
    if (isUserName) {
      if (value == null || value.isEmpty) {
        return "Please enter username";
      } else if (!value.trim().isValidUserName) {
        return "Invalid user, should contains only letter, number or _-." 
        "(must not be the first or last character, not appear consecutively), length between 5 and 20";
      }
    } else {
      if (value == null || value.isEmpty) {
        return "Please enter email";
      } else if (!value.trim().isValidEmail) {
        return "Invalid email";
      } 
    }
  }
  
  return null;
}

String? validateName(String? value) {
  if (value == null || value.isEmpty) {
    return "Please enter";
  } else if (!value.trim().isValidName) {
    return "Invalid name, please contain only letters, spaces and -";
  }

  return null;
}

String? validateScale(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  } else if (!value.trim().isValidScale) {
    return "Invalid Number";
  }

  return null;
}

String? validateSpecies(String? value) {
  if (value == null || value.isEmpty) {
    return "Please enter";
  } else if (!value.trim().isValidSpecies) {
    return "Invalid Species";
  }

  return null;
}

String? validateGPS(String? value) {
  if (value == null || value.isEmpty) {
    return "Please enter";
  } else if (!value.trim().isValidGPS) {
    return "Invalid GPS location";
  }

  return null;
}

String? validateAddress(String? value) {
  if (value == null || value.isEmpty) {
    return "Please enter";
  } else if (!value.trim().isValidAddress) {
    return "Invalid Address";
  }

  return null;
}

String? validateAssetID(String? value) {
  if (value == null || value.isEmpty) {
    return "Please enter";
  } else if (!value.trim().isValidAssetID) {
    return "Invalid Asset ID";
  }

  return null;
}