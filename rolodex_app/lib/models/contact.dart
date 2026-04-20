class Contact {
  String? id; // Firestore auto-generated document ID
  String firstName;
  String lastName;
  String? middleName;
  String phoneNumber;

  Contact({
    this.id,
    required this.firstName,
    required this.lastName,
    this.middleName,
    required this.phoneNumber,
  });

  // Converts a Contact object → Firestore document (for create & update)
  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'middleName': middleName ?? '',
      'phoneNumber': phoneNumber,
    };
  }

  // Converts a Firestore document → Contact object (for read)
  factory Contact.fromFirestore(String id, Map<String, dynamic> data) {
    return Contact(
      id: id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      middleName: data['middleName'],
      phoneNumber: data['phoneNumber'] ?? '',
    );
  }

  // Display format: "Last, First Middle"
  String get displayName {
    String middle =
        (middleName != null && middleName!.isNotEmpty) ? " $middleName" : "";
    return "$lastName, $firstName$middle";
  }
}