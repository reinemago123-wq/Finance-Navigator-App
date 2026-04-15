import 'dart:convert';
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: JsonParserAssignment(),
  ));
}

class JsonParserAssignment extends StatefulWidget {
  const JsonParserAssignment({super.key});

  @override
  State<JsonParserAssignment> createState() => _JsonParserAssignmentState();
}

class _JsonParserAssignmentState extends State<JsonParserAssignment> {
  // Controller to handle the text input
  final TextEditingController _jsonController = TextEditingController();

  // Variables to hold the parsed values
  String countryValue = "N/A";
  String tempValue = "N/A";
  String errorMessage = "";

  // The Parsing Logic
  void parseData() {
    setState(() {
      errorMessage = ""; // Reset error message
    });

    try {
      // 1. Get the string from the TextField
      String input = _jsonController.text;

      // 2. Decode the string
      final Map<String, dynamic> decodedData = jsonDecode(input);

      // 3. Extract and Update UI
      setState(() {
        countryValue = decodedData['sys']['country'] ?? "Not Found";
        tempValue = decodedData['main']['temp']?.toString() ?? "Not Found";
      });
    } catch (e) {
      // Handle invalid JSON format
      setState(() {
        errorMessage = "Invalid JSON format. Please check your syntax.";
        countryValue = "Error";
        tempValue = "Error";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live JSON Parser"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
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
            
            // SECTION: JSON INPUT
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
              child: const Text("PROCESS JSON", style: TextStyle(color: Colors.white)),
            ),
            
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(errorMessage, style: const TextStyle(color: Colors.red)),
              ),
            
            const Divider(height: 40, thickness: 2),
            
            // SECTION: OUTPUT
            const Text(
              "Processing Output:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            
            _buildResultCard("Country Code", countryValue, Icons.flag),
            const SizedBox(height: 10),
            _buildResultCard("Temperature", tempValue != "Error" && tempValue != "N/A" ? "$tempValue K" : tempValue, Icons.thermostat),
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
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
        ),
      ),
    );
  }
}