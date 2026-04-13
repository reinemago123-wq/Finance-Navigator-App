import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../widgets/contact_dialog.dart';

class RolodexScreen extends StatefulWidget {
  const RolodexScreen({super.key});

  @override
  State<RolodexScreen> createState() => _RolodexScreenState();
}

class _RolodexScreenState extends State<RolodexScreen> {
  final List<Contact> _rolodex = [];
  int _selectedIndex = -1;

  // --- UI Elements ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Light professional grey
      appBar: AppBar(
        title: const Text("Rolodex Contacts"),
        centerTitle: true,
        // We moved Add to the bottom, so only Edit and Delete stay here
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note_rounded),
            onPressed: _selectedIndex == -1 ? null : () => _openDialog(editContact: _rolodex[_selectedIndex]),
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            onPressed: _selectedIndex == -1 ? null : _confirmDelete,
          ),
        ],
      ),

      // THE BIG GREEN ADD BUTTON (Centrally Aligned)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        height: 70,
        width: 200, // Makes it look like a wide pill/nav bar
        margin: const EdgeInsets.only(bottom: 10),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.green.shade600,
          elevation: 8,
          onPressed: () => _openDialog(),
          icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 28),
          label: const Text(
            "ADD CONTACT",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),

      body: _rolodex.isEmpty 
          ? _buildEmptyState() 
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 100), // Space for the big button
              itemCount: _rolodex.length,
              itemBuilder: (context, index) {
                final contact = _rolodex[index];
                final isSelected = _selectedIndex == index;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    selected: isSelected,
                    selectedTileColor: Colors.green.withOpacity(0.1),
                    selectedColor: Colors.green.shade800,
                    leading: CircleAvatar(
                      backgroundColor: isSelected ? Colors.green : Colors.grey.shade300,
                      child: Text(contact.lastName[0], style: const TextStyle(color: Colors.white)),
                    ),
                    title: Text(contact.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(contact.phoneNumber),
                    onTap: () => setState(() => _selectedIndex = index),
                  ),
                );
              },
            ),
    );
  }

  // Visual for when list is empty
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.contact_page_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text("No contacts yet", style: TextStyle(color: Colors.grey.shade600, fontSize: 18)),
        ],
      ),
    );
  }

  // --- Logic Functions (Dialogs) ---

  void _openDialog({Contact? editContact}) {
    showDialog(
      context: context,
      builder: (_) => ContactDialog(
        contact: editContact,
        onConfirm: (contact) {
          setState(() {
            if (editContact == null) {
              _rolodex.add(contact);
            } else {
              _rolodex[_selectedIndex] = contact;
            }
          });
        },
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Record"),
        content: Text("Are you sure you want to delete ${_rolodex[_selectedIndex].firstName}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          TextButton(
            onPressed: () {
              setState(() {
                _rolodex.removeAt(_selectedIndex);
                _selectedIndex = -1;
              });
              Navigator.pop(context);
            },
            child: const Text("OK", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}