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
    _fName = TextEditingController(text: widget.contact?.firstName);
    _lName = TextEditingController(text: widget.contact?.lastName);
    _mName = TextEditingController(text: widget.contact?.middleName);
    _phone = TextEditingController(text: widget.contact?.phoneNumber);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.contact == null ? "Add Contact" : "Update Contact"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(controller: _lName, decoration: const InputDecoration(hintText: "Last Name")),
            TextField(controller: _fName, decoration: const InputDecoration(hintText: "First Name")),
            TextField(controller: _mName, decoration: const InputDecoration(hintText: "Middle Name")),
            TextField(controller: _phone, decoration: const InputDecoration(hintText: "Phone Number")),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
        ElevatedButton(
          onPressed: () {
            widget.onConfirm(Contact(
              firstName: _fName.text,
              lastName: _lName.text,
              middleName: _mName.text,
              phoneNumber: _phone.text,
            ));
            Navigator.pop(context);
          },
          child: const Text("OK"),
        ),
      ],
    );
  }
}