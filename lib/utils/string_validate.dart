
// extension of regex expression match
extension ValidateString on String {
  // judge if the string is a valid email
  // rule: 
  //   start with alphanumeric characters or dot
  //   then @
  //   then alphanumeric character followed by dot then alphanumeric characters
  bool get isValidEmail {
    final emailRegExp = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return emailRegExp.hasMatch(this);
  }

  // judge if the string is a valid username
  // rule: 
  //   Username consists of alphanumeric characters (a-zA-Z0-9), lowercase, or uppercase.
  //   Username allowed of the dot (.), underscore (_), and hyphen (-).
  //   The dot (.), underscore (_), or hyphen (-) must not be the first or last character.
  //   The dot (.), underscore (_), or hyphen (-) does not appear consecutively
  //   The number of characters must be between 5 to 20.
  bool get isValidUserName {
    final nameRegExp = RegExp(r"^[a-zA-Z0-9]([._-](?![._-])|[a-zA-Z0-9]){3,18}[a-zA-Z0-9]$");
    return nameRegExp.hasMatch(this);
  }

  // judge if the string is a valid password
  // rule: 
  //   at least 1 number, 1 uppercase, 1 lowercase, between 6 to 20 digits
  bool get isValidPassword {
    final passwordRegExp = 
    RegExp(r"^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z]).{6,20}$");
    return passwordRegExp.hasMatch(this);
  }

  // judge if the string is a valid password
  // rule: 
  //   all number
  bool get isValidPhone{
    final phoneRegExp = RegExp(r"^\+?0[0-9]{10}$");
    return phoneRegExp.hasMatch(this);
  }
}