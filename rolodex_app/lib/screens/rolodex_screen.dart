import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/contact.dart';
import '../widgets/contact_dialog.dart';

class RolodexScreen extends StatefulWidget {
  const RolodexScreen({super.key});

  @override
  State<RolodexScreen> createState() => _RolodexScreenState();
}

class _RolodexScreenState extends State<RolodexScreen> {
  final _firestore = FirebaseFirestore.instance;
  int _selectedIndex = -1;
  List<Contact> _contacts = []; // Local list mirrors Firestore stream

  // ─── UI ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Rolodex Contacts"),
        centerTitle: true,
        actions: [
          // EDIT — only active when a contact is selected
          IconButton(
            icon: const Icon(Icons.edit_note_rounded),
            onPressed: _selectedIndex == -1
                ? null
                : () => _openDialog(editContact: _contacts[_selectedIndex]),
          ),
          // DELETE — only active when a contact is selected
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            onPressed: _selectedIndex == -1 ? null : _confirmDelete,
          ),
        ],
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        height: 70,
        width: 200,
        margin: const EdgeInsets.only(bottom: 10),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.green.shade600,
          elevation: 8,
          onPressed: () => _openDialog(),
          icon: const Icon(Icons.person_add_alt_1_rounded,
              color: Colors.white, size: 28),
          label: const Text(
            "ADD CONTACT",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
        ),
      ),

      // StreamBuilder listens for real-time Firestore updates
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('contacts')
            .orderBy('lastName')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          // Convert Firestore docs → Contact objects using fromFirestore()
          _contacts = snapshot.data!.docs.map((doc) {
            return Contact.fromFirestore(
                doc.id, doc.data() as Map<String, dynamic>);
          }).toList();

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: _contacts.length,
            itemBuilder: (context, index) {
              final contact = _contacts[index];
              final isSelected = _selectedIndex == index;

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  selected: isSelected,
                  selectedTileColor: Colors.green.withOpacity(0.1),
                  selectedColor: Colors.green.shade800,
                  leading: CircleAvatar(
                    backgroundColor:
                        isSelected ? Colors.green : Colors.grey.shade300,
                    child: Text(contact.lastName[0],
                        style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(contact.displayName,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(contact.phoneNumber),
                  onTap: () => setState(() => _selectedIndex = index),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.contact_page_outlined,
              size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text("No contacts yet",
              style:
                  TextStyle(color: Colors.grey.shade600, fontSize: 18)),
        ],
      ),
    );
  }

  // ─── CRUD OPERATIONS ──────────────────────────────────────────────────────

  void _openDialog({Contact? editContact}) {
    showDialog(
      context: context,
      builder: (_) => ContactDialog(
        contact: editContact,
        onConfirm: (contact) {
          if (editContact == null) {
            _createContact(contact);  // CREATE
          } else {
            _updateContact(contact);  // UPDATE
          }
        },
      ),
    );
  }

  // CREATE: Add a new document to the "contacts" collection
  Future<void> _createContact(Contact contact) async {
    await _firestore.collection('contacts').add(contact.toMap());
  }

  // UPDATE: Overwrite the existing document using its Firestore ID
  Future<void> _updateContact(Contact contact) async {
    await _firestore
        .collection('contacts')
        .doc(contact.id)           // ← targets the exact document
        .update(contact.toMap());

    setState(() => _selectedIndex = -1); // deselect after update
  }

  // DELETE: Remove the document using its Firestore ID
  Future<void> _deleteContact(String id) async {
    await _firestore.collection('contacts').doc(id).delete();
    setState(() => _selectedIndex = -1); // deselect after delete
  }

  void _confirmDelete() {
    final contact = _contacts[_selectedIndex];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Contact"),
        content: Text(
            "Are you sure you want to delete ${contact.firstName}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL"),
          ),
          TextButton(
            onPressed: () {
              _deleteContact(contact.id!); // ← uses Firestore doc ID
              Navigator.pop(context);
            },
            child:
                const Text("DELETE", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}