class Contact {
  String firstName;
  String lastName;
  String? middleName;
  String phoneNumber;

  Contact({   // Constructor with named parameters
    required this.firstName,
    required this.lastName,
    this.middleName,
    required this.phoneNumber,
  });  

  // Requirement: "Last name, comma, first name and middle name"
  String get displayName {
    String middle = (middleName != null && middleName!.isNotEmpty) ? " $middleName" : "";
    return "$lastName, $firstName$middle";
  }
}