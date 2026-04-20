import 'package:flutter/material.dart';
import '../models/contact.dart';

class ContactDialog extends StatefulWidget {
  final Contact? contact;
  final Function(Contact) onConfirm;

  const ContactDialog({super.key, this.contact, required this.onConfirm});

  @override
  State<ContactDialog> createState() => _ContactDialogState();
}

class _ContactDialogState extends State<ContactDialog> {
  late TextEditingController _fName, _lName, _mName, _phone;

  @override
  void initState() {
    super.initState();
    // Pre-fills fields if editing an existing contact
    _fName = TextEditingController(text: widget.contact?.firstName);
    _lName = TextEditingController(text: widget.contact?.lastName);
    _mName = TextEditingController(text: widget.contact?.middleName);
    _phone = TextEditingController(text: widget.contact?.phoneNumber);
  }

  @override
  void dispose() {
    _fName.dispose();
    _lName.dispose();
    _mName.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.contact == null ? "Add Contact" : "Update Contact"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _lName,
              decoration: const InputDecoration(hintText: "Last Name"),
            ),
            TextField(
              controller: _fName,
              decoration: const InputDecoration(hintText: "First Name"),
            ),
            TextField(
              controller: _mName,
              decoration: const InputDecoration(hintText: "Middle Name"),
            ),
            TextField(
              controller: _phone,
              decoration: const InputDecoration(hintText: "Phone Number"),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("CANCEL"),
        ),
        ElevatedButton(
          onPressed: () {
            // Passes back a Contact object — preserving the id if editing
            widget.onConfirm(Contact(
              id: widget.contact?.id, // ← keeps the Firestore doc ID for updates
              firstName: _fName.text.trim(),
              lastName: _lName.text.trim(),
              middleName: _mName.text.trim(),
              phoneNumber: _phone.text.trim(),
            ));
            Navigator.pop(context);
          },
          child: const Text("OK"),
        ),
      ],
    );
  }
}