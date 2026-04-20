import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: JsonParserAssignment(),
  ));
}

// ─── SCREEN 1: JSON PARSER ────────────────────────────────────────────────────

class JsonParserAssignment extends StatefulWidget {
  const JsonParserAssignment({super.key});

  @override
  State<JsonParserAssignment> createState() => _JsonParserAssignmentState();
}

class _JsonParserAssignmentState extends State<JsonParserAssignment> {
  final TextEditingController _jsonController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;

  String countryValue = "N/A";
  String tempValue = "N/A";
  String errorMessage = "";
  bool _isParsed = false;   // tracks if a successful parse has happened
  bool _isSaving = false;   // tracks save in progress

  // ─── PARSE ──────────────────────────────────────────────────────────────

  void parseData() {
    setState(() {
      errorMessage = "";
      _isParsed = false;
    });

    try {
      String input = _jsonController.text;
      final Map<String, dynamic> decodedData = jsonDecode(input);

      setState(() {
        countryValue = decodedData['sys']['country'] ?? "Not Found";
        tempValue = decodedData['main']['temp']?.toString() ?? "Not Found";
        _isParsed = true; // unlock the save button
      });
    } catch (e) {
      setState(() {
        errorMessage = "Invalid JSON format. Please check your syntax.";
        countryValue = "Error";
        tempValue = "Error";
        _isParsed = false;
      });
    }
  }

  // ─── SAVE TO FIRESTORE ───────────────────────────────────────────────────

  Future<void> _saveToFirestore() async {
    setState(() => _isSaving = true);

    try {
      await _firestore.collection('parsed_results').add({
        'rawJson':  _jsonController.text.trim(),
        'country':  countryValue,
        'temp':     tempValue,
        'parsedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Result saved successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to save: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  // ─── BUILD ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live JSON Parser"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          // Navigate to history screen
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: "View History",
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Paste JSON Content Below:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // JSON INPUT
            TextField(
              controller: _jsonController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: '{"sys": {"country": "GB"}, "main": {"temp": 300.0}}',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            ),
            const SizedBox(height: 20),

            // PARSE BUTTON
            ElevatedButton(
              onPressed: parseData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                padding: const EdgeInsets.all(15),
              ),
              child: const Text("PROCESS JSON",
                  style: TextStyle(color: Colors.white)),
            ),

            // SAVE BUTTON — only visible after a successful parse
            if (_isParsed) ...[
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveToFirestore,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  padding: const EdgeInsets.all(15),
                ),
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.save, color: Colors.white),
                label: Text(
                  _isSaving ? "Saving..." : "SAVE RESULT",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],

            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(errorMessage,
                    style: const TextStyle(color: Colors.red)),
              ),

            const Divider(height: 40, thickness: 2),

            // OUTPUT
            const Text(
              "Processing Output:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            _buildResultCard("Country Code", countryValue, Icons.flag),
            const SizedBox(height: 10),
            _buildResultCard(
              "Temperature",
              tempValue != "Error" && tempValue != "N/A"
                  ? "$tempValue K"
                  : tempValue,
              Icons.thermostat,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(String label, String value, IconData icon) {
    return Card(
      elevation: 3,
      child: ListTile(
        leading: Icon(icon, color: Colors.indigo),
        title: Text(label),
        trailing: Text(
          value,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.indigo),
        ),
      ),
    );
  }
}

// ─── SCREEN 2: HISTORY ────────────────────────────────────────────────────────

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Parse History"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('parsed_results')
            .orderBy('parsedAt', descending: true) // newest first
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No saved results yet."));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final timestamp = data['parsedAt'] as Timestamp?;
              final date = timestamp != null
                  ? timestamp.toDate().toString().substring(0, 16)
                  : "Unknown time";

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 3,
                child: ExpansionTile(
                  // Tapping expands to show the raw JSON
                  leading: const Icon(Icons.data_object, color: Colors.indigo),
                  title: Text(
                    "Country: ${data['country']}  •  Temp: ${data['temp']} K",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(date,
                      style: const TextStyle(fontSize: 12)),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Raw JSON:",
                              style:
                                  TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              data['rawJson'] ?? '',
                              style: const TextStyle(
                                  fontFamily: 'monospace', fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}